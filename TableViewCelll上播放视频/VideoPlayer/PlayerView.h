//
//  PlayerView.h
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class PlayerView;
#import "PlayerMaskView.h"
;
// 播放器的几种状态
typedef NS_ENUM(NSInteger, PlayerState) {
    PlayerStateFailed,     // 播放失败
    PlayerStateBuffering,  // 缓冲中
    PlayerStatePlaying,    // 播放中
    PlayerStateStopped,    //暂停播放
    PlayerStatePause,      // 暂停播放
};


//屏幕播放状态
typedef NS_ENUM(NSUInteger, MovieViewState) {
    MovieViewStateSmall,//小屏模式
    MovieViewStateAnimating,
    MovieViewStateFullscreen,
};

//手势操作的类型
typedef NS_ENUM(NSUInteger,GesturesControlType) {
    progressControl,//视频进度调节操作
    voiceControl,//声音调节操作
    lightControl,//屏幕亮度调节操作
    noneControl//无任何操作
} ;


@protocol PlayerViewDelegate <NSObject>

///播放器事件
//点击播放暂停按钮代理方法
-(void)player:(PlayerView *)player  clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn;
//点击关闭按钮代理方法
-(void)player:(PlayerView *)player clickedCloseButton:(UIButton *)closeBtn;
//点击全屏按钮代理方法
-(void)player:(PlayerView *)player clickedFullScreenButton:(UIButton *)fullScreenBtn;
//单击WMPlayer的代理方法
-(void)player:(PlayerView *)player singleTaped:(UITapGestureRecognizer *)singleTap;
//双击WMPlayer的代理方法
-(void)player:(PlayerView *)player doubleTaped:(UITapGestureRecognizer *)doubleTap;
//WMPlayer的的操作栏隐藏和显示
-(void)player:(PlayerView *)player isHiddenTopAndBottomView:(BOOL )isHidden;
//播放失败的代理方法
-(void)playerFailedPlay:(PlayerView *)player playerStatus:(PlayerState)state;
//准备播放的代理方法
-(void)playerReadyToPlay:(PlayerView *)player playerStatus:(PlayerState)state;
//播放完毕的代理方法
-(void)playerFinishedPlay:(PlayerView *)player;
@end

@interface PlayerView : UIView
/**
 *  设置播放视频的USRLString，可以是本地的路径也可以是http的网络路径
 */
@property (nonatomic,strong) NSString *videoUrl;
/**
 *  播放器player
 */
@property (nonatomic,retain ) AVPlayer  *player;

/**
 *playerLayer,可以修改frame
 */
@property (nonatomic,strong ) AVPlayerLayer  *playerLayer;
@property (nonatomic, strong) AVURLAsset     *urlAsset;
/**
 工具栏
 */
@property (nonatomic,strong ) PlayerMaskView *playerMaskView;

/**
 ＊  播放器状态
 */
@property (nonatomic, assign) PlayerState   state;
/**
 ＊  屏幕状态
 */
@property (nonatomic, assign) MovieViewState screenState;

/**
 *  当前播放的item
 */
@property (nonatomic, retain) AVPlayerItem   *currentItem;
/**
 *  定时器
 */
@property (nonatomic, retain) NSTimer  *autoDismissTimer;
/**
 *  跳到time处播放
 */
@property (nonatomic, assign) double  seekTime;
/** 视频填充模式 */
@property (nonatomic, copy) NSString  *videoGravity;

/** 播放代理 */
@property (nonatomic, weak) id<PlayerViewDelegate>delegate;

/**
 *  播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/**
 *  获取正在播放的时间点
 *
 *  @return double的一个时间点
 */
- (double)currentTime;

/**
 * 重置播放器
 */
- (void )resetPlayer;
/** 销毁播放器 */
- (void)destroyPlayer;

//获取当前的旋转状态
+(CGAffineTransform)getCurrentDeviceOrientation;
@end
