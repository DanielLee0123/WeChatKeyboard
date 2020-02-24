//
//  LPSChatKeyBoard.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/18.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSChatKeyBoard.h"
#import "LPSMorePanelView.h"
#import "PPStickerKeyboard.h"
#import "PPUtil.h"
#import "LPSRecordButton.h"
#import "PPStickerDataManager.h"
#import "LPSAudioPlayer.h"
#import "LPSSoundRecorder.h"
#import "UIView+LPSExtension.h"
#import "LPSUtilities.h"
#import <YYKeyboardManager/YYKeyboardManager.h>
#import "LPSVoiceRecordControl.h"

const CGFloat kMoreViewHeight = 216;
const CGFloat kFaceViewHeight = 216;

#define kItemIconWidth  38
#define kBtnSpace  8
#define kFakeTimerDuration       1
#define kMaxRecordDuration       60     //最长录音时长
#define kRemainCountingDuration  10     //剩余多少秒开始倒计时

#define kTextViewHeight     36
#define kTextViewOriginY    (kLPSChatToolBarHeight - kTextViewHeight) / 2

@interface LPSChatKeyBoard ()<UITextViewDelegate,PPStickerKeyboardDelegate,YYKeyboardObserver>

@property (nonatomic, strong) UIView *topContainer;//上侧容器
@property (nonatomic, strong) UIView *bottomCotainer;//下方容器

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIButton *faceBtn;
@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong, readwrite) UIButton *moreBtn;
@property (nonatomic, strong) PPStickerTextView *textView;
@property (nonatomic, strong) LPSMorePanelView *moreView;
@property (nonatomic, strong) PPStickerKeyboard *faceView;
@property (nonatomic, strong) LPSRecordButton *talkBtn;

@property (nonatomic, assign) CGFloat keyboardY;
@property (nonatomic, assign, readwrite) LPSChatBarStatus status;
@property (nonatomic, copy) void (^leftActionBlock)(void);
@property (nonatomic, strong) UIButton *leftPluginButton;
@property (nonatomic, copy) void (^keyboardBlock)(LPSChatBarStatus status);

@property (nonatomic, strong) LPSVoiceRecordControl *voiceRecordCtrl;
@property (nonatomic, assign) LPSVoiceRecordState currentRecordState;
@property (nonatomic, strong) NSTimer *fakeTimer;
@property (nonatomic, assign) float duration;

@end

@implementation LPSChatKeyBoard

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lps_colorWithHexValue:0xffffff];
        self.maxVisibleLine = 5;
        self.status = LPSChatBarStatusDefault;
        [self.textView resignFirstResponder];
        [self setUpUI];
        [self addNotification];
    }

    return self;
}

#pragma mark---添加子视图---
- (void)setUpUI {
    [self addSubview:self.topContainer];
    [self addSubview:self.bottomCotainer];
    [self.topContainer addSubview:self.topLine];
    [self.topContainer addSubview:self.faceBtn];
    [self.topContainer addSubview:self.moreBtn];
    [self.topContainer addSubview:self.textView];
    [self.topContainer addSubview:self.voiceBtn];
    [self.topContainer addSubview:self.talkBtn];
}

- (void)hideKeyBoard {
    self.status = LPSChatBarStatusDefault;
    [self.textView resignFirstResponder];
}
- (void)showKeyBoard {
    self.status = LPSChatBarStatusKeyboard;
    [self.textView becomeFirstResponder];
}

-(void)setAttriDraft:(NSAttributedString *)attriDraft
{
    _attriDraft = attriDraft;
    if (attriDraft.length > 0) {
        self.textView.attributedText = attriDraft;
        self.status = LPSChatBarStatusKeyboard;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textView becomeFirstResponder];
        });
        [self textViewDidChange:self.textView];
    }
}

- (void)addMoreItemWithTitle:(NSString *)title imageName:(NSString *)imageName handler:(void(^)(void))handler {
    LPSMorePanelItem *item = [LPSMorePanelItem createMoreItemWithTitle:title imageName:imageName handler:handler];
    [self.moreView addMoreItem:item];
}
- (void)addMorePanelContentView:(UIView *)plugin {
    [self.moreView addMoreContentView:plugin];
}
- (void)addLeftPluginViewWithButton:(UIButton *)button handler:(void(^)(void))handler {
    if (button != nil && !self.isDisableLeftPlugin) {
        _leftActionBlock = handler;
        self.leftPluginButton = button;
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [button addTarget:self action:@selector(leftPluginViewClicked) forControlEvents:UIControlEventTouchUpInside];
        if (self.leftPluginButton.superview) {
            [self.leftPluginButton removeFromSuperview];
        }
        [self.topContainer addSubview:self.leftPluginButton];
    }
    [self layoutSubViewFrame];
}

- (void)setIsDisableLeftPlugin:(BOOL)isDisableLeftPlugin {
    _isDisableLeftPlugin = isDisableLeftPlugin;
    if (isDisableLeftPlugin) {
        [self layoutSubViewFrame];
    }
}

- (void)keyboardStateChanged:(void(^)(LPSChatBarStatus status))keyboardBlock {
    _keyboardBlock = keyboardBlock;
}

- (NSString *)plainText {
    return self.textView.text;
}

- (NSAttributedString *)attributedText {
    return self.textView.attributedText;
}

#pragma mark---UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.status = LPSChatBarStatusKeyboard;
    [self p_reloadTextView];
}

- (void)textViewDidChange:(UITextView *)textView {
//    [self.textView scrollRangeToVisible:self.textView.selectedRange];
    [self p_reloadTextView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendCurrentText];
        [self textViewDidChange:self.textView];
        return NO;
    }

    return YES;
}

- (void)sendCurrentText {
    if (self.textView.text.length > 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(stickerInputViewDidClickSendButton:)]) {
            [self.delegate stickerInputViewDidClickSendButton:self];
        }
    }
    self.textView.text = @"";
}

- (void)p_reloadTextView {
    CGFloat textviewH = ceilf([self.textView sizeThatFits:self.textView.frame.size].height);
    CGFloat maxHeight = ceil(self.textView.font.lineHeight * (self.maxVisibleLine - 1) + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom);
    if (textviewH < kTextViewHeight) {
        textviewH = kTextViewHeight;
    }
    self.textView.scrollEnabled = textviewH >= maxHeight && maxHeight > 0;
    if (self.textView.scrollEnabled) {
        textviewH = 0+maxHeight;
    }
    
    __block CGFloat totalH = 0;
    if (self.status == LPSChatBarStatusFace || self.status == LPSChatBarStatusMore) {
        [UIView animateWithDuration:.25 animations:^{
            totalH = textviewH + kTextViewOriginY * 2 + kChatBottomContentHeight + [LPSUtilities layoutSafeBottom];
            if (self->_keyboardY == 0) {
                self->_keyboardY = ScreenHeight - self.offset;
            }
            self.lps_top = ScreenHeight - self.offset - totalH;
            self.lps_height = totalH;

            self.topContainer.lps_height = textviewH + kTextViewOriginY *2;
            self.bottomCotainer.lps_top = self.topContainer.lps_height;
            self.textView.lps_top = kTextViewOriginY;
            self.textView.lps_height = textviewH;

            self.leftPluginButton.lps_top = self.moreBtn.lps_top = self.faceBtn.lps_top = totalH - kTextViewOriginY- kItemIconWidth-kChatBottomContentHeight - [LPSUtilities layoutSafeBottom];
        }];
    } else {
        [UIView animateWithDuration:.25 animations:^{
            totalH = textviewH + kTextViewOriginY * 2;
            if (self->_keyboardY == 0 || ![YYKeyboardManager defaultManager].keyboardVisible) {
                self->_keyboardY = ScreenHeight - self.offset - [LPSUtilities layoutSafeBottom];
            }
            self.lps_top = self->_keyboardY - totalH;
            self.lps_height = totalH;
            self.topContainer.lps_height = totalH;

            self.textView.lps_top = kTextViewOriginY;
            self.textView.lps_height = textviewH;
            self.bottomCotainer.lps_top = self.topContainer.lps_height;

            self.leftPluginButton.lps_top = self.moreBtn.lps_top = self.faceBtn.lps_top = totalH - kTextViewOriginY- kItemIconWidth;
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(changeStateKeyboard:)]) {
        [self.delegate changeStateKeyboard:self.lps_top];
    }

    [self.textView scrollRangeToVisible:NSMakeRange(0, self.textView.text.length)];
}

#pragma mark action

- (void)leftPluginViewClicked {
    if (self.leftActionBlock) {
        self.leftActionBlock();
    }
}

- (void)onVoiceBtnClick:(UIButton *)button{
    button.selected = !button.selected;
    [self.voiceBtn setImage:[UIImage imageNamed:button.selected ? @"keyboard_pressed" : @"voice_pressed"] forState:UIControlStateHighlighted];
    self.status = (button.selected ? LPSChatBarStatusRecord : LPSChatBarStatusKeyboard);
}

- (void)onFaceBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    self.moreBtn.selected = NO;
    if (!self.faceView.superview) {
        [self.bottomCotainer addSubview:self.faceView];
    }
    self.status = (button.selected ? LPSChatBarStatusFace : LPSChatBarStatusKeyboard);
    if (self.status == LPSChatBarStatusKeyboard){
        [self.textView becomeFirstResponder];
    } else{
        if (self.textView.isFirstResponder) {
            [self.textView resignFirstResponder];
        }
    }
}

- (void)onMoreBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    self.faceBtn.selected = NO;
    if (!self.moreView.superview) {
        [self.bottomCotainer addSubview:self.moreView];
    }
    self.status = (button.selected ? LPSChatBarStatusMore : LPSChatBarStatusKeyboard);
    if (self.status == LPSChatBarStatusKeyboard){
        [self.textView becomeFirstResponder];
    } else{
        if (self.textView.isFirstResponder) {
            [self.textView resignFirstResponder];
        }
    }
}

- (void)refreshMoreView:(LPSChatBarStatus)status {
    if (status != LPSChatBarStatusMore) {
        [self.moreView removeMoreContentView];
    }
}

- (void)setStatus:(LPSChatBarStatus)status {
    if (_status == status) {
        return;
    }
    _status = status;
    [self refreshMoreView:status];
    switch (status) {
        case LPSChatBarStatusDefault:
        {
            self.faceView.hidden = self.moreView.hidden = YES;
            self.faceBtn.selected = self.moreBtn.selected = self.voiceBtn.selected = NO;
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = CGRectMake(0, ScreenHeight - self.offset - (self.textView.lps_height+2*kTextViewOriginY) - [LPSUtilities layoutSafeBottom], ScreenWidth, self.lps_height);
            }];
        }
            break;
        case LPSChatBarStatusRecord:
        {
            self.talkBtn.hidden = NO;
            if (_faceView.superview) {
                self.faceView.hidden = YES;
            }
            self.moreView.hidden = YES;
            if ([self.textView isFirstResponder]) {
                [self.textView resignFirstResponder];
            }
            self.textView.hidden = YES;
            [UIView animateWithDuration:0.2 animations:^{
                [self voiceResetFrame];
            }];
        }
            break;
        case LPSChatBarStatusKeyboard:
        {
            self.moreView.hidden = self.faceView.hidden = self.talkBtn.hidden = YES;
            self.textView.hidden = NO;
            self.faceBtn.selected = self.moreBtn.selected = self.voiceBtn.selected = NO;
        }
            break;
        case LPSChatBarStatusFace:
        {
            self.moreView.hidden = self.talkBtn.hidden = YES;
            self.faceView.hidden = NO;
            self.voiceBtn.selected = NO;
            [UIView animateWithDuration:.25 animations:^{
                self.lps_height = self.textView.lps_height+2 *kTextViewOriginY + kChatBottomContentHeight + [LPSUtilities layoutSafeBottom];
                self.lps_top = ScreenHeight - self.offset - self.lps_height;
                self.bottomCotainer.lps_top = self.textView.lps_height + 2 * kTextViewOriginY;
            }];
        }
            break;
        case LPSChatBarStatusMore:
        {
            self.voiceBtn.selected = NO;
            self.moreView.hidden = NO;
            self.faceView.hidden = self.talkBtn.hidden = YES;
            [UIView animateWithDuration:.25 animations:^{
                self.lps_height = self.textView.lps_height+2*kTextViewOriginY + kChatBottomContentHeight + [LPSUtilities layoutSafeBottom];
                self.lps_top = ScreenHeight - self.offset - self.lps_height;
                self.bottomCotainer.lps_top = self.textView.lps_height + 2 * kTextViewOriginY;
            }];
        }
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(changeStateKeyboard:)]) {
        [self.delegate changeStateKeyboard:self.lps_top];
    }
    if (self.keyboardBlock) {
        self.keyboardBlock(status);
    }
}

#pragma mark - record

- (void)onClickRecordTouchDown:(UIButton *)button
{
    NSLog(@"开始录音");
    self.currentRecordState = LPSVoiceRecordStateRecording;
    [self dispatchVoiceState];
}

- (void)onClickRecordTouchUpInside:(UIButton *)button
{
    NSLog(@"完成录音");
    if (self.currentRecordState == LPSVoiceRecordStateNormal) {
        return;
    }
    if (self.duration < 2) {
        [self.voiceRecordCtrl showToast:@"说话时间太短" complete:nil];
    }
    self.currentRecordState = LPSVoiceRecordStateNormal;
    [self dispatchVoiceState];
}

- (void)onClickRecordTouchUpOutside:(UIButton *)button
{
    NSLog(@"取消录音");
    self.currentRecordState = LPSVoiceRecordStateNormal;
    [self dispatchVoiceState];
}

- (void)onClickRecordTouchDragEnter:(UIButton *)button
{
    NSLog(@"继续录音");
    self.currentRecordState = LPSVoiceRecordStateRecording;
    [self dispatchVoiceState];
}

- (void)onClickRecordTouchDragExit:(UIButton *)button
{
    NSLog(@"将要取消录音");
    self.currentRecordState = LPSVoiceRecordStateReleaseToCancel;
    [self dispatchVoiceState];
}

- (void)startFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
    self.fakeTimer = [NSTimer scheduledTimerWithTimeInterval:kFakeTimerDuration target:self selector:@selector(onFakeTimerTimeOut) userInfo:nil repeats:YES];
    [_fakeTimer fire];
}

- (void)stopFakeTimer
{
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
}

- (void)onFakeTimerTimeOut
{
    self.duration += kFakeTimerDuration;
    NSLog(@"+++duration+++ %f",self.duration);
    float remainTime = kMaxRecordDuration-self.duration;
    if ((int)remainTime == 0) {
        self.currentRecordState = LPSVoiceRecordStateNormal;
        [self dispatchVoiceState];
    }
    else if ([self shouldShowCounting]) {
        self.currentRecordState = LPSVoiceRecordStateRecordCounting;
        [self dispatchVoiceState];
        [self.voiceRecordCtrl showRecordCounting:remainTime];
    }
    else
    {
        float fakePower = (float)(1+arc4random()%99)/100;
        NSLog(@"----->%f",fakePower);
        [self.voiceRecordCtrl updatePower:fakePower];
    }
}

- (BOOL)shouldShowCounting
{
    if (self.duration >= (kMaxRecordDuration-kRemainCountingDuration) && self.duration < kMaxRecordDuration && self.currentRecordState != LPSVoiceRecordStateReleaseToCancel) {
        return YES;
    }
    return NO;
}

- (void)resetState
{
    [self stopFakeTimer];
    self.duration = 0;
}

- (void)dispatchVoiceState
{
    if (_currentRecordState == LPSVoiceRecordStateRecording) {
        [self startFakeTimer];
    }
    else if (_currentRecordState == LPSVoiceRecordStateNormal)
    {
        [self resetState];
    }
    [self.talkBtn updateRecordButtonStyle:_currentRecordState];
    [self.voiceRecordCtrl updateUIWithRecordState:_currentRecordState];
}

- (LPSVoiceRecordControl *)voiceRecordCtrl
{
    if (!_voiceRecordCtrl) {
        _voiceRecordCtrl = [LPSVoiceRecordControl new];
    }
    return _voiceRecordCtrl;
}


- (void)layoutSubViewFrame {
    if (self.isDisableLeftPlugin) {
        self.textView.frame = CGRectMake(kBtnSpace, kTextViewOriginY, ScreenWidth - 2 * kItemIconWidth - 2*kBtnSpace, kTextViewHeight);
        self.faceBtn.frame = CGRectMake(ScreenWidth - 2*kItemIconWidth - kBtnSpace, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
        self.moreBtn.frame = CGRectMake(ScreenWidth - kItemIconWidth - kBtnSpace, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
    } else {
        CGSize leftPluginSize = self.leftPluginButton.lps_size;
        self.leftPluginButton.frame = CGRectMake(kBtnSpace, (kLPSChatToolBarHeight - leftPluginSize.height)/2, leftPluginSize.width, leftPluginSize.height);
        self.textView.frame = CGRectMake(2*kBtnSpace+leftPluginSize.width, kTextViewOriginY, ScreenWidth - leftPluginSize.width - 2 * kItemIconWidth - 4 *kBtnSpace, kTextViewHeight);
        self.faceBtn.frame = CGRectMake(ScreenWidth - 2*kItemIconWidth - kBtnSpace, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
        self.moreBtn.frame = CGRectMake(ScreenWidth - kItemIconWidth - kBtnSpace, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
    }
}

- (void)voiceResetFrame
{
    self.frame = CGRectMake(0, ScreenHeight - kLPSChatToolBarHeight - [LPSUtilities layoutSafeBottom], ScreenWidth, kLPSChatToolBarHeight);
    self.talkBtn.frame = CGRectMake(kItemIconWidth + kBtnSpace, kTextViewOriginY, ScreenWidth -3 * kItemIconWidth - 2 *kBtnSpace, kTextViewHeight);
    self.voiceBtn.frame = CGRectMake(0, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
    self.faceBtn.frame = CGRectMake(ScreenWidth -2 *kItemIconWidth, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
    self.moreBtn.frame = CGRectMake(ScreenWidth - kItemIconWidth, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth);
}

#pragma mark--键盘通知---
- (void)addNotification {
    [[YYKeyboardManager defaultManager] addObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (!_isDisappear) {
        if (self.status == LPSChatBarStatusKeyboard) {
            [self p_reloadTextView];
        } else {
            self.status = LPSChatBarStatusKeyboard;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!_isDisappear && self.status == LPSChatBarStatusKeyboard) {
        self.status = LPSChatBarStatusDefault;
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardY = keyboardF.origin.y - self.offset;
    if (self.status == LPSChatBarStatusMore || self.status == LPSChatBarStatusFace) {
        return;
    }
}

- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGRect kbEndFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:[[UIApplication sharedApplication] keyWindow]];
    _keyboardY = kbEndFrame.origin.y - self.offset;
    if (self.status == LPSChatBarStatusMore || self.status == LPSChatBarStatusFace) {
        return;
    }
    if (_isDisappear) {//一体键盘，在控制器手势返回时，键盘高度保持不变
        if (self.status != LPSChatBarStatusKeyboard) {
            return;
        }
        CGRect kbBeginFrame = [[YYKeyboardManager defaultManager] convertRect:transition.fromFrame toView:[LPSUtilities getCurrentVC].view];
        if (kbBeginFrame.origin.y > (ScreenHeight-self.offset)) {
            self.lps_top = ScreenHeight -self.offset- self.topContainer.lps_height - [LPSUtilities layoutSafeBottom];
        } else {
            self.lps_top = kbBeginFrame.origin.y - self.offset - self.topContainer.lps_height;
        }
        return;
    }
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        if (!transition.toVisible) {
            self.lps_top = ScreenHeight -self.offset- self.topContainer.lps_height - [LPSUtilities layoutSafeBottom];
        } else {
            self.lps_top = kbEndFrame.origin.y - self.offset - self.topContainer.lps_height;
        }
        if (self.lps_top <= 0 && [LPSUtilities iPad]) {
            self.lps_top = 0;
        }
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(changeStateKeyboard:)]) {
            [self.delegate changeStateKeyboard:self.lps_top];
        }
    }];
}

- (void)stickerKeyboard:(PPStickerKeyboard *)stickerKeyboard didClickEmoji:(PPEmoji *)emoji {
    if (!emoji) {
        return;
    }

    UIImage *emojiImage = [UIImage im_imageWithFaceBundleName:emoji.imageName];
    if (!emojiImage) {
        return;
    }

    NSRange selectedRange = self.textView.selectedRange;
    NSString *emojiString = [NSString stringWithFormat:@"%@", emoji.emojiDescription];
    NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithString:emojiString attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor pp_colorWithRGBString:@"#3B3B3B"] }];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:emojiAttributedString];
    self.textView.attributedText = attributedText;
    self.textView.selectedRange = NSMakeRange(selectedRange.location + emojiAttributedString.length, 0);

    [self textViewDidChange:self.textView];
}

- (void)stickerKeyboardDidClickDeleteButton:(PPStickerKeyboard *)stickerKeyboard {
    NSRange selectedRange = self.textView.selectedRange;
    if (selectedRange.location == 0 && selectedRange.length == 0) {
        return;
    }

    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (selectedRange.length > 0) {
        [attributedText deleteCharactersInRange:selectedRange];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    } else {
        [attributedText deleteCharactersInRange:NSMakeRange(selectedRange.location - 1, 1)];
        self.textView.attributedText = attributedText;
        self.textView.selectedRange = NSMakeRange(selectedRange.location - 1, 0);
    }

    [self textViewDidChange:self.textView];
}

- (void)stickerKeyboardDidClickSendButton:(PPStickerKeyboard *)stickerKeyboard {
    [self sendCurrentText];
    [self textViewDidChange:self.textView];
}

#pragma mark - getter
- (UIView *)topContainer {
    if (!_topContainer) {
        _topContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, kLPSChatToolBarHeight)];
        _topContainer.backgroundColor = [UIColor lps_colorWithHexValue:0xffffff];
    }
    return _topContainer;
}
- (UIView *)bottomCotainer {
    if (!_bottomCotainer) {
        _bottomCotainer = [[UIView alloc]initWithFrame:CGRectMake(0, kLPSChatToolBarHeight, ScreenWidth, kChatBottomContentHeight+[LPSUtilities layoutSafeBottom])];
        _bottomCotainer.backgroundColor = [UIColor lps_colorWithHexValue:0xffffff];
    }
    return _bottomCotainer;
}

- (LPSMorePanelView *)moreView {
    if (!_moreView ) {
        _moreView = [[LPSMorePanelView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kChatBottomContentHeight+[LPSUtilities layoutSafeBottom])];
    }
    return _moreView;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 1 / [UIScreen mainScreen].scale)];
        [_topLine setBackgroundColor:[UIColor lps_colorWithHexValue:0xd8d7d9]];
    }
    return _topLine;
}

- (UIButton *)faceBtn {
    if (!_faceBtn) {
        _faceBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 2*kItemIconWidth - kBtnSpace, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth)];
        [_faceBtn setImage:[UIImage im_imageWithBundleName:@"face_normal"] forState:UIControlStateNormal];
        [_faceBtn setImage:[UIImage im_imageWithBundleName:@"keyboard_normal"] forState:UIControlStateSelected];
        [_faceBtn addTarget:self action:@selector(onFaceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceBtn;
}
- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - kItemIconWidth - kBtnSpace, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth)];
        [_moreBtn setImage:[UIImage im_imageWithBundleName:@"more_normal"] forState:UIControlStateNormal];
        [_moreBtn setImage:[UIImage im_imageWithBundleName:@"more_pressed"] forState:UIControlStateSelected];
        [_moreBtn addTarget:self action:@selector(onMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (PPStickerTextView *)textView {
    if (!_textView) {
        _textView = [[PPStickerTextView alloc] initWithFrame:CGRectMake(kItemIconWidth + 2*kBtnSpace, (kLPSChatToolBarHeight - kTextViewHeight)/2, ScreenWidth - 3 * kItemIconWidth - 4 *kBtnSpace, kTextViewHeight)];
        _textView.delegate = self;
        _textView.backgroundColor = [UIColor lps_colorWithHexValue:0xf6f6f6];
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 4.0f;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.scrollsToTop = NO;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.placeholderColor = [UIColor lps_colorWithHexValue:0x999999];
        _textView.placeholder = @" 想对Ta说点什么？";
        _textView.verticalCenter = YES;
        _textView.enablesReturnKeyAutomatically = YES;
        if (@available(iOS 11.0, *)) {
            _textView.textDragInteraction.enabled = NO;
        }
    }
    return _textView;
}

- (PPStickerKeyboard *)faceView {
    if (!_faceView) {
        _faceView = [[PPStickerKeyboard alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, kChatBottomContentHeight)];
        _faceView.delegate = self;
    }
    return _faceView;
}

- (UIButton *)voiceBtn {
    if (!_voiceBtn) {
        _voiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (kLPSChatToolBarHeight - kItemIconWidth)/2, kItemIconWidth, kItemIconWidth)];
        [_voiceBtn setImage:[UIImage im_imageWithBundleName:@"voice_normal"] forState:UIControlStateNormal];
        [_voiceBtn setImage:[UIImage im_imageWithBundleName:@"keyboard_normal"] forState:UIControlStateSelected];
        [_voiceBtn setImage:[UIImage im_imageWithBundleName:@"voice_pressed"] forState:UIControlStateHighlighted];
        [_voiceBtn addTarget:self action:@selector(onVoiceBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceBtn;
}

- (LPSRecordButton *)talkBtn {
    if (!_talkBtn) {
        _talkBtn = [[LPSRecordButton alloc]initWithFrame:self.textView.frame];
        [_talkBtn setHidden:YES];
        [_talkBtn addTarget:self action:@selector(onClickRecordTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_talkBtn addTarget:self action:@selector(onClickRecordTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_talkBtn addTarget:self action:@selector(onClickRecordTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_talkBtn addTarget:self action:@selector(onClickRecordTouchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [_talkBtn addTarget:self action:@selector(onClickRecordTouchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    }
    return _talkBtn;
}

@end
