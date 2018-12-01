//
//  UIKeyboardListener.m
//  Practice3
//
//  Created by Mike on 2/22/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "KeyboardStateListener.h"

static KeyboardStateListener *sharedInstance=nil;

@implementation KeyboardStateListener

+ (KeyboardStateListener*) sharedInstance
{
    if(sharedInstance== nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (BOOL)isVisible
{
    return _isVisible;
}

- (void)didShow
{
    _isVisible = YES;
}

- (void)didHide
{
    _isVisible = NO;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}


@end
