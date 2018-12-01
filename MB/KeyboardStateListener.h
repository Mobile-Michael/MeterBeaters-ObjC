//
//  UIKeyboardListener.h
//  Practice3
//
//  Created by Mike on 2/22/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardStateListener : NSObject
{
    BOOL _isVisible;
}
+ (KeyboardStateListener*) sharedInstance;

@property (nonatomic,readonly,getter = isVisible) BOOL visible;

@end
