//
//  UIColor+RRIM.h
//  RRIM_Example
//
//  Created by Daniel_Lee on 2018/6/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (LPSExtension)

+ (UIColor *)lps_colorWithHexValue:(NSInteger)color alpha:(CGFloat)alpha;

+ (UIColor *)lps_colorWithHexValue:(NSInteger)color;

@end
