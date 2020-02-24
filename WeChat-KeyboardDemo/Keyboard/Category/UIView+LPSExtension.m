//
//  UIView+RRIM.m
//  RRIM_Example
//
//  Created by Daniel_Lee on 2018/6/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "UIView+LPSExtension.h"

@implementation UIView (LPSExtension)

- (CGFloat)lps_left
{
    return self.frame.origin.x;
}

- (void)setLps_left:(CGFloat)lps_left
{
    CGRect frame = self.frame;
    frame.origin.x = lps_left;
    self.frame = frame;
}

- (CGFloat)lps_top
{
    return self.frame.origin.y;
}

- (void)setLps_top:(CGFloat)lps_top
{
    CGRect frame = self.frame;
    frame.origin.y = lps_top;
    self.frame = frame;
}

- (CGFloat)lps_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setLps_right:(CGFloat)lps_right
{
    CGRect frame = self.frame;
    frame.origin.x = lps_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)lps_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setLps_bottom:(CGFloat)lps_bottom
{
    CGRect frame = self.frame;
    frame.origin.y = lps_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)lps_centerX
{
    return self.center.x;
}

- (void)setLps_centerX:(CGFloat)lps_centerX
{
    self.center = CGPointMake(lps_centerX, self.center.y);
}

- (CGFloat)lps_centerY
{
    return self.center.y;
}

- (void)setLps_centerY:(CGFloat)lps_centerY
{
    self.center = CGPointMake(self.center.x, lps_centerY);
}

- (CGFloat)lps_width
{
    return self.frame.size.width;
}

- (void)setLps_width:(CGFloat)lps_width
{
    CGRect frame = self.frame;
    frame.size.width = lps_width;
    self.frame = frame;
}

- (CGFloat)lps_height
{
    return self.frame.size.height;
}

- (void)setLps_height:(CGFloat)lps_height
{
    CGRect frame = self.frame;
    frame.size.height = lps_height;
    self.frame = frame;
}

- (CGPoint)lps_origin
{
    return self.frame.origin;
}

- (void)setLps_origin:(CGPoint)lps_origin
{
    CGRect frame = self.frame;
    frame.origin = lps_origin;
    self.frame = frame;
}

- (CGSize)lps_size
{
    return self.frame.size;
}

- (void)setLps_size:(CGSize)lps_size
{
    CGRect frame = self.frame;
    frame.size = lps_size;
    self.frame = frame;
}

@end
