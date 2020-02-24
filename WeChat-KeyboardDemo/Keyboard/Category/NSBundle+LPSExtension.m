//
//  NSBundle+RRWid.m
//  TFYT
//
//  Created by Daniel_Lee on 2018/7/12.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "NSBundle+LPSExtension.h"

@implementation NSBundle (LPSExtension)
- (NSString *)rr_pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext
{
    NSBundle *resourceBundle = nil;
    NSURL *resourceBundleURL = [self URLForResource:@"WXOUIModuleResources" withExtension:@"bundle"];
    if (resourceBundleURL) {
        resourceBundle = [[NSBundle alloc] initWithURL:resourceBundleURL];
    }
    else {
        resourceBundle = self;
    }
    return [resourceBundle pathForResource:name ofType:ext];
    
}
@end
