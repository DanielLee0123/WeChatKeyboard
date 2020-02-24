//
//  LPSSoundRecorder.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/28.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSSoundRecorder.h"
#import "LPSVoiceRecordControl.h"

#pragma clang diagnostic ignored "-Wdeprecated"

#define kRecordFileStr      @"/voice-local.aac"

@interface LPSSoundRecorder ()

@property (nonatomic, strong) LPSVoiceRecordControl *voiceRecordCtrl;
@property (nonatomic, assign) LPSVoiceRecordState currentRecordState;

@property (nonatomic, strong) NSString *recordPath;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;

@end

@implementation LPSSoundRecorder

+ (LPSSoundRecorder *)sharedInstance {
    static LPSSoundRecorder *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        if (!sharedInstance) {
            sharedInstance = [[LPSSoundRecorder alloc] init];
        }
    });
    
    return sharedInstance;
}

- (void)startSoundRecord:(NSString *)path {
    self.recordPath = path;
    self.currentRecordState = LPSVoiceRecordStateRecording;
    [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateRecording];
    [self startRecord];
}

- (void)stopSoundRecord {
    if (self.levelTimer) {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
    }
    
    NSString *str = [NSString stringWithFormat:@"%f",_recorder.currentTime];
    
    int times = [str intValue];
    if (self.recorder) {
        [self.recorder stop];
    }
    
    if (times >= 1) {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(didStopSoundRecord)]) {
            [self.delegate didStopSoundRecord];
        }
        self.currentRecordState = LPSVoiceRecordStateStoped;
        [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateStoped];
    } else {
        if (self.recorder) {
            [self.recorder deleteRecording];
        }
        if ([self.delegate respondsToSelector:@selector(showSoundRecordFailed)]) {
            [self.delegate showSoundRecordFailed];
        }
        self.currentRecordState = LPSVoiceRecordStateNormal;
        [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateNormal];
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //恢复外部正在播放的音乐
    NSError *err;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
}

- (BOOL)isRecording {
    return self.recorder.isRecording;
}

- (void)soundRecordFailed {
    [self.recorder stop];
    if (self.levelTimer) {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
    }
    self.currentRecordState = LPSVoiceRecordStateNormal;
    [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateNormal];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //恢复外部正在播放的音乐
    NSError *err;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&err];
}

- (void)readyCancelSound {
    self.currentRecordState = LPSVoiceRecordStateReleaseToCancel;
    [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateReleaseToCancel];
}

- (void)resetNormalRecord {
    self.currentRecordState = LPSVoiceRecordStateRecording;
    [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateRecording];
}

- (void)showShotTimeSignComplete:(void (^)(void))complete {
    [self.voiceRecordCtrl showToast:@"说话时间太短" complete:complete];
    [self stopSoundRecord];
}

- (void)showCountdown:(int)countDown {
    if (self.currentRecordState != LPSVoiceRecordStateReleaseToCancel) {
        self.currentRecordState = LPSVoiceRecordStateRecordCounting;
        [self.voiceRecordCtrl updateUIWithRecordState:LPSVoiceRecordStateRecordCounting];
        [self.voiceRecordCtrl showRecordCounting:countDown];
    }
}

- (void)startRecord {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if (err) {
        [self soundRecordFailed];
        return;
    }
    
    //设置录音输入源
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride),&audioRouteOverride);
#pragma clang diagnostic pop
    [audioSession setActive:YES error:&err];
    if(err) {
        [self soundRecordFailed];
        return;
    }
    //设置文件保存路径和名称
    self.recordPath = [self.recordPath stringByAppendingPathComponent:kRecordFileStr];
    NSURL *recordedFile = [NSURL fileURLWithPath:self.recordPath];
    NSDictionary *dic = [self recordingSettings];
    //初始化AVAudioRecorder
    err = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:dic error:&err];
    if(_recorder == nil) {
        [self soundRecordFailed];
        return;
    }
    //准备和开始录音
    [_recorder prepareToRecord];
    self.recorder.meteringEnabled = YES;
    [self.recorder record];
    [_recorder recordForDuration:0];
    if (self.levelTimer) {
        [self.levelTimer invalidate];
        self.levelTimer = nil;
    }
    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
}

- (void)levelTimerCallback:(NSTimer *)timer {
    if (_recorder) {
        [_recorder updateMeters];

        float   level;// The linear 0.0 .. 1.0 value we need.
        float   minDecibels = -80.0f;// Or use -60dB, which I measured in a silent room.
        float   decibels    = [_recorder averagePowerForChannel:0];
        
        if (decibels < minDecibels) {
            level = 0.0f;
        } else if (decibels >= 0.0f) {
            level = 1.0f;
        } else {
            float   root            = 2.0f;
            float   minAmp          = powf(10.0f, 0.05f * minDecibels);
            float   inverseAmpRange = 1.0f / (1.0f - minAmp);
            float   amp             = powf(10.0f, 0.05f * decibels);
            float   adjAmp          = (amp - minAmp) * inverseAmpRange;
            
            level = powf(adjAmp, 1.0f / root);
        }
        
        /* level 范围[0 ~ 1], 转为[0 ~120] 之间 */
//        NSLog(@"------>%f",level);
        [self.voiceRecordCtrl updatePower:level];
    }
}

- (NSTimeInterval)soundRecordTime {
    return _recorder.currentTime;
}

#pragma mark - Getters

- (NSDictionary *)recordingSettings
{
    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionaryWithCapacity:10];
    [recordSetting setObject:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //2 采样率
    [recordSetting setObject:[NSNumber numberWithFloat:44100] forKey: AVSampleRateKey];
    //3 通道的数目
    [recordSetting setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //4 采样位数  默认 16
    [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //5 音频编码的比特率 单位Kbps 传输的速率
    [recordSetting setObject:[NSNumber numberWithInt:128000] forKey:AVEncoderBitRateKey];
    //6 录音质量 高
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    return recordSetting;
}

- (NSString *)soundFilePath {
    return self.recordPath;
}

- (LPSVoiceRecordControl *)voiceRecordCtrl
{
    if (!_voiceRecordCtrl) {
        _voiceRecordCtrl = [LPSVoiceRecordControl new];
    }
    return _voiceRecordCtrl;
}

@end
