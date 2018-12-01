//
//  SocialController.m
//  Practice3
//
//  Created by Mike on 3/5/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "SocialController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SocialController ()

@end

@implementation SocialController

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
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onPostToFacebookRequest
{
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
  {
    m_slComposerSheet = [[SLComposeViewController alloc] init];
    m_slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [m_slComposerSheet setInitialText:@"test"];
    [m_slComposerSheet addURL:[NSURL URLWithString:@"http://www.wikipedia.com"]];
    [m_slComposerSheet addImage:[UIImage imageNamed:@"recenter.png"]];
    [self presentViewController:m_slComposerSheet animated:YES completion:NULL];
    
    //FBShareDialog
  }
  else
  {
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Sorry!" message:@"You can't access Facebook right now. Make sure you have at least one Facebook account set up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
  }
}


-(IBAction)PostToFacebook  :(id)sender
{
  [self onPostToFacebookRequest];
}

-(void) presentShareDialog : (FBShareDialogParams*) params
{
  // Present share dialog
  [FBDialogs presentShareDialogWithLink:params.link
                                   name:params.name
                                caption:params.caption
                            description:params.description
                                picture:params.picture
                            clientState:nil
                                handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                  if(error)
                                  {
                                    // An error occurred, we need to handle the error
                                    // See: https://developers.facebook.com/docs/ios/errors
                                    NSString *sError=[NSString stringWithFormat:@"Error publishing story: %@ ", error.description];
                                    
                                    NSLog(@"%@",sError);
                                  }
                                  else
                                  {
                                    // Success
                                    NSLog(@"result %@", results);
                                  }
                                }];
}

-(void) facebookShare
{
// Check if the Facebook app is installed and we can present the share dialog
  FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
  params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
  params.name = @"Sharing Tutorial";
  params.caption = @"Build great social apps and get more installs.";
  params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
  params.description = @"Allow your users to share stories on Facebook from your app using the iOS SDK.";

  // If the Facebook app is installed and we can present the share dialog
  if ([FBDialogs canPresentShareDialogWithParams:params])
  {
    [self presentShareDialog:params];
  }
  else
  {
    // Present the feed dialog
    [self lastChanceShareAttempt];
  }
}

-(void) onTweetRequest
{
  if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
  {
    m_slComposerSheet = [[SLComposeViewController alloc] init];
    m_slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [m_slComposerSheet setInitialText:@"test"];
    [m_slComposerSheet addURL:[NSURL URLWithString:@"http://www.wikipedia.com"]];
    [m_slComposerSheet addImage:[UIImage imageNamed:@"recenter.png"]];
    [self presentViewController:m_slComposerSheet animated:YES completion:NULL];
  }
  else
  {
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Sorry!" message:@"You can't access Twitter right now. Make sure you have at least one Twitter account set up" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
  }
}

- (IBAction)Tweet:(id)sender
{
  [self onTweetRequest];
}

- (IBAction)ShareOnFacebook:(id)sender
{
  [self facebookShare];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                              sourceApplication:sourceApplication
                                fallbackHandler:^(FBAppCall *call) {
                                  NSLog(@"Unhandled deep link: %@", url);
                                  // Here goes the code to handle the links
                                  // Use the links to show a relevant view of your app to the user
                                }];
  
  return urlWasHandled;
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val =
    [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[kv[0]] = val;
  }
  return params;
}

-(void)  lastChanceShareAttempt//usefeed
{
  // Put together the dialog parameters
  NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"Test Name", @"name",
                                 @"Test Description", @"caption",
                                 @"Test Description2", @"description",
                                 @"https://developers.facebook.com/docs/ios/share/", @"link",
                                 @"http://i.imgur.com/g3Qc1HN.png", @"picture",
                                 nil];
  
  // Show the feed dialog
  [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                         parameters:params
                                            handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                              if (error)
                                              {
                                                // An error occurred, we need to handle the error
                                                // See: https://developers.facebook.com/docs/ios/errors
                                                NSString *pError=[NSString stringWithFormat:@"Error publishing story: %@", error.description];
                                                
                                                NSLog(@"%@",pError);
                                              }
                                              else
                                              {
                                                if (result == FBWebDialogResultDialogNotCompleted) {
                                                  // User cancelled.
                                                  NSLog(@"User cancelled.");
                                              }
                                              else
                                              {
                                                  // Handle the publish feed callback
                                                  NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                  if (![urlParams valueForKey:@"post_id"])
                                                  {
                                                    // User cancelled.
                                                    NSLog(@"User cancelled.");
                                                  }
                                                  else
                                                  {
                                                  // User clicked the Share button
                                                    NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                    NSLog(@"result %@", result);
                                                  }
                                                }
                                              }
                                            }];
}

@end
