//
//  SocialTableViewController.h
//  Practice3
//
//  Created by Mike on 3/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SocialTableViewController : UITableViewController<UIAlertViewDelegate>
{
    SLComposeViewController *m_slComposerSheet;
}

@property (weak, nonatomic) IBOutlet UIButton *m_btnFBPostIMage;
@property (weak, nonatomic) IBOutlet UIButton *m_btnTwitterTweetImage;
@property (weak, nonatomic) IBOutlet UIButton *m_btnComments;

- (IBAction)FBPostImageClicked:(id)sender;
- (IBAction)TweetImageClicked:(id)sender;
- (IBAction)feedBackClicked:(id)sender;

@end
