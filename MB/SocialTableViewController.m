//
//  SocialTableViewController.m
//  Practice3
//
//  Created by Mike on 3/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "SocialTableViewController.h"
#import "UIGlobals.h"
#import "UICommentsPage.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "font_changer.h"

@interface SocialTableViewController ()

@end

@implementation SocialTableViewController
@synthesize  m_btnFBPostIMage,m_btnTwitterTweetImage,m_btnComments;


typedef NS_ENUM(NSInteger, SocialRowType)
{
    ROW_TITLE_BAR,
    ROW_POST_ON_FACEBOOK,
    ROW_TWEET,
    ROW_COMMENT,
};


-(void) initColorScheme
{
    m_btnComments.layer.cornerRadius = 5;
    m_btnComments.layer.borderWidth = 1;
    m_btnComments.layer.borderColor = [UIGlobals ourDarkGray].CGColor;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    [self.m_btnTwitterTweetImage setImage: [UIImage imageNamed:@"Twitter44px"] forState:UIControlStateNormal];
    [self.m_btnFBPostIMage       setImage: [UIImage imageNamed:@"Facebook44px.png"] forState:UIControlStateNormal];
    
    self.tabBarController.title = @"Social";
    self.tableView.contentInset = UIEdgeInsetsMake(-15, 0, 0, 0);
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated
{
    self.tabBarController.title = @"More";
    [self initColorScheme];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setAllFonts:[UIFont fontWithName:@"AppleSDGothicNeo" size:36] bold: [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:36]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UIColor*) getColorForSocialCell : (NSInteger) index
{
    if(index == kTitleBar)
        return [UIGlobals getMainBackgroundColor];
    else
        return [UIGlobals ourLightGray];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIGlobals ourLightGray];
    return cell;
}


-(void) onPostToFacebookRequest
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        m_slComposerSheet = [[SLComposeViewController alloc] init];
        m_slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [m_slComposerSheet setInitialText:@"Try the Meter Beaters app"];
        [m_slComposerSheet addURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/meter-beaters/id866702252?ls=1&mt=8"]];
        [m_slComposerSheet addImage:[UIImage imageNamed:@"FBShareImage.png"]];
        [self presentViewController:m_slComposerSheet animated:YES completion:NULL];
        
        //FBShareDialog
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message: @"You can't access Facebook right now. Make sure you have at least one Facebook account set up." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"FB Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
    }
}
-(void) onTweetRequest
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        m_slComposerSheet = [[SLComposeViewController alloc] init];
        m_slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [m_slComposerSheet setInitialText:@"Find free parking in Chicago with the Meter Beaters App on ITunesStore.  @beatthemeters"];
        [self presentViewController:m_slComposerSheet animated:YES completion:NULL];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry!" message: @"You can't access Twitter right now. Make sure you have at least one Twitter account set up." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Dismiss", @"FB Fail Message" ) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController: alertController animated:YES completion:nil];
    }
}

- (IBAction)FBPostImageClicked:(id)sender
{
    [self onPostToFacebookRequest];
}

- (IBAction)TweetImageClicked:(id)sender
{
    [self onTweetRequest];
}

- (IBAction)feedBackClicked:(id)sender
{
    [self pushToCommentsView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.row)
    {
        case ROW_POST_ON_FACEBOOK:
        {
            [self onPostToFacebookRequest];
            break;
        }
        case ROW_TWEET:
        {
            [self onTweetRequest];
            break;
        }
        default:
            break;
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row )
    {
        case ROW_TITLE_BAR:
            return self.tableView.rowHeight;
        case ROW_POST_ON_FACEBOOK:
            return self.tableView.rowHeight;
        default:
            return 64.0f;
    }
}

-(void) pushToCommentsView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UICommentsPage *pComments = [storyboard instantiateViewControllerWithIdentifier:@"CommentsView"];
    
    pComments.m_pNavController = self.navigationController;
    
    [pComments setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:pComments animated:YES completion:nil];
    
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row )
    {
        case kAlertSetForRow:
        case ROW_COMMENT:
        case ROW_TWEET:
        case ROW_POST_ON_FACEBOOK:
            return NO;
        default:
            return YES;
    }
}



@end
