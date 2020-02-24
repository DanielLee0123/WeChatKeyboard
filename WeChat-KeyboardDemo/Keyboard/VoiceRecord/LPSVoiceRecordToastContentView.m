//
//  RRVoiceRecordToastContentView.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/25.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSVoiceRecordToastContentView.h"
#import "LPSVoiceRecordPowerAnimationView.h"

@implementation LPSVoiceRecordToastContentView

@end

//----------------------------------------//
@interface LPSVoiceRecordingView ()

@property (nonatomic, strong) UIImageView *imgRecord;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) LPSVoiceRecordPowerAnimationView *powerView;

@end

@implementation LPSVoiceRecordingView

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.text = @"上滑取消发送";
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:_contentLabel];
    }
    if (!_imgRecord) {
        _imgRecord = [UIImageView new];
        _imgRecord.backgroundColor = [UIColor clearColor];
        _imgRecord.image = [UIImage im_imageWithBundleName:@"ic_record"];
        [self addSubview:_imgRecord];
    }
    if (!_powerView) {
        _powerView = [LPSVoiceRecordPowerAnimationView new];
        _powerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_powerView];
    }
    
    CGSize powerSize = CGSizeMake(18, 55);
    //默认显示一格音量
    _powerView.originSize = powerSize;
    [_powerView updateWithPower:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize textSize = [_contentLabel sizeThatFits:CGSizeZero];
    self.contentLabel.frame = CGRectMake(0, 0, self.lps_width, ceil(textSize.height));
    self.contentLabel.lps_bottom = self.lps_height - 12;
    self.imgRecord.frame = CGRectMake(40, 30, _imgRecord.image.size.width, _imgRecord.image.size.height);
    CGSize powerSize = CGSizeMake(18, 55);
    self.powerView.frame = CGRectMake(self.imgRecord.lps_right+4, 0, powerSize.width, powerSize.height);
    self.powerView.lps_bottom = self.imgRecord.lps_bottom;
}

- (void)updateWithPower:(float)power
{
    [_powerView updateWithPower:power];
}

@end

//----------------------------------------//
@interface LPSVoiceRecordReleaseToCancelView ()

@property (nonatomic, strong) UIImageView *imgRelease;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation LPSVoiceRecordReleaseToCancelView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    if (!_imgRelease) {
        _imgRelease = [UIImageView new];
        _imgRelease.backgroundColor = [UIColor clearColor];
        _imgRelease.image = [UIImage im_imageWithBundleName:@"ic_release_to_cancel"];
        [self addSubview:_imgRelease];
    }
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _contentLabel.text = @"松开取消发送";
        _contentLabel.textColor = [UIColor lps_colorWithHexValue:0xffffff];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont boldSystemFontOfSize:15];
        _contentLabel.layer.cornerRadius = 2;
        _contentLabel.clipsToBounds = YES;
        [self addSubview:_contentLabel];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imgRelease.frame = CGRectMake(0, 30, _imgRelease.image.size.width, _imgRelease.image.size.height);
    self.imgRelease.lps_centerX = self.lps_width / 2;
    self.contentLabel.frame = CGRectMake(3, 0, self.lps_width-6, self.contentLabel.font.lineHeight);
    self.contentLabel.lps_bottom = self.lps_height - 12;
}

@end

//----------------------------------------//
@interface LPSVoiceRecordCountingView ()

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *lbRemainTime;

@end

@implementation LPSVoiceRecordCountingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.text = @"上滑取消发送";
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.layer.cornerRadius = 2;
        _contentLabel.clipsToBounds = YES;
        [self addSubview:_contentLabel];
    }
    if (!_lbRemainTime) {
        _lbRemainTime = [UILabel new];
        _lbRemainTime.backgroundColor = [UIColor clearColor];
        _lbRemainTime.font = [UIFont systemFontOfSize:60];
        _lbRemainTime.textColor = [UIColor whiteColor];
        [self addSubview:_lbRemainTime];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentLabel.frame = CGRectMake(3, 0, self.lps_width - 6, 25);
    self.contentLabel.lps_bottom = self.lps_height - 12;
    CGSize textSize = [_lbRemainTime sizeThatFits:CGSizeZero];
    self.lbRemainTime.frame = CGRectMake(0, 8, ceil(textSize.width), [UIFont systemFontOfSize:60].lineHeight);
    self.lbRemainTime.lps_centerX = self.lps_width / 2;
}

- (void)updateWithRemainTime:(float)remainTime
{
    _lbRemainTime.text = [NSString stringWithFormat:@"%d",(int)remainTime];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end

//----------------------------------------//
@interface LPSVoiceRecordTipView ()

@property (nonatomic, strong) UIImageView *imgIcon;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation LPSVoiceRecordTipView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor lps_colorWithHexValue:0x000000 alpha:0.5];
    self.layer.cornerRadius = 6;
    
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.text = @"说话时间太短";
        [self addSubview:_contentLabel];
    }
    if (!_imgIcon) {
        _imgIcon = [UIImageView new];
        _imgIcon.backgroundColor = [UIColor clearColor];
        _imgIcon.image = [UIImage im_imageWithBundleName:@"ic_shuohuashijiantaiduan_liaotianshi"];
        [self addSubview:_imgIcon];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imgIcon.frame = CGRectMake(0, 15, _imgIcon.image.size.width, _imgIcon.image.size.height);
    self.imgIcon.lps_centerX = self.lps_width / 2;
    CGSize textSize = [_contentLabel sizeThatFits:CGSizeZero];
    self.contentLabel.frame = CGRectMake(0, 0, self.lps_width, ceil(textSize.height));
    self.contentLabel.lps_bottom = self.lps_height - 12;
}

- (void)showWithMessage:(NSString *)msg
{
    _contentLabel.text = msg;
}

@end
