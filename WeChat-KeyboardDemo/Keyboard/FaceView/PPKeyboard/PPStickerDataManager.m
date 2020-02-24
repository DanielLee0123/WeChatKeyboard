//
//  PPStickerDataManager.m
//  PPStickerKeyboard
//
//  Created by Vernon on 2018/1/17.
//  Copyright © 2018年 Vernon. All rights reserved.
//

#import "PPStickerDataManager.h"
#import "PPSticker.h"
#import "PPUtil.h"
#import "UIImage+imageBundle.h"
#import "NSBundle+LPSExtension.h"
#import "YYText.h"

@interface PPStickerMatchingResult : NSObject
@property (nonatomic, assign) NSRange range;                    // 匹配到的表情包文本的range
@property (nonatomic, strong) UIImage *emojiImage;              // 如果能在本地找到emoji的图片，则此值不为空
@property (nonatomic, strong) NSString *showingDescription;     // 表情的实际文本(形如：[哈哈])，不为空
@property (nonatomic, strong) NSString *imagePath;
@end

@implementation PPStickerMatchingResult
@end

@interface PPStickerDataManager ()
@property (nonatomic, strong, readwrite) NSArray<PPSticker *> *allStickers;
@property (nonatomic, strong) NSString *pattern;
@end

@implementation PPStickerDataManager

+ (instancetype)sharedInstance
{
    static PPStickerDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PPStickerDataManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initStickers];
    }
    return self;
}

- (void)initStickers
{
    NSString *path = [NSBundle.mainBundle rr_pathForResource:@"EmoticonInfo" ofType:@"plist"];
    if (!path) {
        return;
    }
    
    NSURL *faceURL = [[NSBundle mainBundle] URLForResource:@"WXOUIModuleResources" withExtension:@"bundle"];
    NSBundle *faceBundle = [[NSBundle alloc] initWithURL:faceURL];
    
    NSMutableArray<PPSticker *> *stickers = [[NSMutableArray alloc] init];
    self.pattern = [NSString string];
    PPSticker *sticker = [[PPSticker alloc] init];
    sticker.coverImageName = @"face_w";
    NSMutableArray<PPEmoji *> *emojis = [[NSMutableArray alloc] init];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *keys = [dic allKeys];
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        NSArray *array = dic[key];
        NSString *replacing = [NSString stringWithFormat:@"[%@]", [array firstObject]];
        PPEmoji *emoji = [[PPEmoji alloc] init];
        emoji.imageName = key;
        NSString *imagePath = [faceBundle pathForResource:[NSString stringWithFormat:@"%@@2x", emoji.imageName] ofType:@"png"];
        emoji.image = [UIImage imageWithContentsOfFile:imagePath];
        emoji.emojiDescription = replacing;
        [emojis addObject:emoji];
        if (i == keys.count - 1) {
            self.pattern = [self.pattern stringByAppendingString:[NSString stringWithFormat:@"\\[%@\\]", [array firstObject]]];
        } else {
            self.pattern = [self.pattern stringByAppendingString:[NSString stringWithFormat:@"\\[%@\\]|", [array firstObject]]];
        }
    }
    //按图片名称排序，001···099
    NSArray *result = [emojis sortedArrayUsingComparator:^NSComparisonResult(PPEmoji *  _Nonnull obj1, PPEmoji*  _Nonnull obj2) {
        return [obj1.imageName compare:obj2.imageName];
    }];
    sticker.emojis = result;
    [stickers addObject:sticker];
    self.allStickers = stickers;
}

#pragma mark - public method

- (BOOL)isContainEmojiForString:(NSString *)string
{
    if (!string || !string.length) {
        return NO;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.pattern options:0 error:NULL];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (results && results.count) {
        for (NSTextCheckingResult *result in results) {
            NSString *showingDescription = [string substringWithRange:result.range];
//            NSString *emojiSubString = [showingDescription substringFromIndex:1];       // 去掉[
//            emojiSubString = [emojiSubString substringWithRange:NSMakeRange(0, emojiSubString.length - 1)];    // 去掉]
            PPEmoji *emoji = [self emojiWithEmojiDescription:showingDescription];
            return emoji ? YES : NO;
        }
    }
    
    return NO;
}

- (NSString *)stringByReplacingEmotionString:(NSString *)string {
    NSString *path = [NSBundle.mainBundle rr_pathForResource:@"EmoticonInfo" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSArray *keys = [dic allKeys];
    NSArray *tmpArr = [NSArray array];
    for (int i = 0; i < keys.count; i++) {
        NSString *key = keys[i];
        NSArray *array = dic[key];
        NSString *replacing = [NSString stringWithFormat:@"[%@]", [array firstObject]];
        // /:O=O -> 老大  /:O -> 惊愕 防止匹配出错，做特殊处理
        if ([[array lastObject] isEqualToString:@"/:O"]) {
            tmpArr = array;
            continue;
        } else {
            string = [string stringByReplacingOccurrencesOfString:[array lastObject] withString:replacing];
        }
    }
    if ([string containsString:@"/:O"]) {
        NSString *replacing = [NSString stringWithFormat:@"[%@]", [tmpArr firstObject]];
        string = [string stringByReplacingOccurrencesOfString:[tmpArr lastObject] withString:replacing];
    }
    
    return string;
}

- (NSAttributedString *)replaceEmojiForString:(NSString *)string attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs
{
    if (!string || !string.length) {
        return nil;
    }
    // 处理成 [微笑] 格式字符串
    string = [self stringByReplacingEmotionString:string];
    
    UIFont *font = [UIFont systemFontOfSize:16];
    if (attrs.count) {
        if ([[attrs allKeys] containsObject:NSFontAttributeName]) {
            font = attrs[NSFontAttributeName];
        }
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
    attributedString.yy_font = font;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.pattern options:0 error:NULL];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    if (results && results.count) {
        NSUInteger offset = 0;
        for (PPStickerMatchingResult *result in results) {
            NSString *showingDescription = [string substringWithRange:result.range];
            PPEmoji *emoji = [self emojiWithEmojiDescription:showingDescription];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:emoji.image];
            imageView.lps_size = CGSizeMake(font.lineHeight+3, font.lineHeight+3);
            NSMutableAttributedString *emojiAttributedString = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.lps_size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            if (!emojiAttributedString) {
                continue;
            }
            NSRange actualRange = NSMakeRange(result.range.location - offset, showingDescription.length);
            [attributedString replaceCharactersInRange:actualRange withAttributedString:emojiAttributedString];
            offset += showingDescription.length - emojiAttributedString.length;
        }
    }
    return attributedString;
}

#pragma mark - private method

- (PPEmoji *)emojiWithEmojiDescription:(NSString *)emojiDescription
{
    for (PPSticker *sticker in self.allStickers) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"emojiDescription == %@", emojiDescription];
        NSArray *deleteArray = [sticker.emojis filteredArrayUsingPredicate:predicate];
        if (deleteArray.count > 0) {
            return deleteArray.firstObject;
        }
    }
    return nil;
}

@end
