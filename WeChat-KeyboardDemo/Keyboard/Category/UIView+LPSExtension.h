//
//  UIView+RRIM.h
//  RRIM_Example
//
//  Created by Daniel_Lee on 2018/6/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LPSExtension)

@property (nonatomic) CGFloat lps_left;          ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat lps_top;           ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat lps_right;         ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat lps_bottom;        ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat lps_width;         ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat lps_height;        ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat lps_centerX;       ///< Shortcut for center.x
@property (nonatomic) CGFloat lps_centerY;       ///< Shortcut for center.y
@property (nonatomic) CGPoint lps_origin;        ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  lps_size;          ///< Shortcut for frame.size.

@end
