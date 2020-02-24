//
//  LPSVoiceRecordControl.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPSVoiceRecordDefine.h"

@interface LPSVoiceRecordControl : NSObject

- (void)updateUIWithRecordState:(LPSVoiceRecordState)state;
- (void)showToast:(NSString *)message complete:(void (^)(void))complete;
- (void)updatePower:(float)power;
- (void)showRecordCounting:(float)remainTime;

@end
