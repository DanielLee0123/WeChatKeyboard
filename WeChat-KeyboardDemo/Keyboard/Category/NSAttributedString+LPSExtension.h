//
// Created by Daniel_Lee on 2018/6/26.
// Copyright (c) 2018 Daniel_Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSAttributedString (LPSExtension)
- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth;
- (CGSize)sizeWithMaxSize:(CGSize)maxSize;
@end
@interface NSMutableAttributedString (RRWid)

+ (instancetype)strWithFont:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                     string:(NSString *)string;

+ (instancetype)strWithFont:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                     string:(NSString *)string
                   maxWidth:(CGFloat)maxWidth;

+ (instancetype)strWithFont:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                     string:(NSString *)string
                    maxSize:(CGSize)maxSize;

// 根据情况设置行间距属性及字体属性，并计算最终大小
- (CGSize)sizewithFont:(UIFont *)font
             lineSpace:(CGFloat)lineSpace
              maxWidth:(CGFloat)maxWidth;

// 根据情况设置行间距属性及字体属性，并计算最终大小
- (CGSize)sizewithFont:(UIFont *)font
             lineSpace:(CGFloat)lineSpace
               maxSize:(CGSize)maxSize;

// 根据情况设置行间距属性及字体属性，并计算最终大小
// 若原来已设置了不同的font，则useFont= NO，maxFont只用于计算，不会覆盖设置
- (CGSize)sizeWithSpace:(CGFloat)lineSpace
                maxFont:(UIFont *)maxFont
                useFont:(BOOL)useFont
                maxSize:(CGSize)maxSize;

@end
