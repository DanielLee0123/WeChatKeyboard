//
//  LPSMsgTextCell.h
//  WeChat-KeyboardDemo
//
//  Created by Daniel_Lee on 2020/2/24.
//  Copyright © 2020 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPSMsgTextCell : UITableViewCell

- (void)reloadWithAttr:(NSMutableAttributedString *)attributedText;

@end

NS_ASSUME_NONNULL_END
