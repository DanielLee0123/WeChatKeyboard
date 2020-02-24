//
//  LPSChatViewController.m
//  WeChat-KeyboardDemo
//
//  Created by Daniel_Lee on 2020/2/24.
//  Copyright © 2020 Daniel_Lee. All rights reserved.
//

#import "LPSChatViewController.h"
#import "LPSChatKeyBoard.h"
#import "LPSUtilities.h"
#import "LPSChatKeyboardDelegate.h"
#import "PPStickerDataManager.h"
#import "LPSMsgTextCell.h"

@interface LPSChatViewController ()<UITableViewDataSource, UITableViewDelegate,LPSChatKeyboardDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LPSChatKeyBoard *keyBoard;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation LPSChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, 0, self.view.lps_width, self.view.lps_height-(kLPSChatToolBarHeight+[LPSUtilities layoutSafeBottom]));
    self.keyBoard.offset = 0;
    self.keyBoard.frame = CGRectMake(0, self.tableView.lps_bottom, ScreenWidth, kLPSChatToolBarHeight+[LPSUtilities layoutSafeBottom]);
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.keyBoard];
    
}

- (void)showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"chat";
    LPSMsgTextCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[LPSMsgTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    id str = [self.dataSource objectAtIndex:indexPath.row];
    if ([str isKindOfClass:[NSAttributedString class]]) {
        [cell reloadWithAttr:str];
    } else {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
        NSDictionary *attriDic = @{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor blackColor]};
        [attr setAttributes:attriDic range:NSMakeRange(0, attr.length)];
        [cell reloadWithAttr:attr];
    }
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.keyBoard hideKeyBoard];
}

#pragma mark - LPSChatKeyboardDelegate

- (void)changeStateKeyboard:(CGFloat)chatKeyboardY
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [UIView animateWithDuration:0.25 animations:^{
           self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, chatKeyboardY);
       } completion:^(BOOL finished) {}];
        
       if (self.tableView.contentSize.height > self.tableView.frame.size.height)
       {
           if (self.keyBoard.status != LPSChatBarStatusDefault) {
               CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
               [self.tableView setContentOffset:offset animated:YES];
           }
       }
   });
}

/**
 *  发送输入框中的文字
 */
- (void)stickerInputViewDidClickSendButton:(LPSChatKeyBoard *_Nullable)inputView
{
    NSString *plainText =  [inputView.plainText copy];
    if (plainText.length == 0){
        //输入
        return;
    }
    NSDictionary *attriDic = @{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor blackColor]};
    NSAttributedString *attrText = (NSMutableAttributedString *)[[PPStickerDataManager sharedInstance] replaceEmojiForString:plainText attributes:attriDic];
    [self.dataSource addObject:attrText];
    [self showMsgs];
}

- (void)showMsgs {
    NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    if (@available(iOS 11.0, *)) {
        [self.tableView performBatchUpdates:^{
            [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        }completion:^(BOOL finished) {
            if ([self.tableView numberOfRowsInSection:0] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                });
            }
        }];
    } else {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.tableView numberOfRowsInSection:0] > 0) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
    }
}

- (UITableView *)tableView {
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    return _tableView;
}

- (LPSChatKeyBoard *)keyBoard {
    if (!_keyBoard){
        _keyBoard = [[LPSChatKeyBoard alloc] initWithFrame:CGRectZero];
        _keyBoard.delegate = self;
        __weak typeof(self) ws = self;
        [_keyBoard addMoreItemWithTitle:@"照片" imageName:@"input_plug_ico_photo_nor" handler:^{
            [ws showAlertWithTitle:@"你点击了照片按钮"];
        }];
        [_keyBoard addMoreItemWithTitle:@"拍摄" imageName:@"input_plug_ico_camera_nor" handler:^{
            [ws showAlertWithTitle:@"你点击了拍摄按钮"];
        }];
        [_keyBoard addMoreItemWithTitle:@"位置" imageName:@"input_plug_ico_ad_nor" handler:^{
            [ws showAlertWithTitle:@"你点击了位置按钮"];
        }];
    }
    return _keyBoard;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25"]];
    }
    
    return _dataSource;
}

@end
