//
//  LPSVoiceRecordView.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSVoiceRecordDefine.h"
#import "LPSVoiceRecordToastContentView.h"

@interface LPSVoiceRecordView : UIView

- (void)updateUIWithRecordState:(LPSVoiceRecordState)state;
- (void)updatePower:(float)power;
- (void)updateWithRemainTime:(float)remainTime;

@end
