//
//  PlayerMaskView.m
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "PlayerMaskView.h"
//间隙
#define Padding        10
//顶部底部工具条高度
#define ToolBarHeight     40
//进度条颜色
#define ProgressColor     [UIColor colorWithRed:0.54118 green:0.51373 blue:0.50980 alpha:1.00000]
//缓冲颜色
#define ProgressTintColor [UIColor orangeColor]
//播放完成颜色
#define PlayFinishColor   [UIColor whiteColor]

@interface PlayerMaskView()
//
@property (nonatomic, strong)NSDateFormatter *dateFormatter;

@end

@implementation PlayerMaskView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        [self initSubviews];
        [self addTapGesture];
        
    }
    return self;
}

- (void)initSubviews
{
    
    [self addSubview:self.topToolBar];
    [self addSubview:self.bottomToolBar];
    [self addSubview:self.activity];
    //[self.topToolBar addSubview:self.backButton];
    [self.topToolBar addSubview:self.titleLabel];
    [self.bottomToolBar addSubview:self.playButton];
    [self.bottomToolBar addSubview:self.fullButton];
    [self.bottomToolBar addSubview:self.currentTimeLabel];
    [self.bottomToolBar addSubview:self.totalTimeLabel];
    [self.bottomToolBar addSubview:self.progress];
    [self.bottomToolBar addSubview:self.slider];
    [self addSubview:self.failButton];
    [self makeConstraints];
    self.topToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    self.bottomToolBar.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
}

- (void)makeConstraints
{
    
    //topView
    [self.topToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    
    //titleLabel
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topToolBar).with.offset(10);
        make.right.equalTo(self.topToolBar).with.offset(-10);
        make.center.equalTo(self.topToolBar);
        make.top.equalTo(self.topToolBar).with.offset(0);
    }];
    
    //bottomView
    [self.bottomToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(ToolBarHeight);
    }];
    
//    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
//    for (UIControl *view in volumeView.subviews) {
//        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
//            self.volumeSlider = (UISlider *)view;
//        }
//    }
    //加载
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    //_fullScreenBtn
    [self.fullButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomToolBar.mas_right).with.offset(-17);
        make.centerY.equalTo(self.bottomToolBar.mas_centerY);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(18);
    }];
    
    //显示左边的时间进度
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomToolBar.mas_left);
        make.centerY.equalTo(self.bottomToolBar);
        make.width.mas_equalTo(59);
    }];

    //显示右边的总时间
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fullButton.mas_left).with.offset(-12);
        make.width.mas_equalTo(59);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    
    //缓冲条
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(16);
        make.height.mas_equalTo(2);
        make.centerY.equalTo(self.bottomToolBar);
    }];
    //滑杆
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.edges.equalTo(self.progress);
        make.left.equalTo(self.progress.mas_left);
        make.right.equalTo(self.progress.mas_right);
        make.centerX.equalTo(self.progress.mas_centerX);
        make.centerY.equalTo(self.progress.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    //失败按钮
    [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}
- (void) addTapGesture
{
    // 单击的 Recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1; // 单击
    singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTap];

    // 双击的 Recognizer
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTouchesRequired = 1; //手指数
    doubleTap.numberOfTapsRequired = 2; // 双击
    // 解决点击当前view时候响应其他控件事件
    [singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击成立，则取消单击手势（双击的时候不回走单击事件）
    [self addGestureRecognizer:doubleTap];
}
#pragma mark - 懒加载
//顶部工具条
- (UIView *) topToolBar{
    if (_topToolBar == nil){
        _topToolBar = [[UIView alloc] init];
        _topToolBar.userInteractionEnabled = YES;
    }
    return _topToolBar;
}
//底部工具条
- (UIView *) bottomToolBar{
    if (_bottomToolBar == nil){
        _bottomToolBar = [[UIView alloc] init];
        _bottomToolBar.userInteractionEnabled = YES;
    }
    return _bottomToolBar;
}
//转子
- (UIActivityIndicatorView *)activity{
    if (_activity == nil){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activity startAnimating];
    }
    return _activity;
}

//返回按钮
- (UIButton *) backButton{
    if (_backButton == nil){
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"CLBackBtn"] forState:UIControlStateNormal];
//        [_backButton setImage:[UIImage getPictureWithName:@"CLBackBtn"] forState:UIControlStateHighlighted];
//        [_backButton addTarget:UIImage action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

//视频标题
- (UILabel*)titleLabel {
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

//播放按钮
- (UIButton *) playButton{
    if (_playButton == nil){
        _playButton = [[UIButton alloc] init];
    }
    return _playButton;
}
//全屏按钮
- (UIButton *) fullButton{
    if (_fullButton == nil){
        _fullButton = [[UIButton alloc] init];
        [_fullButton setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [_fullButton setImage:[UIImage imageNamed:@"nonfullscreen"] forState:UIControlStateSelected];
        [_fullButton addTarget:self action:@selector(fullButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullButton;
}
//当前播放时间
- (UILabel *) currentTimeLabel{
    if (_currentTimeLabel == nil){
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.backgroundColor = [UIColor clearColor];
        _currentTimeLabel.font      = [UIFont systemFontOfSize:11];
        _currentTimeLabel.text      = [self convertTime:0.0];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}
//总时间
- (UILabel *) totalTimeLabel{
    if (_totalTimeLabel == nil){
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.backgroundColor = [UIColor clearColor];
        _totalTimeLabel.font      = [UIFont systemFontOfSize:11];
        _totalTimeLabel.text      = [self convertTime:0.0];
        _totalTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _totalTimeLabel;
}
//缓冲条
- (UIProgressView *) progress{
    if (_progress == nil){
        _progress = [[UIProgressView alloc] init];
        _progress.backgroundColor = [UIColor blueColor];
//        _progress.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
//        _progress.trackTintColor = [UIColor clearColor];
        _progress.trackTintColor = ProgressColor;
        _progress.progressTintColor = ProgressTintColor;
    }
    return _progress;
}
//滑动条
- (CCSlider *) slider{
    if (_slider == nil){
        _slider = [[CCSlider alloc] init];
        // slider开始滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        // slider滑动中事件
        [_slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        // slider结束滑动事件
        [_slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        _slider.minimumTrackTintColor = [UIColor greenColor];
        _slider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        
        //左边颜色
        //_slider.minimumTrackTintColor = PlayFinishColor;
        //右边颜色
        //_slider.maximumTrackTintColor = [UIColor clearColor];
    }
    return _slider;
}
//加载失败按钮
- (UIButton *) failButton
{
    if (_failButton == nil) {
        _failButton = [[UIButton alloc] init];
        _failButton.hidden = YES;
        [_failButton setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failButton.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
        [_failButton addTarget:self action:@selector(failButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _failButton;
}

#pragma mark - 按钮点击事件
//返回按钮
- (void)backButtonAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(cc_backButtonAction:)]) {
        [_delegate cc_backButtonAction:button];
    }else{
        NSLog(@"没有实现代理");
    }
}
//播放按钮
- (void)playButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cc_playButtonAction:)]) {
        [_delegate cc_playButtonAction:button];
    }else{
        NSLog(@"没有实现代理");
    }
}
//全屏按钮
- (void)fullButtonAction:(UIButton *)button{
    button.selected = !button.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(cc_fullButtonAction:)]) {
        [_delegate cc_fullButtonAction:button];
    }else{
        NSLog(@"没有实现代理");
    }
}

//失败按钮
- (void)failButtonAction:(UIButton *)button{
    self.failButton.hidden = YES;
    [self.activity startAnimating];
    if (_delegate && [_delegate respondsToSelector:@selector(cc_failButtonAction:)]) {
        [_delegate cc_failButtonAction:button];
    }else{
        NSLog(@"没有实现代理");
    }
}
#pragma mark - 滑杆
//开始滑动
- (void)progressSliderTouchBegan:(CCSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cc_progressSliderTouchBegan:)]) {
        [_delegate cc_progressSliderTouchBegan:slider];
    }else{
        NSLog(@"没有实现代理");
    }
}
//滑动中
- (void)progressSliderValueChanged:(CCSlider *)slider{
    if (_delegate && [_delegate respondsToSelector:@selector(cc_progressSliderValueChanged:)]) {
        [_delegate cc_progressSliderValueChanged:slider];
    }else{
        NSLog(@"没有实现代理");
    }
}
//滑动结束
- (void)progressSliderTouchEnded:(CCSlider *)slider{
    
    if (_delegate && [_delegate respondsToSelector:@selector(cc_progressSliderTouchEnded:)]) {
        [_delegate cc_progressSliderTouchEnded:slider];
    }else{
        NSLog(@"没有实现代理");
    }
}

// 单击手势方法(隐藏或者显示工具栏)
- (void)handleSingleTap:(UITapGestureRecognizer *)singleTap
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cc_handleSingleTap:)]){
        [self.delegate cc_handleSingleTap:singleTap];
    }
    
}
// 双击手势方法(暂停方法)
- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cc_handleDoubleTap:)]){
        [self.delegate cc_handleDoubleTap:doubleTap];
    }
}

#pragma mark -- 私有方法  --
- (NSString *)convertTime:(float)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:d];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}

@end
