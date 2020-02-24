//
//  LPSChatKeyBoard.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/18.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSMorePanelItem.h"
#import "LPSVoiceRecordDefine.h"
#import "LPSChatMacros.h"
#import "PPStickerTextView.h"
#import "LPSChatKeyboardDelegate.h"

static const CGFloat kLPSChatToolBarHeight = 49.0f;

@interface LPSChatKeyBoard : UIView

/**
 * 键盘收起
 */
- (void)hideKeyBoard;
/**
 * 弹出键盘
 */
- (void)showKeyBoard;

@property (nonatomic, weak) id<LPSChatKeyboardDelegate> _Nullable delegate;
@property (nonatomic, assign) NSInteger maxVisibleLine;
@property (nonatomic, assign) BOOL isDisappear;
@property (nonatomic, assign) CGFloat offset;//y坐标偏移量
@property (nonatomic, strong, readonly) NSString * _Nullable plainText;//获取输入框中的文字
@property (nonatomic, strong, readonly) NSAttributedString * _Nullable attributedText;//获取输入框中的富文本
@property (nonatomic, strong) NSAttributedString * _Nullable attriDraft;    //草稿属性化文字
@property (nonatomic, strong, readonly) PPStickerTextView * _Nullable textView;
@property (nonatomic, assign, readonly) LPSChatBarStatus status;
@property (nonatomic, assign) BOOL isDisableLeftPlugin;//是否禁用左侧按钮

- (void)keyboardStateChanged:(void(^_Nullable)(LPSChatBarStatus state))keyboardBlock;

/**
 *  添加更多面板的按钮
 */
- (void)addMoreItemWithTitle:(NSString *_Nullable)title imageName:(NSString *_Nullable)imageName handler:(void(^_Nullable)(void))handler;
/**
 *  添加输入框左侧按钮，左侧只可以添加一个按钮
 */
- (void)addLeftPluginViewWithButton:(UIButton *_Nullable)button handler:(void(^_Nullable)(void))handler;
/**
 *  在更多面板上添加视图
 */
- (void)addMorePanelContentView:(UIView *_Nullable)plugin;

- (void)textViewDidChange:(UITextView *_Nullable)textView;

@end
