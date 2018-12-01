//
//  UICommentsPage.m
//  Practice3
//
//  Created by Mike on 2/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "UICommentsPage.h"
#import "UIGlobals.h"
#import "LoginPage.h"
#import "font_changer.h"

@interface UICommentsPage ()

@end

@implementation UICommentsPage
@synthesize  m_btPostComment,m_tfComments,m_lbRemainingCHars,m_btnBack,m_btnRateThisApp;
@synthesize  m_uiHeader;
@synthesize m_pNavController;

#define MAX_COMMENT_LEN 254
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.m_tfComments.delegate = self;
    
    // Do any additional setup after loading the view.
    m_btPostComment.layer.cornerRadius = 2;
    m_btPostComment.layer.borderWidth = 1;
    m_btPostComment.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    m_btnRateThisApp.layer.cornerRadius = 2;
    m_btnRateThisApp.layer.borderWidth = 1;
    m_btnRateThisApp.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
}

-(void) viewDidAppear:(BOOL)animated
{
    //CGFloat fHeightOfNavBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    //CGRect moveDownHeader = CGRectOffset(m_uiHeader.frame, 0, fHeightOfNavBar);
    //m_uiHeader.frame = moveDownHeader;
    
    //m_tfComments.frame = CGRectOffset(m_tfComments.frame, 0,  fHeightOfNavBar);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)postFeedBackClicked:(id)sender
{
    [m_tfComments resignFirstResponder];
    NSString *pEmail=  [UIGlobals getEmail];
    [self postToDatabase:m_tfComments.text :pEmail];
}

- (IBAction)backClicked:(id)sender
{
    [self goBack];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSUInteger newLength = [textView.text length];
    NSString *pRemaining = [NSString stringWithFormat:@"Remaining Characters: %lu",(unsigned long)(MAX_COMMENT_LEN-newLength)];
    m_lbRemainingCHars.text = pRemaining;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:@"Leave Comments Here..."])
    {
        textView.text = @"";
    }
}

-(BOOL) textView:(UITextView *)textView shouldChangeTextInƒange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength=[textView.text length]+[text length] -range.length;
    return (newLength > MAX_COMMENT_LEN)? NO: YES;
}

-(void) postToDatabase : (NSString *) pComment :(NSString*) pEmail __deprecated
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [[device identifierForVendor] UUIDString];
    // Create url connection and fire request
    // Start NSURLSession
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    // POST parameters
    NSURL *url = nil;
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if(!pEmail)
        pEmail = @"NOEMAIL";
    
    NSString *newID = [LoginPage uuid];
    NSString *params = [NSString stringWithFormat:@"device_id=%@&email=%@&comment=%@&newID=%@", uniqueIdentifier,pEmail,pComment,newID];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSURLSessionDataTask returns data, response, and error
    NSURLSessionDataTask *dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response,NSError *error)
                                     {
                                         [self goBack];
                                     }];
    
    [dataTask resume];
    return;
}

-(void) goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)gotoReviews:(id)sender
{
    NSString *str = @"https://itunes.apple.com/app/id866702252?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)RateThisApp:(id)sender
{
    [self gotoReviews:self];
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
