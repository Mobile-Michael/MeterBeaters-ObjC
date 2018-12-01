//
//  UIRegisterPage.m
//  Practice3
//
//  Created by Mike on 2/25/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "UIRegisterPage.h"
#import "UIGlobals.h"
#import "LoginPage.h"
#import "meterbeater.pch"
#import "font_changer.h"

@interface UIRegisterPage ()

@end

@implementation UIRegisterPage
@synthesize m_btnRegisterDevice,m_tEmail,m_tPassword,m_tPasswordConfirm;
@synthesize  m_uiActivity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.m_tPassword.delegate = self;
    self.m_tPasswordConfirm.delegate = self;
    self.m_tEmail.delegate = self;
    
    m_pTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(searching) userInfo:nil repeats:YES];
    self.m_uiActivity.hidesWhenStopped=YES;
    m_bWaiting=false;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIGlobals ourLightGray];
    
    self.m_btnRegisterDevice.layer.cornerRadius = 5;
    self.m_btnRegisterDevice.layer.borderWidth = 1;
    self.m_btnRegisterDevice.layer.borderColor = [UIGlobals ourDarkGray].CGColor;
    
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
}

-(void) viewDidAppear:(BOOL)animated
{
    self.m_tPassword.text = @"";
    self.m_tPasswordConfirm.text = @"";
    self.m_tEmail.text = @"";
}

-(void) searching
{
    if(m_bWaiting)
    {
        [self.m_uiActivity startAnimating];
    }
    else
    {
        [self.m_uiActivity stopAnimating];
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

- (IBAction)RegisterClicked:(id)sender
{
    NSString *pErrorMessage = nil;
    if([self.m_tEmail.text isEqualToString:@""])
    {
        pErrorMessage = @"Please enter Email.";
    }
    else if([self.m_tPassword.text isEqualToString:@""])
    {
        pErrorMessage = @"Please enter password.";
    }
    else if([self.m_tPasswordConfirm.text isEqualToString:@""])
    {
        pErrorMessage = @"Please confirm password.";
    }
    else if(![self validateEmail:self.m_tEmail.text])
    {
        pErrorMessage = @"Please enter a valid email address.";
    }
    else
    {
        //check password matches
        if(![self.m_tPassword.text isEqualToString:self.m_tPasswordConfirm.text])
        {
            pErrorMessage = @"Passwords do not match";
        }
        else
        {
            m_bWaiting=true;
            [self tryRegister];
            //now we can check to see if the device is registered
        }
    }
    
    if( pErrorMessage)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Input Error" message: pErrorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
    }
}

- (IBAction)BackClicked:(id)sender
{
    [self goBack];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void) genericAlertView : (NSString*) pMessage : (NSString*) pTitle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: pTitle message: pMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"Login Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController: alertController animated:YES completion:nil];
}

-(void) tryRegister __deprecated
{
    return;
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    
    // Create url connection and fire request
    // Start NSURLSession
    NSURLSession *defaultSession = [NSURLSession sharedSession];
    
    NSString *pEmail    = self.m_tEmail.text;
    NSString *pPassword = self.m_tPassword.text;
    
    // POST parameters
    NSURL *url = nil;
    
    NSString *newID = [LoginPage uuid];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params = [NSString stringWithFormat:@"device_id=%@&email=%@&loginpass=%@&newID=%@", uniqueIdentifier,pEmail,pPassword,newID];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                      completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         self->m_bWaiting=false;
                                         if(error == nil)
                                         {
                                             NSError *jsonError;
                                             NSDictionary *jsonDictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                                               error:&jsonError];
                                             
                                             if(jsonDictionary && jsonDictionary.count)
                                             {
                                                 NSString *pSuccess=[[NSString alloc] init];
                                                 pSuccess=[jsonDictionary objectForKey:@"success"];
                                                 if ([pSuccess isEqualToString:@"1"])
                                                 {
                                                     [UIGlobals saveEmail: self.m_tEmail.text];
                                                     [self genericAlertView: @"Email Registered" : @"Success"];
                                                     [self dismissViewControllerAnimated:NO completion:nil];
                                                     [self goBack];
                                                 }
                                                 else
                                                 {
                                                     NSString *pError=[jsonDictionary objectForKey:@"error_message"];
                                                     [self genericAlertView: pError : @"Register Failed"];
                                                 }
                                             }
                                             else
                                             {
                                                 [self genericAlertView: @"Server Might Be Down" : @"Login Failed"];
                                             }
                                         }
                                         else
                                         {
                                             [self genericAlertView: @"Server Might Be Down" : @"Login Failed"];
                                         }
                                     }];
    
    if(dataTask)
    {
        [dataTask resume];
    }
    else
    {
        LogBeater(@"Data task is nil");
    }
    return;
}


-(void) goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
