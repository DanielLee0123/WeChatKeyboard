//
//  LPSVoiceRecordPowerAnimationView.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPSVoiceRecordPowerAnimationView : UIView

@property (nonatomic, assign) CGSize originSize;

- (void)updateWithPower:(float)power;

@end
