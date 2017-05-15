//
//  PlayerView.m
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "PlayerView.h"
#import "PlayerMaskView.h"
static void *PlayViewStatusObservationContext = &PlayViewStatusObservationContext;
@interface PlayerView()<UIGestureRecognizerDelegate,PlayerMaskViewDelegate>
{
    //用来判断手势是否移动过
    BOOL _hasMoved;
    //记录触摸开始时的视频播放的时间
    float _touchBeginValue;
    //记录触摸开始亮度
    float _touchBeginLightValue;
    //记录触摸开始的音量
     float _touchBeginVoiceValue;
}
/** 是否初始化了播放器 */
@property (nonatomic, assign) BOOL  isUserPlay;
/**全屏标记*/
@property (nonatomic,assign) BOOL   isFullScreen;
///记录touch开始的点
@property (nonatomic,assign)CGPoint touchBeginPoint;
//视频进度条的单击事件
@property (nonatomic, strong) UITapGestureRecognizer *tap;
///声音滑块
@property (nonatomic,strong) UISlider  *volumeSlider;
//监听播放起状态的监听者
@property (nonatomic ,strong) id playbackTimeObserver;
//
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
//是否点击了按钮的响应事件
@property (nonatomic, assign) BOOL isDragingSlider;

/**控件原始Farme*/
@property (nonatomic,assign) CGRect customFarme;
/**父类控件*/
@property (nonatomic,strong) UIView *fatherView;

@end

@implementation PlayerView

#pragma mark -- Lazy loading --
- (PlayerMaskView*)playerMaskView {
    if (!_playerMaskView) {
        _playerMaskView = [[PlayerMaskView alloc] init];
        _playerMaskView.delegate = self;
    }
    return _playerMaskView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]){
        self.userInteractionEnabled = YES;
        //[self addApplicationStatusNotification];
        [self constructUI];
    }
    return self;
}

-(void)constructUI
{
    [self addSubview:self.playerMaskView];
}

- (void)addApplicationStatusNotification
{
    //开启
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //注册屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)initPlayer
{
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
    [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
}


#pragma mark -- app活动状态  NSNotification --
// 进入后台
- (void)appDidEnterBackground:(NSNotification*)note
{
    //将要挂起，停止播放
    [self pause];
}
// 进入前台
- (void)appWillEnterForeground:(NSNotification*)note
{
    //继续播放
    if (_isUserPlay) {
        [self play];
    }
}
//屏幕旋转通知
- (void)orientChange:(NSNotification *)notification{
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft){
        if (_isFullScreen == NO){
            [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
        }
    }
    else if (orientation == UIDeviceOrientationLandscapeRight){
        if (_isFullScreen == NO){
            [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
        }
    }
    else if (orientation == UIDeviceOrientationPortrait){
        if (_isFullScreen == YES){
            [self originalscreen];
        }
    }
}
#pragma mark -- KVO 监听视频的播放状态 播放进度 播放总时长 ---
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context == PlayViewStatusObservationContext)
    {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status)
            {
                case AVPlayerStatusReadyToPlay:
                {
                    self.state = PlayerStatePlaying;
                    //5s dismiss bottomView
                    if (self.autoDismissTimer==nil) {
                        self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                    }
                    // 跳到xx秒播放视频
                    if (self.seekTime) {
                        [self seekToTimeToPlay:self.seekTime];
                    }
                }
                    break;
                    
                case AVPlayerStatusFailed:
                {
                    self.state = PlayerStateFailed;
                    if (self.delegate &&[self.delegate respondsToSelector:@selector(playerFailedPlay:playerStatus:)]) {
                        [self.delegate playerFailedPlay:self playerStatus:PlayerStateFailed];
                    }
                    NSError *error = [self.player.currentItem error];
                    if (error) {
                        self.playerMaskView.failButton.hidden = NO;
                    }
                }
                    break;
            }
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.currentItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            [self.playerMaskView.progress setProgress:timeInterval/totalDuration animated:NO];
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.currentItem.playbackBufferEmpty) {
                self.state = PlayerStateBuffering;
                [self loadedTimeRanges];
            }
            
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            // 当缓冲好的时候
            if (self.currentItem.playbackLikelyToKeepUp && self.state == PlayerStateBuffering){
                self.state = PlayerStatePlaying;
            }
        }
    }
}
/**
 *  缓冲较差时候回调这里
 */
- (void)loadedTimeRanges
{
    self.state = PlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (!self.isUserPlay) {
            isBuffering = NO;
            return;
        }
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.currentItem.isPlaybackLikelyToKeepUp) {
            [self loadedTimeRanges];
        }
    });
}

#pragma mark-- 播放完成 --
- (void)moviePlayDidEnd:(NSNotification *)notification {
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(playerFinishedPlay:)]) {
        [self.delegate playerFinishedPlay:self];
    }
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.state = PlayerStateStopped;
            });
        }
    }];
}
#pragma mark - 关闭按钮点击func
///获取视频长度
- (double)duration{
    AVPlayerItem *playerItem = self.player.currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return CMTimeGetSeconds([[playerItem asset] duration]);
    }
    else{
        return 0.f;
    }
}

#pragma mark --  EventAction --
///播放
-(void)play{
    
    if (self.state == PlayerStatePause) {
        self.state = PlayerStatePlaying;
    }
    _isUserPlay = YES;
    [self.player play];
}
///暂停
-(void)pause{
    if (self.state == PlayerStatePlaying) {
        self.state = PlayerStatePause;
    }
    [self.player pause];
}
//重新开始播放
- (void)resetPlay{
    [_player seekToTime:CMTimeMake(0, 1)];
    [self play];
}

//视频进度条的点击事件
- (void)actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self.playerMaskView.slider];
    CGFloat value = (self.playerMaskView.slider.maximumValue - self.playerMaskView.slider.minimumValue) * (touchLocation.x/self.playerMaskView.slider.frame.size.width);
    [self.playerMaskView.slider setValue:value animated:YES];
    [self.player seekToTime:CMTimeMakeWithSeconds(self.playerMaskView.slider.value, self.currentItem.currentTime.timescale)];
    if (self.player.rate != 1.f) {
        if ([self currentTime] == [self duration])
            [self setCurrentTime:0.f];
        //self.playOrPauseBtn.selected = NO;
        [self.player play];
    }
}


#pragma mark  -- 私有方法 --

///获取视频当前播放的时间
- (double)currentTime{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else{
        return 0.0;
    }
}

- (void)setCurrentTime:(double)time{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.currentItem.currentTime.timescale)];
        
    });
}


//5s后自动隐藏工具栏
-(void)autoDismissBottomView:(NSTimer *)timer{
    if (self.state == PlayerStatePlaying) {
        if (self.playerMaskView.bottomToolBar.alpha == 1.0 || self.playerMaskView.topToolBar.alpha == 1.0) {
            [self hiddenControlView];//隐藏操作栏
        }
    }
}
//显示操作栏view
-(void)showControlView{
    [UIView animateWithDuration:0.5 animations:^{
        self.playerMaskView.topToolBar.alpha = 1.0;
        self.playerMaskView.bottomToolBar.alpha = 1.0;
    } completion:^(BOOL finish){
        
    }];
}
///隐藏操作栏view
-(void)hiddenControlView{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.playerMaskView.topToolBar.alpha = 0.0;
        self.playerMaskView.bottomToolBar.alpha = 0.0;
        
    } completion:^(BOOL finish){
        
        
    }];
}

//给AVPlayer添加时间观察者
-(void)createTimer{
    __weak typeof(self) weakSelf = self;
    //给AVPlayer添加时间观察者有利于我们去检测播放进度
    self.playbackTimeObserver =  [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)  queue:dispatch_get_main_queue() /* If you pass NULL, the main queue is used.*/
                                                                          usingBlock:^(CMTime time){
                                                                              [weakSelf syncScrubber];
                                                                          }];
}

//定时刷新播放时间值
- (void)syncScrubber{

    if (_currentItem.duration.timescale != 0){
        //总共时长
        self.playerMaskView.slider.maximumValue = 1;
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        //duration 总时长
        NSInteger durMin = (NSInteger)_currentItem.duration.value / _currentItem.duration.timescale / 60;//总分钟
        NSInteger durSec = (NSInteger)_currentItem.duration.value / _currentItem.duration.timescale % 60;//总秒
        if(!self.isDragingSlider ){//没有被拖拽
            //当前进度
            self.playerMaskView.slider.value        = CMTimeGetSeconds([_currentItem currentTime]) / (_currentItem.duration.value / _currentItem.duration.timescale);
            self.playerMaskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        }
        self.playerMaskView.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
}


/**
 *  跳到time处播放
 *  seekTime这个时刻，这个时间点
*/
- (void)seekToTimeToPlay:(double)time{
    CGFloat totalTime = (CGFloat)_currentItem.duration.value/_currentItem.duration.timescale;
    if (self.player && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (time >= totalTime) {
            time = 0.0;
        }
        if (time < 0) {
            time=0.0;
        }
        // int32_t timeScale = self.player.currentItem.asset.duration.timescale;
        //currentItem.asset.duration.timescale计算的时候严重堵塞主线程，慎用
        /* A timescale of 1 means you can only specify whole seconds to seek to. The timescale is the number of parts per second. Use 600 for video, as Apple recommends, since it is a product of the common video frame rates like 50, 60, 25 and 24 frames per second*/
        [self.player seekToTime:CMTimeMakeWithSeconds(time, _currentItem.currentTime.timescale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
        }];
    }
}

- (CMTime)playerItemDuration{
    AVPlayerItem *playerItem = _currentItem;
    if (playerItem.status == AVPlayerItemStatusReadyToPlay){
        return([playerItem duration]);
    }
    return(kCMTimeInvalid);
}

- (NSString *)convertTime:(float)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:d];
}
/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}

#pragma mark -- 屏幕旋转 --

//全屏显示
- (void)fullScreenWithDirection:(UIInterfaceOrientation )interfaceOrientation{
    if (self.screenState!= MovieViewStateSmall) {
        return;
    }
     self.screenState = MovieViewStateAnimating;
    //记录播放器父类
    _fatherView = self.superview;
    //记录原始大小
    _customFarme = self.frame;
    [self setStatusBarHidden:YES];
    [self removeFromSuperview];
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    __block CGFloat angle = 0.0;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        [UIView animateWithDuration:0.25 animations:^{
            angle = M_PI / 2;
        }];
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [UIView animateWithDuration:0.25 animations:^{
             angle =  - M_PI / 2;
        }];
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeRotation(angle);
        self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        
    } completion:^(BOOL finished) {
        self.screenState = MovieViewStateFullscreen;
    }];

    self.playerMaskView.fullButton.selected = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

//原始大小
- (void)originalscreen{
    
    if (self.screenState != MovieViewStateFullscreen) {
        return;
    }
    self.screenState = MovieViewStateAnimating;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [self setStatusBarHidden:NO];
   
    [UIView animateWithDuration:0.25 animations:^{
        //还原
        self.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.screenState = MovieViewStateSmall;
    }];
    self.frame = _customFarme;
    //还原到原有父类上
    [_fatherView addSubview:self];
    self.playerMaskView.fullButton.selected = NO;
}
/** 转换播放时间和总时间的方法 */
-(NSString *)timeToStringWithTimeInterval:(NSTimeInterval)interval;
{
    NSInteger Min = interval / 60;
    NSInteger Sec = (NSInteger)interval % 60;
    NSString *intervalString = [NSString stringWithFormat:@"%02ld:%02ld",Min,Sec];
    return intervalString;
}
#pragma mark - 隐藏或者显示状态栏方法
- (void)setStatusBarHidden:(BOOL)hidden{
    //取出当前控制器的导航条
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    //设置是否隐藏
    statusBar.hidden  = hidden;
}

#pragma mark -- setter/getter --

//播放url
- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = videoUrl;
    [self configPlayer];
}

- (void)configPlayer {
    //设置player的参数
    self.currentItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:_videoUrl]];
    // 每次都重新创建Player，替换replaceCurrentItemWithPlayerItem:，该方法阻塞线程
    self.player = [AVPlayer playerWithPlayerItem:_currentItem];
    // 初始化playerLayer
    self.playerLayer = [AVPlayerLayer  playerLayerWithPlayer:self.player];
    //Player视频的默认填充模式，AVLayerVideoGravityResizeAspect
    self.playerLayer.videoGravity = self.videoGravity;
    [self initPlayer];
    if ([self.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    self.player.usesExternalPlaybackWhileExternalScreenIsActive=YES;
    // 添加播放进度计时器
    [self createTimer];
    self.playerLayer.frame = self.playerMaskView.bounds;
    [self.playerMaskView.layer insertSublayer:_playerLayer atIndex:0];
    
}
- (NSString *)videoGravity {
    if (!_videoGravity) {
        _videoGravity = AVLayerVideoGravityResize;
    }
    return _videoGravity;
}
//播放状态
- (void) setState:(PlayerState)state
{
    _state = state;
    // 控制菊花显示、隐藏
    if (state == PlayerStateBuffering) {
        
        [self.playerMaskView.activity startAnimating];
        
    }else if(state == PlayerStatePlaying){
        
       [self.playerMaskView.activity stopAnimating];//
        
    }else if(state == PlayerStatePause){
        
      [self.playerMaskView.activity stopAnimating];//
        
    }else{
        
       [self.playerMaskView.activity stopAnimating];//
    }
}

/**
 *  重写playerItem的setter方法，处理自己的逻辑
*/

- (void) setCurrentItem:(AVPlayerItem *)currentItem
{
    if (_currentItem == currentItem) {
        return;
    }
    if (_currentItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        [_currentItem removeObserver:self forKeyPath:@"status"];
        [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        _currentItem = nil;
    }
    _currentItem = currentItem;
    if (_currentItem) {
        //播放状态 AVPlayerItemStatusUnknown AVPlayerItemStatusReadyToPlay AVPlayerItemStatusFailed
        [_currentItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
        //通常情况下,在加载网络视频时,我们需要获取视频的缓冲进度,这时候,我们可以通过监听AVPlayerItem的loadedTimeRanges状态,获取缓冲进度
        [_currentItem addObserver:self
                       forKeyPath:@"loadedTimeRanges"
                          options:NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
        // 缓冲区空了,需要等待数据
        [_currentItem addObserver:self
                       forKeyPath:@"playbackBufferEmpty"
                          options: NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
        // 缓冲区有足够数据可以播放了
        [_currentItem addObserver:self
                       forKeyPath:@"playbackLikelyToKeepUp"
                          options: NSKeyValueObservingOptionNew
                          context:PlayViewStatusObservationContext];
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    }
}

//重置播放器
-(void )resetPlayer{
    
}


//获取当前的旋转状态
+(CGAffineTransform)getCurrentDeviceOrientation{
    //状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation ==UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation ==UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if(orientation ==UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark  -- PlayerMaskViewDelegate --
#pragma mark - 拖动进度条
//开始拖拽
-(void)cc_progressSliderTouchBegan:(CCSlider *)slider{
    self.isDragingSlider = YES;
}
//拖拽结束，播放拖拽时间的视频
-(void)cc_progressSliderTouchEnded:(CCSlider *)slider{
    
    self.isDragingSlider = NO;
    //计算出拖动的当前秒数
    CGFloat total = (CGFloat)_currentItem.duration.value / _currentItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime  = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime];
    
}
//拖拽中,不需要播放视频(需要改变当前时间)
-(void)cc_progressSliderValueChanged:(CCSlider *)slider{
    self.isDragingSlider = YES;
    // 计算slider拖动的点对应的播放时间
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * slider.value;
    self.playerMaskView.currentTimeLabel.text = [self timeToStringWithTimeInterval:currentTime];
}

#pragma mark - 操作按钮 -
// 播放暂停按钮方法
-(void)cc_playButtonAction:(UIButton *)button{
    
    
    
}
//全屏按钮响应事件
-(void)cc_fullButtonAction:(UIButton *)button{

    if (self.screenState == MovieViewStateSmall){
        [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
    }
    else if (self.screenState == MovieViewStateFullscreen){
        [self originalscreen];
    }
}

//播放失败按钮点击事件
-(void)cc_failButtonAction:(UIButton *)button{
    [self setVideoUrl:_videoUrl];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

// 单击手势方法(隐藏或者显示工具栏)
- (void)cc_handleSingleTap:(UITapGestureRecognizer *)singleTap
{
//销毁定时器
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    //重新创建定时器
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.playerMaskView.bottomToolBar.alpha == 0.0 || self.playerMaskView.topToolBar.alpha == 0.0) {
            [self showControlView];
        }else{
            [self hiddenControlView];
        }
    } completion:^(BOOL finish){
        
    }];
}
// 双击手势方法(暂停方法)
- (void)cc_handleDoubleTap:(UITapGestureRecognizer *)doubleTap
{
    if(self.state == PlayerStatePlaying ||  self.state == PlayerStateBuffering || self.state == PlayerStateFailed){
        [self pause];
    }else{
        [self play];
    }
    [self showControlView];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.playerMaskView.frame = self.bounds;
}

//销毁播放器
- (void)destroyPlayer{
    [self setStatusBarHidden:NO];
    self.seekTime = 0;
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //销毁定时器
    [self destroyTimer];
    //暂停
    [_player pause];
    //清除
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    // 移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    // 把player置为nil
    self.player = nil;
    self.currentItem = nil;
    //移除
    [self removeFromSuperview];
    
}
//销毁所有定时器
- (void)destroyTimer{
    if(_autoDismissTimer){
        [_autoDismissTimer invalidate];
        _autoDismissTimer = nil;
    }
}

- (void)dealloc{
    
    NSLog(@"Player dealloc");
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player pause];
    [self.player removeTimeObserver:self.playbackTimeObserver];
    //移除观察者
    [_currentItem removeObserver:self forKeyPath:@"status"];
    [_currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    _currentItem = nil;
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;
    self.playerLayer = nil;
    [self destroyTimer];
    
}

@end
