//
//  RRVoiceRecordDefine.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#ifndef LPSVoiceRecordDefine_h
#define LPSVoiceRecordDefine_h

typedef NS_ENUM(NSInteger, LPSVoiceRecordState)
{
    LPSVoiceRecordStateNormal,          //初始状态
    LPSVoiceRecordStateRecording,       //正在录音
    LPSVoiceRecordStateReleaseToCancel, //上滑取消（也在录音状态，UI显示有区别）
    LPSVoiceRecordStateRecordCounting,  //最后10s倒计时（也在录音状态，UI显示有区别）
    LPSVoiceRecordStateRecordTooShort,  //录音时间太短（录音结束了）
    LPSVoiceRecordStateStoped,          //录音结束
};

#endif /* LPSVoiceRecordDefine_h */
