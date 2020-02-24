//
//  LPSChatMacros.h
//  WeChat-KeyboardDemo
//
//  Created by Daniel_Lee on 2020/2/24.
//  Copyright © 2020 Daniel_Lee. All rights reserved.
//

#ifndef LPSChatMacros_h
#define LPSChatMacros_h

//更多面板、表情键盘的高度
#define kChatBottomContentHeight      216
//表情、更多按钮宽度
#define kItemIconWidth  38
#define kBtnSpace  8
//输入框默认高度
#define kTextViewHeight     36

typedef NS_ENUM(NSInteger, LPSChatBarStatus)
{
    LPSChatBarStatusDefault,//初始状态，键盘未弹出
    LPSChatBarStatusFace,//表情键盘弹出状态
    LPSChatBarStatusMore,//更多面板弹出状态
    LPSChatBarStatusKeyboard,//键盘弹出状态
    LPSChatBarStatusRecord,//语音状态
};


#endif /* LPSChatMacros_h */
