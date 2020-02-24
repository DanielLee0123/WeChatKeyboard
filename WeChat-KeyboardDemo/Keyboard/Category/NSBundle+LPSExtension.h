//
//  NSBundle+RRWid.h
//  TFYT
//
//  Created by Daniel_Lee on 2018/7/12.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (LPSExtension)
- (NSString *_Nullable)rr_pathForResource:(nullable NSString *)name ofType:(nullable NSString *)ext;
@end
