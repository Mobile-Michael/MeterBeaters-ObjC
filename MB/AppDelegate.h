//
//  AppDelegate.h
//  Practice3
//
//  Created by Mike on 9/2/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSDate *m_pTimeWentToForeground;
}

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong)UITabBarController *tabBarController;
@property NSTimer *m_pTimer;
@property (atomic) BOOL m_bRedrawAnnotations;
@property (nonatomic,strong) NSMutableDictionary *openSpotDict;
@property (weak,nonatomic) NSURLSessionConfiguration *defaultConfigObject;
@property (weak,nonatomic) NSURLSession *defaultSession;

-(void) getOpenSpotInfo;
-(NSInteger) getSpotsForID : (NSString *)key;
-(void) changeTimerState : (BOOL) bOn : (NSInteger) nSeconds;

@end
