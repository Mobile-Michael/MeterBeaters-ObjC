//
//  UIRegisterPage.h
//  Practice3
//
//  Created by Mike on 2/25/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIRegisterPage : UIViewController<UITextFieldDelegate>
{
    NSTimer *m_pTimer;
    BOOL m_bWaiting;
}

@property (weak, nonatomic) IBOutlet UITextField *m_tEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_tPassword;
@property (weak, nonatomic) IBOutlet UITextField *m_tPasswordConfirm;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRegisterDevice;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_uiActivity;

- (IBAction)RegisterClicked:(id)sender;
- (IBAction)BackClicked:(id)sender;

@end
