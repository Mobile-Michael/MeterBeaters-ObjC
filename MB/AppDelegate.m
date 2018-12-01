//
//  AppDelegate.m
//  Practice3
//
//  Created by Mike on 9/2/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "AppDelegate.h"
#import "ParkingInputController.h"
#import "MapViewController.h"
#import "UIGlobals.h"
#import "ParkTimeInfo.h"
#import "meterbeater.pch"
#import "ParkingSearchFilters.h"


@implementation AppDelegate
@synthesize tabBarController,openSpotDict,m_pTimer;
@synthesize defaultSession,defaultConfigObject,m_bRedrawAnnotations;


#define TIMER_AMOUNT 600
- (BOOL)checkNotificationType:(UIUserNotificationType)type
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        return (currentSettings.types & type);
    }
    else{
        return true;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.tabBarController = (UITabBarController*)self.window.rootViewController;
    
    
    UIImage *tabBarBackground = [UIImage imageNamed:@"TabBarGrayNoEM.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    tabBarController.tabBar.tintColor = [UIColor blackColor];
    m_bRedrawAnnotations = false;
    
    
    
    
    //set a timer for 10 minutes to make a call to get the open spots
    [self changeTimerState: YES : TIMER_AMOUNT];
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories : nil]];
        
        [application registerForRemoteNotifications];
    }
    
    //if shortcut item do not return YES;
    UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
    if( shortcutItem)
    {
        return [self handleShortcutItem: shortcutItem isStartup: YES];
    }
    else
        return YES;
    
    
}

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey: @"token_encoded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    LogBeater(@"Failed to register for Push Notifications");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self changeTimerState: NO : 0];
    m_pTimeWentToForeground = [NSDate date];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if( m_pTimeWentToForeground)
    {
        NSDate *timeNow = [NSDate date];
        NSTimeInterval timeAway = [timeNow timeIntervalSinceDate : m_pTimeWentToForeground];
        if( timeAway > 600)
        {
            [UIGlobals getSearchFilters].m_bParkingQueryChanged = YES;
        }
        
        LogBeater(@"time away was %f seconds", timeAway);
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey: @"checkSearches"] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if( [self checkNotificationType: UIUserNotificationTypeBadge])
    {
        application.applicationIconBadgeNumber = 0;
    }
    
    //download the openSpotInfo
    [self getOpenSpotInfo];
    [self changeTimerState: YES : TIMER_AMOUNT];
    application.applicationSupportsShakeToEdit = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if( [self m_pTimer])
    {
        [[self m_pTimer] invalidate];
    }
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSDictionary *result = [userInfo objectForKey:@"aps"];
    if(result)
    {
        NSString * pString = [result objectForKey:@"alert"];
        if(pString)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Push Notification Received!" message: pString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss OK button" ) style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            // Provide quick access to Settings.
            
            [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    }
    
    if( [self checkNotificationType: UIUserNotificationTypeBadge])
    {
        application.applicationIconBadgeNumber = 0;
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Parking Is About To Expire!" message: @"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Dismiss OK button" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}


-(void) getOpenSpotInfo __deprecated
{
#warning implement this yourself
    return;
    m_bRedrawAnnotations = true;
    //NSDate *methodStart = [NSDate date];
    // POST parameters
    
    NSURL *url = [NSURL URLWithString:@".....getOpenSpotInfo.php"];
    // was using this to test at timout NSURL *url = [NSURL URLWithString:@"http://10.255.255.1"];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // Start NSURLSession
    if(!defaultConfigObject)
    {
        defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    
    defaultConfigObject.timeoutIntervalForRequest = 5;
    defaultConfigObject.timeoutIntervalForResource = 5;
    
    if(!defaultSession)
    {
        defaultSession = [NSURLSession sharedSession];
    }
    
    // NSURLSessionDataTask returns data, response, and error
    if(self.openSpotDict)
    {
        [self.openSpotDict removeAllObjects];
    }
    
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         if(error == nil)
                                         {
                                             
                                             // Parse out the JSON data
                                             NSError *jsonError;
                                             NSMutableArray *result  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                                         error:&jsonError];
                                             
                                             
                                             if(!self.openSpotDict)
                                             {
                                                 self.openSpotDict = [[NSMutableDictionary alloc] init];
                                             }
                                             
                                             if(result && result.count)
                                             {
                                                 for(NSInteger i=0;i < result.count; i++)
                                                 {
                                                     NSString *cDB_id  = [[result objectAtIndex : i] objectForKey:@"db_id"];
                                                     NSString *cSpots  = [[result objectAtIndex : i] objectForKey:@"spots"];
                                                     [self.openSpotDict setValue: cSpots forKey: cDB_id];
                                                     //LogBeater(@"spot: %@ -> = %@", cDB_id, cSpots);
                                                 }
                                             }
                                             else
                                             {
                                             }
                                         }
                                         else
                                         {
                                             LogBeater(@"Error %@", error);
                                         }
                                         
                                         //NSDate *methodFinish = [NSDate date];
                                         //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                                         //NSString *pValue = [self.openSpotDict valueForKey:@"7706"];
                                         //LogBeater(@"executionTime = %f", executionTime);
                                         self->m_bRedrawAnnotations = true;
                                         
                                     }];
    
    [dataTask resume];
    return;
}

-(NSInteger) getSpotsForID : (NSString *)key
{
    NSInteger nRet = 0;
    if( self.openSpotDict)
    {
        NSString *pReturn = [self.openSpotDict objectForKey: key];
        if( pReturn != nil)
        {
            nRet = [pReturn integerValue];
        }
    }
    
    return nRet;
}

-(void) onTimerCall
{
    [self getOpenSpotInfo];
}

-(void) changeTimerState : (BOOL) bOn : (NSInteger) nSeconds
{
    if( bOn)
    {
        if( ![self m_pTimer])
        {
            self.m_pTimer = [NSTimer scheduledTimerWithTimeInterval : nSeconds
                                                              target:self selector:@selector(onTimerCall) userInfo:nil repeats:YES];
        }
    }
    else
    {
        if( [self m_pTimer])
        {
            [[self m_pTimer] invalidate];
            m_pTimer = nil;
        }
    }
}

#define SHORTCUT_FREE_2_HR @"free.parking.2.shortcut"
#define SHORTCUT_FREE_4_HR @"free.parking.4.shortcut"
#define SHORTCUT_METER     @"meter.parking.shortcut"

#pragma mark home shortcut actions
-(void)application:(UIApplication *)application performActionForShortcutItem:(nonnull UIApplicationShortcutItem *)shortcutItem completionHandler:(nonnull void (^)(BOOL))completionHandler
{
    [self handleShortcutItem: shortcutItem isStartup: NO];
}

-(BOOL)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem isStartup:(BOOL)bStartup
{
    if( !shortcutItem)
        return NO;
    
    NSString *type = shortcutItem.type;
    bool bTransition = NO;
    ParkingSearchFilters *pSearchFilters = [UIGlobals getSearchFilters];
    NSInteger nHoursToAdd = 2;
    if( [type isEqualToString: SHORTCUT_FREE_2_HR])
    {
        bTransition = YES;
        [pSearchFilters SetParkType: FREE];
    }
    else if([type isEqualToString: SHORTCUT_FREE_4_HR])
    {
        bTransition = YES;
        [pSearchFilters SetParkType: FREE];
        nHoursToAdd = 4;
    }
    else if( [type isEqualToString: SHORTCUT_METER])
    {
        bTransition = YES;
        [pSearchFilters SetParkType: METER];
    }
    
    if( bTransition)
    {
        [pSearchFilters setUseMyLocation: YES];
        
        NSDate *pDate = [[NSDate alloc] initWithTimeIntervalSinceNow: 0];
        [[pSearchFilters getParkTimeBegin] setFromNSDate: pDate];
        [[pSearchFilters getParkTimeEnd] setFromNSDate: pDate];
        [[pSearchFilters getParkTimeEnd] addTime: nHoursToAdd : 0];
        pSearchFilters.m_bParkingQueryChanged = YES;
        
        //1.) need to set location services to true
        //2.) need to changet the parking type
        //3.) need to
        NSInteger pageIndex = MAP_INDEX;
        if(pageIndex > 0 && pageIndex < NUM_PAGE_INDEXES)
        {
            if( self.tabBarController.selectedIndex != pageIndex)
            {
                [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[[self.tabBarController viewControllers] objectAtIndex : pageIndex]];
                [self.tabBarController setSelectedIndex : pageIndex];
            }
            else
            {
                if( !bStartup)
                {
                    MapViewController *pMapView = (MapViewController*)[[self.tabBarController viewControllers] objectAtIndex: pageIndex];
                    [pMapView onViewDidAppear];
                }
            }
        }
    }
    
    return bTransition;
}

@end
