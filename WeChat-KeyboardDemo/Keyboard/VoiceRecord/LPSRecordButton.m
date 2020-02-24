//
//  LPSRecordButton.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSRecordButton.h"

@implementation LPSRecordButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor lps_colorWithHexValue:0xA3A5AB].CGColor;
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self setTitleColor:[UIColor lps_colorWithHexValue:0x565656] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor lps_colorWithHexValue:0x565656] forState:UIControlStateHighlighted];
        [self setTitle:@"Hold to talk" forState:UIControlStateNormal];
    }
    return self;
}

- (void)updateRecordButtonStyle:(LPSVoiceRecordState)state
{
    [self setTitle:@"Hold to talk" forState:UIControlStateNormal];
    self.backgroundColor = [UIColor whiteColor];
    if (state == LPSVoiceRecordStateRecording) {
        [self setTitle:@"Release to send" forState:UIControlStateNormal];
        self.backgroundColor = [UIColor lps_colorWithHexValue:0xC6C7CA];
    }
    else if (state == LPSVoiceRecordStateReleaseToCancel)
    {
        [self setTitle:@"Hold to talk" forState:UIControlStateNormal];
        self.backgroundColor = [UIColor lps_colorWithHexValue:0xC6C7CA];
    }
    else if (state == LPSVoiceRecordStateRecordCounting)
    {
        [self setTitle:@"Release to send" forState:UIControlStateNormal];
        self.backgroundColor = [UIColor lps_colorWithHexValue:0xC6C7CA];
    }
}

@end
