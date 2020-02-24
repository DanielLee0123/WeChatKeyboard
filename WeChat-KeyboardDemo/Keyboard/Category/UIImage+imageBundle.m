//
//  UIImage+imageBundle.m
//  RRIM_Example
//
//  Created by Daniel_Lee on 2018/6/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "UIImage+imageBundle.h"

@implementation UIImage (imageBundle)
+(instancetype)im_imageWithBundleName:(NSString *)name
{

    NSBundle *resourceBundle = nil;
    NSBundle *classBundle = [NSBundle mainBundle];
    NSURL *resourceBundleURL = [classBundle URLForResource:@"IMResource" withExtension:@"bundle"];
    if (resourceBundleURL) {
        resourceBundle = [[NSBundle alloc] initWithURL:resourceBundleURL];
    }
    else {
        resourceBundle = classBundle;
    }

    NSString *imagePath = [resourceBundle pathForResource:name ofType:@"png"];
    if (!imagePath) {
        name = [name stringByAppendingString:@"@2x"];
        imagePath = [resourceBundle pathForResource:name ofType:@"png"];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        return image;
    }
    return nil;
}
+(instancetype)im_imageWithFaceBundleName:(NSString *)name;
{
    NSBundle *classBundle = [NSBundle mainBundle];
    NSURL *faceURL = [classBundle URLForResource:@"WXOUIModuleResources" withExtension:@"bundle"];
    
    NSBundle *faceBundle = [[NSBundle alloc] initWithURL:faceURL];
    

    NSString *imagePath = [faceBundle pathForResource:name ofType:@"png"];
    if (!imagePath) {
        name = [name stringByAppendingString:@"@2x"];
        imagePath = [faceBundle pathForResource:name ofType:@"png"];
    }
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        return image;
    }
    return nil;
}
@end
