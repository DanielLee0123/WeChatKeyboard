//
//  LPSMorePanelView.m
//  JobHunter
//
//  Created by Daniel_Lee on 2018/5/19.
//  Copyright © 2018年 Daniel_Lee. All rights reserved.
//

#import "LPSMorePanelView.h"
#import "LPSMorePanelItem.h"
#import "UIView+LPSExtension.h"
#import "UIColor+LPSExtension.h"

#define bottomH  18
#define kMoreItemTag    55555
#define ScreenWidth                             [[UIScreen mainScreen] bounds].size.width
#define kPageItemCount          8

@interface LPSMorePanelView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation LPSMorePanelView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lps_colorWithHexValue:0xffffff];
        [self addSubview:self.topLine];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
    }
    return self;
}

- (void)addMoreContentView:(UIView *)plugin {
    if (plugin != nil) {
        self.contentView = plugin;
        [self addSubview:self.contentView];
        [self bringSubviewToFront:self.contentView];
    }
}

- (void)removeMoreContentView {
    if (self.contentView.superview) {
        [self.contentView removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    self.contentView.frame = self.bounds;
    self.topLine.frame = CGRectMake(0, 0, ScreenWidth, 1/[UIScreen mainScreen].scale);
    [self.scrollView setFrame:CGRectMake(0, self.topLine.frame.size.height, self.frame.size.width,self.frame.size.height-bottomH)];
    [self.pageControl setFrame:CGRectMake(0, self.frame.size.height-bottomH, self.frame.size.width, 8)];
    [self layoutBtns];
}

- (void)addMoreItem:(LPSMorePanelItem *)item
{
    if (item.title.length && item.imageName.length) {
        [self.items addObject:item];
        [item setTag:[self.items indexOfObject:item] + kMoreItemTag];
        [item addTarget:self action:@selector(didSelectedItem:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:item];
        [self setNeedsLayout];
    }
}

- (void)removeMoreItem:(LPSMorePanelItem *)item
{
    if (!self.items.count) {
        return;
    }
    [self.items removeObject:item];
    [self setNeedsLayout];
}

#pragma mark - Public Methods

- (void)layoutBtns
{
    self.pageControl.numberOfPages = self.items.count / kPageItemCount + 1;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.lps_width * (self.items.count / kPageItemCount + 1), _scrollView.lps_height);
    
    float w = self.lps_width * 20 / 21 / 4 * 0.8;
    float space = w / 4;
    float h = (self.lps_height - 20 - space * 2) / 2;
    float x = space, y = space;
    int i = 0, page = 0;
    for (LPSMorePanelItem * item in self.items) {
        [item setFrame:CGRectMake(x, y, w, h)];
        i ++;
        page = i % kPageItemCount == 0 ? page + 1 : page;
        x = (i % 4 ? x + w : page * self.lps_width) + space;
        y = (i % kPageItemCount < 4 ? space : h + space * 1.5);
    }
}

// 点击了某个Item
- (void)didSelectedItem:(LPSMorePanelItem *)sender
{
    LPSMorePanelItem *item = [self.items objectAtIndex:sender.tag-kMoreItemTag];
    void (^handler) (void) = item.handler;
    if (handler) {
        handler();
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / self.lps_width;
    [_pageControl setCurrentPage:page];
}

#pragma mark - Getter and Setter

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setPagingEnabled:YES];
        scrollView.delegate = self;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        _pageControl = pageControl;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor blackColor];
        [_pageControl addTarget:self action:@selector(pageControlClicked:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (UIView *)topLine
{
    if (!_topLine) {
        UIView * topLine = [[UIView alloc] init];
        topLine.backgroundColor = [UIColor lps_colorWithHexValue:0xd8d8d9];
        _topLine = topLine;
    }
    return _topLine;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    
    return _contentView;
}

- (NSMutableArray<LPSMorePanelItem *> *)items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    
    return _items;
}

- (void)pageControlClicked:(UIPageControl *)pageControl
{
    [self.scrollView scrollRectToVisible:CGRectMake(pageControl.currentPage * ScreenWidth, 0, ScreenWidth, self.scrollView.lps_height) animated:YES];
}

@end
