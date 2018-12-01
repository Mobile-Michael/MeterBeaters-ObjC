//
//  UICommentsPage.h
//  Practice3
//
//  Created by Mike on 2/26/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICommentsPage : UIViewController<UITextViewDelegate>

@property (nonatomic, weak)   UINavigationController *m_pNavController;
@property (weak, nonatomic)   IBOutlet UIButton *m_btnBack;
@property (weak, nonatomic)   IBOutlet UIButton *m_btnRateThisApp;
@property (strong, nonatomic) IBOutlet UIView *m_uiHeader;
@property (weak, nonatomic)   IBOutlet UITextView *m_tfComments;
@property (weak, nonatomic)   IBOutlet UIButton *m_btPostComment;
@property (weak, nonatomic)   IBOutlet UILabel *m_lbRemainingCHars;


- (IBAction)postFeedBackClicked:(id)sender;
- (IBAction)backClicked:(id)sender;
- (IBAction)RateThisApp:(id)sender;


@end
