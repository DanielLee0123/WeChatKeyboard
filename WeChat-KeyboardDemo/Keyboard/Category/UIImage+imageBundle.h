//
//  UIImage+imageBundle.h
//  RRIM_Example
//
//  Created by Daniel_Lee on 2018/6/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (imageBundle)
+(instancetype)im_imageWithBundleName:(NSString *)name;
+(instancetype)im_imageWithFaceBundleName:(NSString *)name;
@end
