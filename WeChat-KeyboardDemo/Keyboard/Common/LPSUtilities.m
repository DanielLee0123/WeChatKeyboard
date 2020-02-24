//
//  LPSUtilities.m
//  LPSChatKeyboardDemo
//
//  Created by Daniel_Lee on 2019/8/12.
//  Copyright © 2019 Daniel_Lee. All rights reserved.
//

#import "LPSUtilities.h"

@implementation LPSUtilities

+ (UIViewController *_Nullable)getCurrentVC {
    UIViewController *result = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }

    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];


    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    UIViewController *vc = [self currentVCWithVC:result];

    return vc;
}

+ (UIViewController *)currentVCWithVC:(UIViewController *)vc {
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self currentVCWithVC:((UITabBarController *) vc).selectedViewController];
    }

    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self currentVCWithVC:((UINavigationController *) vc).visibleViewController];
    }

    return vc;
}

+ (BOOL)iPhoneX {
    
    GBDeviceInfo *info = [GBDeviceInfo deviceInfo];
    return (info.model == GBDeviceModeliPhoneX || info.model == GBDeviceModeliPhoneXR || info.model == GBDeviceModeliPhoneXS || info.model == GBDeviceModeliPhoneXSMax);
}

+ (BOOL)iPad
{
    GBDeviceInfo *info = [GBDeviceInfo deviceInfo];
    return info.family == GBDeviceFamilyiPad || info.family == GBDeviceFamilySimulator;
}

+ (CGFloat)layoutSafeBottom {
    if ([LPSUtilities iPhoneX]) {
        return kXTabBarSafeHeight;
    }
    return 0;
}

+ (CGFloat)layoutSafeTop {
    if ([LPSUtilities iPhoneX]) {
        return kXTopSafeHeight;
    }
    return 0;
}

@end
