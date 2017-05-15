//
//  PlayerMaskView.h
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSlider.h"

@protocol PlayerMaskViewDelegate <NSObject>
@optional
/**返回按钮代理*/
- (void)cc_backButtonAction:(UIButton *)button;
/**播放按钮代理*/
- (void)cc_playButtonAction:(UIButton *)button;
/**全屏按钮代理*/
- (void)cc_fullButtonAction:(UIButton *)button;
/**开始滑动*/
- (void)cc_progressSliderTouchBegan:(CCSlider *)slider;
/**滑动中*/
- (void)cc_progressSliderValueChanged:(CCSlider *)slider;
/**滑动结束*/
- (void)cc_progressSliderTouchEnded:(CCSlider *)slider;
/**失败按钮代理*/
- (void)cc_failButtonAction:(UIButton *)button;
/**单击*/
- (void)cc_handleSingleTap:(UITapGestureRecognizer *)singleTap;
/**双击*/
- (void)cc_handleDoubleTap:(UITapGestureRecognizer *)doubleTap;

@end
@interface PlayerMaskView : UIView

/**顶部工具条*/
@property (nonatomic,strong) UIView *topToolBar;
/**底部工具条*/
@property (nonatomic,strong) UIView *bottomToolBar;
/**转子*/
@property (nonatomic,strong) UIActivityIndicatorView *activity;
/**顶部工具条返回按钮*/
@property (nonatomic,strong) UIButton *backButton;
/**底部工具条播放按钮*/
@property (nonatomic,strong) UIButton *playButton;
/**底部工具条全屏按钮*/
@property (nonatomic,strong) UIButton *fullButton;
/**视频title*/
@property (nonatomic,strong) UILabel *titleLabel;
/**底部工具条当前播放时间*/
@property (nonatomic,strong) UILabel *currentTimeLabel;
/**底部工具条视频总时间*/
@property (nonatomic,strong) UILabel *totalTimeLabel;
/**缓冲进度条*/
@property (nonatomic,strong) UIProgressView *progress;
/**播放进度条*/
@property (nonatomic,strong) CCSlider *slider;
/**加载失败按钮*/
@property (nonatomic,strong) UIButton *failButton;
/**  */
@property (nonatomic, weak) id<PlayerMaskViewDelegate>delegate;
@end
