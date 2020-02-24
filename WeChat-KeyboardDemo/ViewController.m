//
//  ViewController.m
//  LPSChatKeyboardDemo
//
//  Created by Daniel_Lee on 2019/8/12.
//  Copyright © 2019 Daniel_Lee. All rights reserved.
//

#import "ViewController.h"
#import "LPSChatViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 60, 35)];
    [button setTitle:@"chat" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)click {
    LPSChatViewController *chatVC = [[LPSChatViewController alloc] init];
    [self.navigationController pushViewController:chatVC animated:YES];
}

@end
