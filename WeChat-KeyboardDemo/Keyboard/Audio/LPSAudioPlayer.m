//
//  LPSAudioPlayer.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/28.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "amrFileCodec.h"

#pragma clang diagnostic ignored "-Wdeprecated"

NSString *const kXMNAudioDataKey;

@interface LPSAudioPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSOperationQueue *audioDataOperationQueue;
@property (nonatomic, assign) RRAudioPlayerState audioPlayerState;
@property (nonatomic, copy) void (^complete) (void);
@property (nonatomic, copy) void(^finishPlayingHandler)(void);

@end

@implementation LPSAudioPlayer

+ (void)initialize {
    //配置播放器配置
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioDataOperationQueue = [[NSOperationQueue alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

+ (instancetype)sharePlayer{
    static dispatch_once_t onceToken;
    static id shareInstance;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

#pragma mark - Public Methods

- (void)playAudioWithURLString:(NSString *)URLString complete:(void (^)(void))complete {
    if (!URLString.length) {
        return;
    }
    
    //如果来自同一个URLString相同,则直接取消
    if ([self.URLString isEqualToString:URLString]) {
        [self stopAudioPlayer];
        [self setAudioPlayerState:RRAudioPlayerStateCancel];
        if (complete) {
            complete();
        }
        return;
    }
    
    self.URLString = URLString;
    self.complete = complete;
    
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *audioData = [self audioDataFromURLString:URLString];
        if (!audioData) {
            [self setAudioPlayerState:RRAudioPlayerStateCancel];
            if (complete) {
                complete();
            }
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playAudioWithData:audioData];
        });
    }];
    [_audioDataOperationQueue addOperation:blockOperation];
}

- (void)stopAudioPlayer {
    if (_audioPlayer) {
        _audioPlayer.playing ? [_audioPlayer stop] : nil;
        _audioPlayer.delegate = nil;
        _audioPlayer = nil;
        if (self.complete) {
            self.complete();
        }
        _complete = nil;
        [[LPSAudioPlayer sharePlayer] setAudioPlayerState:RRAudioPlayerStateCancel];
        [self handleMonitorNotification:NO];
    }
}

- (void)didFinishPlayingHandler:(void(^)(void))finishPlayingHandler {
    _finishPlayingHandler = finishPlayingHandler;
}

#pragma mark - Private Methods
- (NSData *)audioDataFromURLString:(NSString *)URLString {
    NSData *audioData = [self convertAMRtoWAVE:URLString];
    if (!audioData) {//data为空说明不为amr格式，直接读取本地数据
        audioData = [NSData dataWithContentsOfFile:URLString];
    }
    
    if (audioData) {
        objc_setAssociatedObject(audioData, &kXMNAudioDataKey, [NSString stringWithFormat:@"%@",URLString], OBJC_ASSOCIATION_COPY);
    }
    
    return audioData;
}

- (void)playAudioWithData:(NSData *)audioData {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
    NSString *audioURLString = objc_getAssociatedObject(audioData, &kXMNAudioDataKey);
    if (![self.URLString isEqualToString:audioURLString]) {
        return;
    }
    
    NSError *audioPlayerError;
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&audioPlayerError];
    if (!_audioPlayer || !audioData) {
        [self setAudioPlayerState:RRAudioPlayerStateCancel];
        return;
    }
    //添加近距离监听
    [self handleMonitorNotification:YES];
    _audioPlayer.volume = 1.0f;
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [self setAudioPlayerState:RRAudioPlayerStatePlaying];
    [_audioPlayer play];
}

#pragma mark - 监听听筒or扬声器
- (void)handleMonitorNotification:(BOOL)state
{
    if(state) {//添加监听
        [[UIDevice currentDevice] setProximityMonitoringEnabled:state];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    } else {//移除监听
        if (![_audioPlayer isPlaying] && ![[UIDevice currentDevice] proximityState]) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    }
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (![_audioPlayer isPlaying]) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    }
}

- (void)cancelOperation {
    for (NSOperation *operation in _audioDataOperationQueue.operations) {
        [operation cancel];
        break;
    }
}

- (void)setComplete:(void (^)(void))complete
{
    if (_complete) {
        _complete();
    }
    _complete = complete;
}

#pragma mark - Setters

- (void)setURLString:(NSString *)URLString {
    if (_URLString.length) {
        //说明当前有正在播放,或者正在加载的视频,取消operation(如果没有在执行任务),停止播放
        [self cancelOperation];
        [self stopAudioPlayer];
        [self setAudioPlayerState:RRAudioPlayerStateCancel];
    }
    _URLString = [URLString copy];
}

- (void)setAudioPlayerState:(RRAudioPlayerState)audioPlayerState {
    _audioPlayerState = audioPlayerState;
    if (_audioPlayerState == RRAudioPlayerStateCancel || _audioPlayerState == RRAudioPlayerStateNormal) {
        _URLString = nil;
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self setAudioPlayerState:RRAudioPlayerStateNormal];
    if (self.complete) {
        self.complete();
    }
    _complete = nil;
    //移除近距离事件监听
    [self handleMonitorNotification:NO];
    //延迟一秒将audioPlayer 释放
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .2f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self stopAudioPlayer];
        if (self.finishPlayingHandler) {
            self.finishPlayingHandler();
        }
        self->_finishPlayingHandler = nil;
    });
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
//    [[RRToastView Toast] showToast:RRToastTypeFail title:error.description content:nil duration:1.5 offsetY:0 inView:nil];
    if (self.complete) {
        self.complete();
    }
    _complete = nil;
}

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
    int type = [notification.userInfo[AVAudioSessionInterruptionOptionKey] intValue];
    switch (type) {
        case AVAudioSessionInterruptionTypeBegan: // 被打断
            [self.audioPlayer pause]; // 暂停播放
            break;
        case AVAudioSessionInterruptionTypeEnded: // 中断结束
            [self.audioPlayer play];  // 继续播放
            break;
        default:
            break;
    }
}

#pragma mark - helper

- (NSData *)convertAMRtoWAVE:(NSString *)fielPath {
    NSData *data = [NSData dataWithContentsOfFile:fielPath];
    data = DecodeAMRToWAVE(data);
    return data;
}

+ (AudioFormatID)getAudioFormatIDWithPath:(NSString *)path {
    if (path.length == 0) {
        return 0;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    CFURLRef urlRef = (__bridge CFURLRef)url;
    AudioFileID audioFile;
    OSStatus status = AudioFileOpenURL(urlRef, kAudioFileReadPermission, kAudioFileAMRType, &audioFile);
    if (status == noErr) {
        UInt32 formatListSize;
        status = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyFormatList, &formatListSize, NULL);
        if (status == noErr) {
            AudioFormatListItem *formatList = malloc(formatListSize);
            status = AudioFileGetProperty(audioFile, kAudioFilePropertyFormatList, &formatListSize, formatList);
            if (status == noErr) {
                AudioFormatID formatID = 0;
                for (int i = 0; i*sizeof(AudioFormatListItem)<formatListSize; i++) {
                    AudioStreamBasicDescription format = formatList[i].mASBD;
                    formatID = format.mFormatID;
                    if (formatID > 0) {
                        break;
                    }
                }
                free(formatList);
                [self closeAudioFile:&audioFile];
                return formatID;
            }
            free(formatList);
        }
    }
    [self closeAudioFile:&audioFile];
    return 0;
}

+ (void)closeAudioFile:(AudioFileID *)audioFile {
    if (*audioFile != NULL) {
        AudioFileClose(*audioFile);
        *audioFile = NULL;
    }
}

@end
