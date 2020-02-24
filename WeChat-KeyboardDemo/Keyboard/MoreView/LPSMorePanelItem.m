//
//  LPSMorePanelItem.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/19.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSMorePanelItem.h"
#import "UIImage+imageBundle.h"
#import "NSString+LPSExtension.h"

#define kMoreItemWidth  59

@interface LPSMorePanelItem ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation LPSMorePanelItem

+ (LPSMorePanelItem *)createMoreItemWithTitle:(NSString *)title imageName:(NSString *)imageName handler:(void(^)(void))handler
{
    LPSMorePanelItem *item = [[LPSMorePanelItem alloc] init];
    item.title = title;
    item.imageName = imageName;
    item.handler = handler;
    return item;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.button.frame = CGRectMake(0, 0, kMoreItemWidth, kMoreItemWidth);
    self.button.center = CGPointMake(self.frame.size.width / 2, self.button.center.y);
    UIFont *font = [UIFont systemFontOfSize:12];
    CGFloat titleWidth = [self.titleLabel.text rr_sizeWithFont:font maxWidth:self.frame.size.width+10].width;
    self.titleLabel.frame = CGRectMake(0, self.button.frame.size.height + 5, titleWidth, ceilf(font.lineHeight));
    self.titleLabel.center = CGPointMake(self.frame.size.width / 2, self.titleLabel.center.y);
}

#pragma mark - Public Method

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
    [self.button setTag:tag];
}

#pragma mark - Setter

- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.titleLabel setText:title];
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    [self.button setImage:[UIImage im_imageWithBundleName:imageName] forState:UIControlStateNormal];
}
#pragma mark - Getter

- (UIButton *) button
{
    if (!_button) {
        _button = [[UIButton alloc] init];
    }
    return _button;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_titleLabel setTextColor:[UIColor grayColor]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _titleLabel;
}

@end
