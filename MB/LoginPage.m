//
//  LoginPage.m
//  Practice3
//
//  Created by Mike on 2/24/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "LoginPage.h"
#import "UIRegisterPage.h"
#import "UIGlobals.h"
#import "ParkingInputController.h"
#import "MapViewController.h"
#import "meterbeater.pch"

@interface LoginPage ()

@end


@implementation LoginPage
@synthesize m_btnLogin;
@synthesize m_bGettingInfo;
@synthesize jsonDictionary;
@synthesize parkingZonesDict;
@synthesize m_pTimer,m_uiActivity,defaultConfigObject,defaultSession;
@synthesize m_nCredits,m_nFreeSearches,m_pUUID;
@synthesize m_viewSearchInfo,product,productID,m_bHasObserver,m_bPurchasing,m_bFromSearchPageInApp;
@synthesize m_bStartUpDone;
//,m_btnRegister,m_btnResetPassword,m_txtEmailField,m_txtPassword,m_currentLoginName,m_currentPassword,;

-(void) updateSearchesNumbers
{
    self.m_lbFreeSearches.text = [[NSString alloc] initWithFormat: @"Free Searches:  %ld",(long)m_nFreeSearches];
    self.m_lbSearchCredits.text = [[NSString alloc] initWithFormat:@"Search Credits: %ld",(long)m_nCredits];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_bStartUpDone = NO;
    m_nFreeSearches = 0;
    m_nCredits = 0;
    m_bHasObserver = false;
    m_bPurchasing = false;
    m_bFromSearchPageInApp = NO;
    // Start NSURLSession
    defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultSession = [NSURLSession sharedSession];
    
    self.tabBarController.delegate = self;
    self.m_bGettingInfo = NO;
    self.m_uiActivity.hidesWhenStopped = YES;
    m_pTimer=[NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(searching) userInfo:nil repeats:YES];
    //[self.m_btnLogin setTitle:@"Continue" forState:UIControlStateNormal];
    
    self.m_viewSearchInfo.layer.cornerRadius = 10.0f;
    self.m_viewSearchInfo.layer.masksToBounds = YES;
    self.m_viewSearchInfo.backgroundColor = [UIGlobals ourLightGray];
    [self updateLoginButton];
    [self getPermitZonage];
    
    m_pUUID=[[NSUserDefaults standardUserDefaults] objectForKey:@"incoding"];
    if(!m_pUUID)
    {
        m_pUUID = [LoginPage uuid];
        [[NSUserDefaults standardUserDefaults] setValue:m_pUUID forKey:@"incoding" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //add a black UIView to have the status bar show up white against
    CGFloat fHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    UIView *statusBarBG = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, fHeight)];
    statusBarBG.backgroundColor = [UIColor blackColor];
    [self.view addSubview: statusBarBG];
    
    //NSString *pEmailString = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    /*self.m_txtPassword.delegate = self;
     self.m_txtEmailField.delegate = self;
     self.m_bLoginSucceeded = false;
     NSString *pPass = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
     
     self.m_txtEmailField.text = pEmailString;
     
     if(pPass)
     self.m_txtPassword.text = pPass;
     else
     self.m_txtPassword.text = @"";
     
     self.m_btnResetPassword.hidden = TRUE;
     if(pEmailString && pPass)
     {
     [self tryLogin:pEmailString :pPass : YES];
     }
     self.m_currentLoginName = m_txtEmailField.text;
     self.m_currentPassword = m_txtPassword.text;
     
     */
}

-(void) updateLoginButton
{
    //UIViewController *pView = [[self.tabBarController viewControllers] objectAtIndex:SEARCH_INDEX];
    //ParkingInputController *pPIC = (ParkingInputController*)pView;
    //[pPIC setLoggedIn:self.m_bLoginSucceeded];
    
    /*if(self.m_bLoginSucceeded)
     {
     [self.m_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [self.m_btnLogin setTitle:@"Continue" forState:UIControlStateNormal];
     }
     else
     {
     [self.m_btnLogin setTitle:@"Login" forState:UIControlStateNormal];
     [self.m_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     }*/
}

-(void) viewDidAppear:(BOOL)animated
{
    self.tabBarController.delegate = self;
    [self updateLoginButton];
    
    
    BOOL bCheck = [[NSUserDefaults standardUserDefaults] boolForKey:@"checkSearches"];
    if(bCheck)
    {
        [self getSearchCounts];
    }
    
    if(!m_bHasObserver)
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        m_bHasObserver = true;
    }
    
    if(self.m_bFromSearchPageInApp)
    {
        self.m_bFromSearchPageInApp = NO;
        [self inAppPurchaseHelper];
    }
    
    if(!m_bStartUpDone)
    {
        m_bStartUpDone = YES;
        [self transitionToMapPage];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailStr];
}

- (IBAction)LoginClicked:(id)sender
{
    /* NSString *pEmail = _m_txtEmailField.text;
     NSString *pPassword=m_txtPassword.text;
     
     if(self.m_bLoginSucceeded)
     {
     //check to see if there were any changes
     if([pPassword isEqualToString:m_currentPassword]&&
     [pEmail isEqualToString:m_currentLoginName])
     {
     [self transitionToSearchPage];
     return;
     }
     else
     {
     //retry under new credentials
     self.m_bLoginSucceeded=false;
     }
     }
     
     self.m_currentLoginName=pEmail;
     self.m_currentPassword=pPassword;
     [[NSUserDefaults standardUserDefaults] setValue:pEmail forKey:@"email" ];
     [[NSUserDefaults standardUserDefaults] setValue:pPassword forKey:@"password" ];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     if([pEmail isEqualToString:@""])
     {
     UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Login Error!" message:@"Please enter Email" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
     [pAlert show];
     }
     else if([pPassword isEqualToString:@""])
     {
     UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Please enter password" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
     [pAlert show];
     }
     else if(![self validateEmail:pEmail])
     {
     UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Login Error" message:@"Invalid email format" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
     [pAlert show];
     }
     else
     {
     [self tryLogin:pEmail : pPassword : NO];
     }
     */
    
    [self transitionToSearchPage];
}

- (IBAction)RegisterClicked:(id)sender
{
    [self pushRegistrationPage];
}

/*- (IBAction)resetPasswordClicked:(id)sender
 {
 [self pushRegistrationPage];
 }
 
 - (IBAction)OnEmailEdit:(id)sender
 {
 self.m_bLoginSucceeded=false;
 [self updateLoginButton];
 }
 
 - (IBAction)OnPassChange:(id)sender
 {
 self.m_bLoginSucceeded=false;
 [self updateLoginButton];
 }*/


-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void) getPermitZonage///This gets the center of all the zoning infos;
__deprecated
{
    return;
    
    self.m_bGettingInfo = YES;
    // POST parameters
#pragma warning Add your own url call.
    NSURL *url = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         if(error == nil)
                                         {
                                             // Parse out the JSON data
                                             NSError *jsonError;
                                             self->jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                                       error:&jsonError];
                                             
                                             if(!self->parkingZonesDict)
                                                 self->parkingZonesDict = [[NSMutableDictionary alloc] initWithCapacity : 2048];
                                             
                                             if(self->jsonDictionary && self->jsonDictionary.count)
                                             {
                                                 for(NSInteger i=0; i<self->jsonDictionary.count; i++)
                                                 {
                                                     const NSMutableDictionary *pDict = [self->jsonDictionary objectAtIndex:i];
                                                     if( pDict)
                                                     {
                                                         NSString *cZone = [pDict objectForKey: @"zone"];
                                                         NSString *cLat  = [pDict objectForKey: @"latitude"];
                                                         NSString *cLong = [pDict objectForKey: @"longitude"];
                                                         
                                                         CLLocation *newLocation = [[CLLocation alloc] initWithLatitude :[cLat doubleValue] longitude: [cLong doubleValue]];
                                                         
                                                         [self->parkingZonesDict setObject:newLocation forKey:cZone];
                                                     }
                                                 }
                                             }
                                             else
                                             {
                                             }
                                         }
                                         
                                         self.m_bGettingInfo = NO;
                                     }];
    
    [dataTask resume];
    return;
}

-(void) getSearchCounts __deprecated
{
    return;
    self.m_bGettingInfo = YES;
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    
    // POST parameters
    NSURL *url = nil;
    
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"device_id=%@&newID=%@", uniqueIdentifier,m_pUUID];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         
                                         bool bShowError = true;
                                         if(error == nil)
                                         {
                                             // Parse out the JSON data
                                             NSError *jsonError;
                                             NSDictionary *info;
                                             info  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                       error:&jsonError];
                                             if(info && info.count)
                                             {
                                                 NSString *pFreeSearches = [[NSString alloc] init];
                                                 pFreeSearches = [info objectForKey:@"free"];
                                                 
                                                 NSString *pInventory = [[NSString alloc] init];
                                                 pInventory = [info objectForKey:@"inventory"];
                                                 
                                                 if(![pFreeSearches isKindOfClass:[NSNull class]])
                                                     self->m_nFreeSearches = [pFreeSearches intValue];
                                                 else
                                                     self->m_nFreeSearches = 0;
                                                 
                                                 if(![pInventory isKindOfClass:[NSNull class]])
                                                     self->m_nCredits  = [pInventory intValue];
                                                 else
                                                     self->m_nCredits = 0;
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^
                                                                {
                                                                    [self updateSearchesNumbers];
                                                                });
                                                 bShowError = false;
                                             }
                                         }
                                         
                                         self.m_bGettingInfo = NO;
                                         if( bShowError)
                                         {
                                             dispatch_async(dispatch_get_main_queue(), ^
                                                            {
                                                                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login Failed!" message: @"Server might be down. We apologize." preferredStyle:UIAlertControllerStyleAlert];
                                                                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
                                                                [alertController addAction:cancelAction];
                                                                [self presentViewController: alertController animated:YES completion:nil];
                                                            });
                                         }
                                     }];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey: @"checkSearches"] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [dataTask resume];
    return;
}


/*-(void) tryLogin:(NSString *)emailAnd :(NSString *) passwordAnd : (BOOL) isFirstTry __deprecated
 {
 self.m_bTryingToLogin = YES;
 UIDevice *device = [UIDevice currentDevice];
 NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
 // Create url connection and fire request
 // Start NSURLSession
 
 // POST parameters
 #ifndef USE_LINODE
 NSURL *url = ni;
 #endif
 
 NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
 NSString *params = [NSString stringWithFormat:@"device_id=%@&email=%@&loginpass=%@&newID=%@", uniqueIdentifier,emailAnd,passwordAnd,m_pUUID];
 
 [urlRequest setHTTPMethod:@"POST"];
 [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
 
 // NSURLSessionDataTask returns data, response, and error
 NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
 completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
 {
 if(error == nil)
 {
 
 // Parse out the JSON data
 NSError *jsonError;
 NSDictionary *info;
 info  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
 error:&jsonError];
 
 
 if(info && info.count)
 {
 NSString *pSuccess=[[NSString alloc] init];
 pSuccess=[info objectForKey:@"success"];
 if ([pSuccess isEqualToString:@"1"])
 {
 self.m_bLoginSucceeded=true;
 [self updateLoginButton];
 [self transitionToSearchPage];
 }
 else
 {
 if(!isFirstTry)
 {
 NSString *pError=[info objectForKey:@"error_message"];
 UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Login Failed!" message:pError delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
 [pAlert show];
 }
 
 self.m_bLoginSucceeded=false;
 }
 }
 else
 {
 
 
 UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Login Failed!" message:@"Server Might Be Down" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
 [pAlert show];
 self.m_bLoginSucceeded=false;
 }
 }
 else
 {
 UIAlertView *pAlert = [[UIAlertView alloc]initWithTitle:@"Login Failed" message:@"Server is Down! We apologize" delegate:nil cancelButtonTitle:@"dismiss" otherButtonTitles:nil, nil];
 [pAlert show];
 self.m_bLoginSucceeded=FALSE;
 
 }
 
 self.m_bTryingToLogin = NO;
 }];
 
 [dataTask resume];
 return;
 }
 */

-(void) pushRegistrationPage
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIRegisterPage *pRegPage = [storyboard instantiateViewControllerWithIdentifier:@"RegisterPage"];
    
    [pRegPage setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:pRegPage animated:YES completion:nil];
}

-(void) transitionToMapPage
{
    [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[[self.tabBarController viewControllers] objectAtIndex: MAP_INDEX]];
    
    [self.tabBarController setSelectedIndex: MAP_INDEX];
    
}

-(void) transitionToSearchPage
{
    [self.tabBarController.delegate tabBarController:self.tabBarController shouldSelectViewController:[[self.tabBarController viewControllers] objectAtIndex:SEARCH_INDEX]];
    
    [self.tabBarController setSelectedIndex:SEARCH_INDEX];
}

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
#ifndef USE_LOGIN_PAGE
    return YES;
#else
    if( self.m_bLoginSucceeded)
    {
        return YES;
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Login Attempt" message: @"Not logged in." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
        
        return NO;
    }
#endif
}

-(void) searching
{
    if(self.m_bGettingInfo)
        [self.m_uiActivity startAnimating];
    else
        [self.m_uiActivity stopAnimating];
}

-(NSMutableDictionary*)zones
{
    return self.parkingZonesDict;
}


- (IBAction)InfoClicked:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Free Searches FYI" message: @"You will be allocated free searches (amount subject to change) on a daily basis for the Meter Beaters' free parking database. You may purchase non-expiring search credits at anytime.  The meter map and permit map searches do not count against your search balance, so search away!." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController: alertController animated:YES completion:nil];
    
}

- (IBAction)AddMore:(id)sender
{
    if(!m_bPurchasing)
    {
        [self inAppPurchaseHelper];
    }
}

//IN-APP Interface---------------------------------
-(void) unlockPurchase
{
    [self redeemed];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"In-App Purchase" message: @"Success! Thank you for purchasing the Meter Beaters' parking pass!." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController: alertController animated:YES completion:nil];
    
    [self getSearchCounts];
}

-(void) logTest : (NSString*) pMessage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"In-App Purchase" message: pMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController: alertController animated:YES completion:nil];
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *item in transactions)
    {
        switch(item.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
            {
                self.m_bGettingInfo=YES;
                LogBeater(@"Transaction state -> Purchasing");
                continue;
            }
            case SKPaymentTransactionStatePurchased:
            {
                self.m_bPurchasing = NO;
                self.m_bGettingInfo=NO;
                [self unlockPurchase];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                self.m_bGettingInfo=NO;
                self.m_bPurchasing = NO;
                LogBeater(@"transaction failed");
                if(item.error.code != SKErrorPaymentCancelled)
                {
                    LogBeater(@"Transaction state -> Cancelled");
                }
                else
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"In-App Purchase" message: @"Purchase failed." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController: alertController animated:YES completion:nil];
                }
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                self.m_bGettingInfo=NO;
                LogBeater(@"Transaction state -> Restored");
                break;
            }
            default:
            {
                self.m_bGettingInfo=NO;
                break;
            }
        }
        
        [[SKPaymentQueue defaultQueue] finishTransaction:item];
    }
}

#pragma mark
#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    if(products.count == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"In-App Purchase" message: @"Product not found." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
    }
    else
    {
        product = products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    
    products= response.invalidProductIdentifiers;
    for(SKProduct *item in products)
    {
        LogBeater(@"Product not Found: %@",item);
    }
}

-(void) inAppPurchaseHelper
{
    if([SKPaymentQueue canMakePayments])
    {
        self.productID=@"MeterBeater.MeterBeater.parkingpass";
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
        request.delegate=self;
        [request start];
        m_bPurchasing = YES;
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"In-App Purchase" message: @"Please enable in-app purchases in your settings." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
    }
}

- (IBAction) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    LogBeater(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored)
        {
            LogBeater(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

//IN-APP interface END-------------------------------------------------------



-(void) redeemed __deprecated
{
    return;
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    
    // POST parameters
    NSURL *url = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"device_id=%@&admin=1&newID=%@", uniqueIdentifier,m_pUUID  ];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         // Remove progress window
                                         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                                         NSInteger statusCode = [httpResponse statusCode];
                                         if(error == nil)
                                         {
                                             if (statusCode==401)
                                             {
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^
                                                                {
                                                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Request Failed" message: @"Tech support has been notified, sorry for the delay." preferredStyle:UIAlertControllerStyleAlert];
                                                                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
                                                                    [alertController addAction:cancelAction];
                                                                    [self presentViewController: alertController animated:YES completion:nil];
                                                                });
                                             }
                                             else
                                             {
                                                 [self getSearchCounts];
                                             }
                                         }
                                         else
                                         {
                                             
                                         }}];
    
    if(dataTask)
    {
        [dataTask resume];
    }
    else
    {
        LogBeater(@"data task is nil");
    }
    
    return;
}

-(void) setInAppPurchaseFromSearchPage
{
    self.m_bFromSearchPageInApp = YES;
}

+(NSString*) uuid
{
    static NSString *smUUID = nil;
    if(!smUUID)
    {
        smUUID = [UIGlobals uuid];
    }
    
    return smUUID;
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
