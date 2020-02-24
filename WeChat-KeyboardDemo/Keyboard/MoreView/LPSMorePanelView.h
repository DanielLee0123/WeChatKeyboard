//
//  LPSMorePanelView.h
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/19.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LPSMorePanelItem.h"

@interface LPSMorePanelView : UIView

- (void)addMoreItem:(LPSMorePanelItem *)item;

- (void)removeMoreItem:(LPSMorePanelItem *)item;

- (void)addMoreContentView:(UIView *)plugin;

- (void)removeMoreContentView;

@end
