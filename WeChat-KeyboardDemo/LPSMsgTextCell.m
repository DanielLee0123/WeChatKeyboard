//
//  LPSMsgTextCell.m
//  WeChat-KeyboardDemo
//
//  Created by Daniel_Lee on 2020/2/24.
//  Copyright © 2020 Daniel_Lee. All rights reserved.
//

#import "LPSMsgTextCell.h"
#import "YYText.h"

@interface LPSMsgTextCell ()

@property (nonatomic, strong) YYLabel *msgLabel;

@end

@implementation LPSMsgTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.msgLabel];
    }
    
    return self;
}

- (void)reloadWithAttr:(NSMutableAttributedString *)attributedText {
    [self.msgLabel setAttributedText:attributedText];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.msgLabel.frame = CGRectMake(15, 0, self.frame.size.width-15, self.frame.size.height);
}


- (YYLabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[YYLabel alloc] init];
        _msgLabel.backgroundColor = [UIColor clearColor];
        _msgLabel.font = [UIFont systemFontOfSize:15];
        _msgLabel.textColor = [UIColor blackColor];
        _msgLabel.numberOfLines = 0;
        _msgLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    }
    return _msgLabel;
}

@end
