//
//  LPSSoundRecorder.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/28.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol JHSoundRecorderDelegate <NSObject>

- (void)showSoundRecordFailed;
- (void)didStopSoundRecord;

@end

@interface LPSSoundRecorder : NSObject

@property (nonatomic, strong) NSString *soundFilePath;
@property (nonatomic, weak) id<JHSoundRecorderDelegate>delegate;

+ (LPSSoundRecorder *)sharedInstance;

/**
 *  开始录音
 *  @param path 音频文件保存路径
 */
- (void)startSoundRecord:(NSString *)path;
/**
 *  录音结束
 */
- (void)stopSoundRecord;
/**
 *  更新录音显示状态,手指向上滑动后 提示松开取消录音
 */
- (void)soundRecordFailed;
/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)readyCancelSound;
/**
 *  更新录音状态,手指重新滑动到范围内,提示向上取消录音
 */
- (void)resetNormalRecord;
/**
 *  录音时间太短，大于等于1s
 */
- (void)showShotTimeSignComplete:(void (^)(void))complete;
/**
 *  最后10秒倒计时
 *  @param countDown 剩余秒数
 */
- (void)showCountdown:(int)countDown;
/**
 *  是否正在录音
 */
- (BOOL)isRecording;

- (NSTimeInterval)soundRecordTime;

@end
