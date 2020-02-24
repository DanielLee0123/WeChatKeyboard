//
//  LPSVoiceRecordControl.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSVoiceRecordControl.h"
#import "LPSVoiceRecordView.h"

@interface LPSVoiceRecordControl ()

@property (nonatomic, strong) LPSVoiceRecordView *voiceRecordView;
@property (nonatomic, strong) LPSVoiceRecordTipView *tipView;

@end

@implementation LPSVoiceRecordControl

- (void)updatePower:(float)power
{
    [self.voiceRecordView updatePower:power];
}

- (void)showRecordCounting:(float)remainTime
{
    [self.voiceRecordView updateWithRemainTime:remainTime];
}

- (void)showToast:(NSString *)message complete:(void (^)(void))complete
{
    if (!self.tipView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.tipView];
        [self.tipView showWithMessage:message];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
            [self.tipView removeFromSuperview];
        });
    }
}

- (void)updateUIWithRecordState:(LPSVoiceRecordState)state
{
    if (state == LPSVoiceRecordStateNormal || state == LPSVoiceRecordStateStoped) {
        if (self.voiceRecordView.superview) {
            [self.voiceRecordView removeFromSuperview];
        }
        return;
    }
    
    if (!self.voiceRecordView.superview) {
        [[[UIApplication sharedApplication].delegate window] addSubview:self.voiceRecordView];
    }
    
    [self.voiceRecordView updateUIWithRecordState:state];
}

- (LPSVoiceRecordView *)voiceRecordView
{
    if (!_voiceRecordView) {
        _voiceRecordView = [[LPSVoiceRecordView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        _voiceRecordView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }
    return _voiceRecordView;
}

- (LPSVoiceRecordTipView *)tipView
{
    if (!_tipView) {
        _tipView = [[LPSVoiceRecordTipView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        _tipView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    }
    return _tipView;
}

@end
