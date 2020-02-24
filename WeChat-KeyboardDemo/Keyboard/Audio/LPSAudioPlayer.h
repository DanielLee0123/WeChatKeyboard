//
//  LPSAudioPlayer.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/28.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>

typedef NS_ENUM(NSUInteger, RRAudioPlayerState){
    RRAudioPlayerStateNormal = 0,/** 未播放状态 */
    RRAudioPlayerStatePlaying = 1,/** 正在播放 */
    RRAudioPlayerStateCancel = 2,/** 播放被取消 */
};

@interface LPSAudioPlayer : NSObject

@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, assign, readonly) RRAudioPlayerState audioPlayerState;

+ (instancetype)sharePlayer;

- (void)playAudioWithURLString:(NSString *)URLString complete:(void (^)(void))complete;

- (void)stopAudioPlayer;

- (void)didFinishPlayingHandler:(void(^)(void))finishPlayingHandler;

//获取音频格式AudioFormatID
+ (AudioFormatID)getAudioFormatIDWithPath:(NSString *)path;

@end
