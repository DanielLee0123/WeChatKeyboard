//
//  LPSChatKeyboardDelegate.h
//  WeChat-KeyboardDemo
//
//  Created by Daniel_Lee on 2020/2/24.
//  Copyright © 2020 Daniel_Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class LPSChatKeyBoard;
@protocol LPSChatKeyboardDelegate <NSObject>

@optional
/**
 *  输入框高度改变
 */
- (void)changeStateKeyboard:(CGFloat)chatKeyboardY;
/**
 *  发送输入框中的文字
 */
- (void)stickerInputViewDidClickSendButton:(LPSChatKeyBoard *_Nullable)inputView;

@end

NS_ASSUME_NONNULL_END
