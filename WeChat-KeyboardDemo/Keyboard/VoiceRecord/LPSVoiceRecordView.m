//
//  LPSVoiceRecordView.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSVoiceRecordView.h"

@interface LPSVoiceRecordView ()

@property (nonatomic, strong) LPSVoiceRecordingView *recodingView;
@property (nonatomic, strong) LPSVoiceRecordReleaseToCancelView *releaseToCancelView;
@property (nonatomic, strong) LPSVoiceRecordCountingView *countingView;
@property (nonatomic, assign) LPSVoiceRecordState currentState;

@end

@implementation LPSVoiceRecordView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    if (!_recodingView) {
        self.recodingView = [[LPSVoiceRecordingView alloc] initWithFrame:self.bounds];
        [self addSubview:_recodingView];
        _recodingView.hidden = YES;
    }
    
    if (!_releaseToCancelView) {
        self.releaseToCancelView = [[LPSVoiceRecordReleaseToCancelView alloc] initWithFrame:self.bounds];
        [self addSubview:_releaseToCancelView];
        _releaseToCancelView.hidden = YES;
    }
    
    if (!_countingView) {
        self.countingView = [[LPSVoiceRecordCountingView alloc] initWithFrame:self.bounds];
        [self addSubview:_countingView];
        _countingView.hidden = YES;
    }
    
    self.backgroundColor = [UIColor lps_colorWithHexValue:0x000000 alpha:0.5];
    self.layer.cornerRadius = 6;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _recodingView.frame = self.bounds;
    _releaseToCancelView.frame = self.bounds;
    _countingView.frame = self.bounds;
}

- (void)updatePower:(float)power
{
    if (_currentState != LPSVoiceRecordStateRecording) {
        return;
    }
    [_recodingView updateWithPower:power];
}

- (void)updateWithRemainTime:(float)remainTime
{
    if (_currentState != LPSVoiceRecordStateRecordCounting || _releaseToCancelView.hidden == NO) {
        return;
    }
    [_countingView updateWithRemainTime:remainTime];
}

- (void)updateUIWithRecordState:(LPSVoiceRecordState)state
{
    self.currentState = state;
    if (state == LPSVoiceRecordStateNormal || state == LPSVoiceRecordStateStoped) {
        _recodingView.hidden = YES;
        _releaseToCancelView.hidden = YES;
        _countingView.hidden = YES;
    }
    else if (state == LPSVoiceRecordStateRecording)
    {
        _recodingView.hidden = NO;
        _releaseToCancelView.hidden = YES;
        _countingView.hidden = YES;
    }
    else if (state == LPSVoiceRecordStateReleaseToCancel)
    {
        _recodingView.hidden = YES;
        _releaseToCancelView.hidden = NO;
        _countingView.hidden = YES;
    }
    else if (state == LPSVoiceRecordStateRecordCounting)
    {
        _recodingView.hidden = YES;
        _releaseToCancelView.hidden = YES;
        _countingView.hidden = NO;
    }
    else if (state == LPSVoiceRecordStateRecordTooShort)
    {
        _recodingView.hidden = YES;
        _releaseToCancelView.hidden = YES;
        _countingView.hidden = YES;
    }
}

@end
