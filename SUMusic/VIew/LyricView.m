//
//  LyricView.m
//  SUMusic
//
//  Created by 万众科技 on 16/1/26.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "LyricView.h"

#define LycRowH 40.0

@interface LyricView ()<UITableViewDataSource,UITableViewDelegate> {
    
    UITableView * _tableView;
    NSMutableArray * _timeSource;
    NSMutableArray * _lycSource;
    
    BOOL _isCheck;
    BOOL _isShow;
    
    NSTimer * _timer;
}


@end

@implementation LyricView

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _isCheck = NO;
    _isShow = NO;
    _timeSource = [NSMutableArray array];
    _lycSource = [NSMutableArray array];
    
    _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.contentInset = UIEdgeInsetsMake(self.h / 2 - LycRowH / 2, 0, self.h / 2 - LycRowH / 2, 0);
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = LycRowH;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    [self addSubview:_tableView];
}

- (void)loadLyric:(NSDictionary *)dict {
    
    //状态
    _isCheck = YES;
    
    if (dict == nil) {
        
        //show no lyric
        
        
    }else {
        
        for (NSString * key in dict) {
            [_timeSource addObject:key];
            [_lycSource addObject:dict[key]];
        }
        //排序
        for (int i = 0; i < _timeSource.count - 1; i ++) {
            for (int j = i + 1; j < _timeSource.count; j ++) {
                if ([_timeSource[i] intValue] > [_timeSource[j] intValue]) {
                    [_timeSource exchangeObjectAtIndex:i withObjectAtIndex:j];
                    [_lycSource exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
        [_tableView reloadData];
    }
    
}

- (void)clearLyric {
    _isCheck = NO;
    [_timeSource removeAllObjects];
    [_lycSource removeAllObjects];
    [_tableView reloadData];
}

- (void)showInView:(UIView *)sender {
    _isShow = YES;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(scrollLyric) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [sender addSubview:self];
}

- (void)hide {
    _isShow = NO;
    
    [_timer invalidate];
    _timer = nil;
    
    [self removeFromSuperview];
}

- (BOOL)checkLyric {
    return _isCheck;
}

- (BOOL)checkShow {
    return _isShow;
}

#pragma mark - scroll lyric
- (void)scrollLyric {
    
    NSString * secNow = [AppDelegate delegate].player.playTime;
    for (int i = 0; i < _timeSource.count; i ++) {
        if ([_timeSource[i] isEqualToString:secNow]) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            //滚动
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //突出显示
            UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
            UILabel * lyc = (UILabel *)[cell.contentView viewWithTag:666];
            lyc.font = [UIFont systemFontOfSize:18];
            lyc.textColor = BaseColor;
            //恢复
            if (i > 0) {
                NSIndexPath * lastIndexPath = [NSIndexPath indexPathForRow:i - 1 inSection:0];
                UITableViewCell * cell = [_tableView cellForRowAtIndexPath:lastIndexPath];
                UILabel * lyc = (UILabel *)[cell.contentView viewWithTag:666];
                lyc.font = [UIFont systemFontOfSize:15];
                lyc.textColor = [UIColor grayColor];
            }
            break;
        }
    }
}


#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timeSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * aCellID = @"lyricCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:aCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aCellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.w, 40)];
        label.font = [UIFont systemFontOfSize:15];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 666;
        [cell.contentView addSubview:label];
    }
    UILabel * lyc = (UILabel *)[cell.contentView viewWithTag:666];
    lyc.textColor = [UIColor grayColor];
    lyc.text = _lycSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hide];
}

@end
