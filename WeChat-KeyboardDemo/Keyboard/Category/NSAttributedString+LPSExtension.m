//
// Created by Daniel_Lee on 2018/6/26.
// Copyright (c) 2018 Daniel_Lee. All rights reserved.
//

#import "NSAttributedString+LPSExtension.h"


@implementation NSAttributedString (LPSExtension)
- (CGSize)sizeWithMaxWidth:(CGFloat)maxWidth
{
    return [self sizeWithMaxSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

- (CGSize)sizeWithMaxSize:(CGSize)maxSize
{
    CGSize textSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
}
@end
@implementation NSMutableAttributedString (RRWid)
+ (instancetype)strWithFont:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                     string:(NSString *)str
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str attributes:@{
            NSFontAttributeName: font,
            NSParagraphStyleAttributeName: paragraphStyle,
    }];

    return attributedString;
}

+ (instancetype)strWithFont:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                     string:(NSString *)string
                   maxWidth:(CGFloat)maxWidth

{
    return [self strWithFont:font lineSpace:lineSpace string:string maxSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

+ (instancetype)strWithFont:(UIFont *)font
                  lineSpace:(CGFloat)lineSpace
                     string:(NSString *)string
                    maxSize:(CGSize)maxSize

{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString sizeWithSpace:lineSpace maxFont:font useFont:YES maxSize:maxSize];

    return attributedString;
}

- (CGSize)sizewithFont:(UIFont *)font
             lineSpace:(CGFloat)lineSpace
              maxWidth:(CGFloat)maxWidth
{
    return [self sizeWithSpace:lineSpace maxFont:font useFont:YES maxSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
}

- (CGSize)sizewithFont:(UIFont *)font
             lineSpace:(CGFloat)lineSpace
               maxSize:(CGSize)maxSize
{
    return [self sizeWithSpace:lineSpace maxFont:font useFont:YES maxSize:maxSize];
}

// 已有AttributedString，已设置string
- (CGSize)sizeWithSpace:(CGFloat)lineSpace
                maxFont:(UIFont *)maxFont
                useFont:(BOOL)useFont
                maxSize:(CGSize)maxSize
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;

    if (!useFont) {
        [self addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle} range:NSMakeRange(0, self.length)];
    }
    else {
        [self addAttributes:@{
                NSFontAttributeName : maxFont,
                NSParagraphStyleAttributeName : paragraphStyle,
        } range:NSMakeRange(0, self.length)];
    }

    CGSize textSize = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    if (textSize.height < maxFont.lineHeight * 1.8 + lineSpace) {
        textSize.height = maxFont.lineHeight;

        [self removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, self.length)];
    }

    return CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
}
@end
