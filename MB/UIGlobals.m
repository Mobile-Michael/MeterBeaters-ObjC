//
//  UIGlobals.m
//  Practice3
//
//  Created by Mike on 3/15/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "UIGlobals.h"
#import "meterbeater.pch"
#import "ParkingSearchFilters.h"

static UIGlobals *sm_pInstance = nil;
@implementation UIGlobals

-(id) init
{
    self = [super init];
    if(self)
    {
        self->m_pSearchInputs = [[ParkingSearchFilters alloc] init];
    }
    
    return self;
}

+(ParkingSearchFilters*) getSearchFilters
{
    return [UIGlobals getInstance]->m_pSearchInputs;
}

+(UIColor*) getColorForRowParkingInput:(NSInteger)nRow : (BOOL) bOkayToMap
{
    UIColor *pColor      = [UIColor whiteColor];
    UIColor *pCellColors = [UIGlobals ourLightGray];
    switch(nRow)
    {
        case kStartTimeLabelRow:
        {
            pColor = pCellColors;
            break;
        }
        case kStartTimeDatePickerRow:
        {
            pColor = pCellColors;
            break;
        }
        case kEndTimeLabelRow:
        {
            pColor = pCellColors;
            break;
        }
        case kEndTimeDatePickerRow:
        {
            pColor = pCellColors;
            break;
        }
        case kQueryRow:
        {
            /*if(bOkayToMap)
             pColor=[UIColor greenColor];
             else
             pColor=[UIColor redColor];*/
            pColor = pCellColors;
            break;
        }
        case kStartHelperButtons:
        {
            pColor = pCellColors;
            break;
        }
        case kLocationRow:
        {
            pColor = pCellColors;
            break;
        }
        case kUseMyLocationRow:
        {
            pColor = pCellColors;
            break;
        }
        case kDistanceRow:
        {
            pColor = pCellColors;
            break;
        }
        case kDistancePlaceHolder:
        case kSpacer1:
        case kSpacer2:
        case kSpacer3:
        {
            pColor = [UIGlobals ourDarkGray];
            break;
        }
        case kHelperButtons:
        {
            pColor = pCellColors;
            break;
        }
        case kTitleBar:
        {
            pColor = [UIGlobals getMainBackgroundColor];
            break;
        }
        case kTypeOfParking:
        {
            pColor = [UIGlobals presetParkingType];
            break;
        }
        case kZoneRow:
        case kAlertSetForRow:
        case kAddressForSS:
        case kInfoTextForSS:
        case kDaysForSS:
        case kResetWardRow:
        case kDaysPlaceHolderText:
        {
            pColor = pCellColors;
            break;
        }
        default:
        {
            LogBeater(@"Unhandled row %ld",(long)nRow);
            break;
        }
    }
    
    return pColor;
}

+(UIColor*) getNavBarColor
{
    return [UIColor blackColor];
}

+(UIColor*) getNavBarTextColor
{
    return [UIColor whiteColor];
}

+(UIColor*) getMainBackgroundColor
{
    return [UIColor colorWithRed:202/255.0f green:252/255.0f blue:101/255.0f alpha:1.0f];
}

+(UIColor*) getMainBoldBackgroundColor
{
    return [UIColor colorWithRed:102/255.0f green:153/255.0f blue:51/255.0f alpha:1.0f];
}

+(UIColor*) ourDarkGray
{
    return [UIColor colorWithRed:202/255.0f green:200/255.0f blue:200/255.0f alpha:1.0f];
}

+(UIColor*) ourLightGray
{
    return [UIColor colorWithRed:229/255.0f green:230/255.0f blue:231/255.0f alpha:1.0f];
}

+(UIColor*) presetButtonGray
{
    return [UIColor colorWithRed:120/255.0f green:120/255.0f blue:120/255.0f alpha:1.0f];
}

+(UIColor*) presetParkingType
{
    return [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f];
}

+ (UIGlobals*) getInstance
{
    if( sm_pInstance == nil )
    {
        sm_pInstance = [[UIGlobals alloc] init];
    }
    
    return sm_pInstance;
}

+ (NSString *)uuid
{
    NSString *uuid = [[NSString alloc] init];
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    uuid = (__bridge NSString*)string;
    return uuid;
}

+(void) showOutRangeError:(UIViewController*)viewController
{
    NSString *pErrorString=[[NSString alloc]initWithFormat:@"Your search is outside of our covered area.  If you'd like a neighborhood added, please leave us a comment in the More section of the app. You can also leave feedback and see  a current list of areas at http://www.beatthemeters.com"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Out of Range!" message:  pErrorString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: NSLocalizedString( @"Dismiss", @"Dismiss OK button" ) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    if( viewController)
    {
        [viewController presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        while (topVC.presentedViewController)
        {
            topVC = topVC.presentedViewController;
        }
        
        if( topVC)
        {
            [topVC presentViewController: alertController animated: YES completion: nil];
        }
        
    }
}

+(void) saveEmail : (NSString *)pEmail
{
    [[NSUserDefaults standardUserDefaults] setObject: pEmail forKey: @"Email"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)  getEmail
{
    NSString *pReturn =  [[NSUserDefaults standardUserDefaults] objectForKey: @"email"];
    return pReturn;
}





@end
