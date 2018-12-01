//
//  LoginPage.h
//  Practice3
//
//  Created by Mike on 2/24/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@interface LoginPage : UIViewController<UITextFieldDelegate,UITabBarControllerDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *m_txtEmailField;
@property (weak, nonatomic) IBOutlet UIButton *m_btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRegister;
@property (nonatomic,strong) NSMutableArray *jsonDictionary;
@property (nonatomic,strong) NSMutableDictionary *parkingZonesDict;
@property (weak,nonatomic) NSURLSessionConfiguration *defaultConfigObject;
@property (weak,nonatomic) NSURLSession *defaultSession;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_uiActivity;
@property (weak,nonatomic) NSString *m_pUUID;
@property bool m_bGettingInfo;
@property (weak, nonatomic) IBOutlet UILabel *m_lbFreeSearches;
@property (weak, nonatomic) IBOutlet UILabel *m_lbSearchCredits;
@property (weak, nonatomic) IBOutlet UIView *m_viewSearchInfo;
@property (strong,nonatomic) SKProduct *product;
@property (strong,nonatomic) NSString *productID;

@property BOOL m_bHasObserver;
@property BOOL m_bPurchasing;
@property BOOL m_bFromSearchPageInApp;
@property BOOL m_bStartUpDone;
@property NSInteger m_nFreeSearches;
@property NSInteger m_nCredits;
@property NSTimer *m_pTimer;

- (IBAction)InfoClicked:(id)sender;
- (IBAction)AddMore:(id)sender;
- (IBAction)LoginClicked:(id)sender;
- (IBAction)RegisterClicked:(id)sender;

#ifdef USE_LOGIN_PAGE
 @property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;
 @property BOOL m_bLoginSucceeded;
 - (IBAction)ResetPasswordClicked:(id)sender;
 - (IBAction)OnEmailEdit:(id)sender;
 - (IBAction)OnPassChange:(id)sender;
//-(void) tryLogin: (NSString*) emailAnd : (NSString*) passwordAnd : (BOOL) isFirstLogin;
#endif

-(NSMutableDictionary*)zones;
-(void) getPermitZonage;

-(void) getSearchCounts;
-(void) setInAppPurchaseFromSearchPage;
+(NSString*) uuid;

@end
