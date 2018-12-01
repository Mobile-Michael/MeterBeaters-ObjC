//
//  font_changer.m
//  MeterBeaters
//
//  Created by Mike Mullin on 11/25/18.
//  Copyright © 2018 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "font_changer.h"
@implementation UIView (FontChanger)

//this was "borrowed" from stack overflow
- (void)setAllFonts:(UIFont*)regular bold:(UIFont*)bold
{
    if ([self respondsToSelector:@selector(setFont:)]) {
        UIFont *oldFont = [self valueForKey:@"font"];
        
        UIFont *newFont;
        // for iOS6
        NSRange isBold = [[oldFont fontName] rangeOfString:@"Bold" options:NSCaseInsensitiveSearch];
        // for iOS7 (is device owner didn't change it!)
        NSRange isMedium = [[oldFont fontName] rangeOfString:@"MediumP4" options:NSCaseInsensitiveSearch];
        if (isBold.location==NSNotFound && isMedium.location==NSNotFound) {
            newFont = [regular fontWithSize:oldFont.pointSize];
        } else {
            newFont = [bold fontWithSize:oldFont.pointSize];
        }
        
        // TODO: there are italic fonts also though
        
        [self setValue:newFont forKey:@"font"];
    }
    
    for (UIView *subview in self.subviews) {
        [subview setAllFonts:regular bold:bold];
    }
}

@end
