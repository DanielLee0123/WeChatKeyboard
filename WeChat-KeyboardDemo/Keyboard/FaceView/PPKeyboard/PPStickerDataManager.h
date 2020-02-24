//
//  PPStickerDataManager.h
//  PPStickerKeyboard
//
//  Created by Vernon on 2018/1/17.
//  Copyright © 2018年 Vernon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PPSticker;

@interface PPStickerDataManager : NSObject

+ (instancetype _Nullable )sharedInstance;

/// 所有的表情包
@property (nonatomic, strong, readonly) NSArray<PPSticker *> * _Nullable allStickers;

/**
 *  处理字符串 如：/:065 -> [天使]
 */
- (NSString *_Nullable)stringByReplacingEmotionString:(NSString *_Nullable)string;
/**
 *  判断字符串中是否包含表情
 */
- (BOOL)isContainEmojiForString:(NSString *_Nullable)string;

/* 匹配给定attributedString中的所有emoji，如果匹配到的emoji有本地图片的话会直接换成本地的图片
 *
 * @param attributedString 可能包含表情包的attributedString
 * @param font 表情图片的对齐字体大小
 */
- (NSAttributedString *_Nullable)replaceEmojiForString:(NSString *_Nullable)string attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;

@end
