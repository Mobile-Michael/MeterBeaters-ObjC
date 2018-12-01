//
//  SocialController.h
//  Practice3
//
//  Created by Mike on 3/5/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "social/social.h"
#import "accounts/accounts.h"

@interface SocialController : UIViewController
{
  SLComposeViewController *m_slComposerSheet;
  
}

@property (weak, nonatomic) IBOutlet UIButton *m_facebookPost;

-(IBAction)PostToFacebook  :(id)sender;
- (IBAction)Tweet:(id)sender;
- (IBAction)ShareOnFacebook:(id)sender;


@end
