//
//  PlayItem.h
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoItem.h"
@class PlayItem;
@protocol PlayItemDelegate <NSObject>

- (void)playItem:(PlayItem*)playItem startPlayVideo:(UIButton *)sender;

@end

@interface PlayItem : UITableViewCell
/**  */
@property (nonatomic, weak) id<PlayItemDelegate>delegate;
/**   */
@property (nonatomic, strong) UIButton *playBtn;
/**   */
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
/** 图  */
@property (strong, nonatomic) UIImageView *backgroundImage;

@property (nonatomic, strong) VideoItem *videoModel;

- (void) refreshItemWithVideoItem:(VideoItem *)videoModel  indexPath:(NSIndexPath *)indexPath;
/**
 *  释放WMPlayer
 */

@end
