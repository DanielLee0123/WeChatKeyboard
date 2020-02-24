//
//  RRVoiceRecordToastContentView.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPSVoiceRecordToastContentView : UIView

@end

@interface LPSVoiceRecordingView : LPSVoiceRecordToastContentView

- (void)updateWithPower:(float)power;

@end

//----------------------------------------//
@interface LPSVoiceRecordReleaseToCancelView : LPSVoiceRecordToastContentView


@end

//----------------------------------------//

@interface LPSVoiceRecordCountingView : LPSVoiceRecordToastContentView

- (void)updateWithRemainTime:(float)remainTime;

@end

//----------------------------------------//
@interface LPSVoiceRecordTipView : LPSVoiceRecordToastContentView

- (void)showWithMessage:(NSString *)msg;

@end
