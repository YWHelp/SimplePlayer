//
//  HomeViewController.m
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "HomeViewController.h"
#import "PlayItem.h"
#import "PlayPreviewController.h"
#import "VideoItem.h"
#import "HomeVideoInfoListPresenter.h"
static NSString *const playItemCellIdentifier = @"playItemCellIdentifier";
@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource,HomeVideoInfoListPresenterDelegate,PlayItemDelegate,PlayerViewDelegate>

/**   */
@property (nonatomic, strong)UITableView *tableView;

/**数据源*/
@property(nonatomic,copy)NSMutableArray<SidModel*> *sidArray;
@property(nonatomic,copy)NSMutableArray<VideoItem*> *videoArray;
/**   */
@property (nonatomic, strong) HomeVideoInfoListPresenter *presenter;
/**  */
@property (nonatomic, assign) NSInteger pageCount;
/**player*/
@property (nonatomic,weak) PlayerView *playerView;
/**记录Cell*/
@property (nonatomic,assign) PlayItem *currentCell;


@end

@implementation HomeViewController{
    NSIndexPath *currentIndexPath;;
}

#pragma mark -- Lazy loading --
- (NSMutableArray*)videoArray {
    if (!_videoArray) {
        _videoArray = [NSMutableArray array];
    }
    return _videoArray;
}

- (NSMutableArray*)sidArray {
    if (!_sidArray) {
        _sidArray = [NSMutableArray array];
    }
    return _sidArray;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //旋转屏幕通知
    self.title = @"视频";
    [self constructUI];
    self.presenter = [[HomeVideoInfoListPresenter alloc]init];
    self.presenter.delegate = self;
    [self.presenter acquireHomeVideoInfoListWithUrl:@"http://c.m.163.com/nc/video/home/0-10.html" parameters:nil];
    [self addMJRefresh];

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:17.0],NSFontAttributeName ,nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)constructUI
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    [self.tableView registerClass:[PlayItem class] forCellReuseIdentifier:playItemCellIdentifier];
}

#pragma mark  --UITableViewDelegate/UITableViewDataSource ----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.videoArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayItem *cell = (PlayItem*)[self.tableView dequeueReusableCellWithIdentifier:playItemCellIdentifier];
    cell.delegate = self;
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
     VideoItem *videoModel = [self.videoArray objectAtIndex:indexPath.section];
     PlayItem * myCell = (PlayItem *)cell;
     [myCell refreshItemWithVideoItem:videoModel indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayPreviewController *playerVc = [[PlayPreviewController alloc]init];
    playerVc.videoUrl = @"";
    [self.navigationController pushViewController:playerVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 10)];
    headerView.backgroundColor = [UIColor redColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001f;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoItem *videoModel = [self.videoArray objectAtIndex:indexPath.section];
    if(videoModel.descriptionDe.length > 0){
      return 220 + 69;
    }else{
       return 220 + 69-17-8;
    }
}
#pragma mark scrollView delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.tableView){
        if (_playerView == nil) {
            return;
        }
        NSArray *indexpaths = [self.tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath] && currentIndexPath != nil){
            //[cell removePlayer];
            //if(_playerView){
                [_playerView destroyPlayer];
                _playerView = nil;
           // }
          [self.currentCell.contentView bringSubviewToFront:self.currentCell.playBtn];
        }
    }
}

#pragma  mark  -- HomeVideoInfoListPresenterDelegate --

- (void) acquireHomeVideoSidListSuccess:(NSArray<SidModel *> *)videoSidList
{
    self.sidArray = [videoSidList copy];
    [self.tableView.mj_header beginRefreshing];
}

- (void) acquireHomeVideoListSuccess:(NSArray<VideoItem *> *)videoList
{
    [self endMJRefresh];
    if(videoList.count > 0){
        if(self.pageCount == 0){
          [self.videoArray removeAllObjects];
          [self.videoArray addObjectsFromArray:videoList];
        }else{
            [self.videoArray addObjectsFromArray:videoList];
            if(videoList.count >= 10)
            {
                [self.tableView.mj_footer endRefreshing];
            }
            else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
    [self.tableView reloadData];
    
}
- (void) acquireHomeVideoInfoListFailed
{
    [self.tableView.mj_header endRefreshing];
}

#pragma mark -- PlayItemDelegate --

- (void) playItem:(PlayItem *)playItem startPlayVideo:(UIButton *)sender
{
    
    currentIndexPath = playItem.currentIndexPath;
    //销毁播放器
    if(_playerView){
       //先将之前的播放按钮提到最前面
       [self.currentCell.contentView  bringSubviewToFront:self.currentCell.playBtn];
       [_playerView destroyPlayer];
       _playerView = nil;
    }
    //记录被点击的Cell
    self.currentCell = playItem;
    PlayerView *playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, playItem.backgroundImage.bounds.size.width, playItem.backgroundImage.bounds.size.height)];
    playerView.delegate = self;
    _playerView = playerView;
    [self.currentCell.backgroundImage addSubview:_playerView];
    [self.currentCell.backgroundImage bringSubviewToFront:_playerView];
    //将playBtn显示在最后
    [self.currentCell.contentView  sendSubviewToBack:sender];
    _playerView.playerMaskView.titleLabel.text = playItem.videoModel.title;
    //视频地址
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _playerView.videoUrl = playItem.videoModel.mp4_Hd_url.length > 0 ? playItem.videoModel.mp4_Hd_url:playItem.videoModel.mp4_url;
        //播放
        [_playerView play];
    });
}


#pragma mark -- PlayerViewDelegate  --
- (void) playerFinishedPlay:(PlayerView *)player
{
    //销毁播放器
    if(player.screenState == MovieViewStateFullscreen){
        
        
        
    }else{
        
        
    }
    
    if(_playerView){
        [_playerView destroyPlayer];
        _playerView = nil;
    }
    [self.currentCell.contentView bringSubviewToFront:self.currentCell.playBtn];
}

#pragma mark --

-(void)addMJRefresh
{
    __weak __typeof(self)weakSelf = self;
    __unsafe_unretained UITableView *tableView = self.tableView;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.pageCount = 0;
        SidModel *sidModl = weakSelf.sidArray[2];
        [self.presenter getVideoMoreListWithURLString:[NSString stringWithFormat:@"http://c.3g.163.com/nc/video/list/%@/y/0-10.html",sidModl.sid] ListID:sidModl.sid];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.pageCount++;
        SidModel *sidModl = weakSelf.sidArray[2];
        NSString *URLString = [NSString stringWithFormat:@"http://c.3g.163.com/nc/video/list/%@/y/%ld-10.html",sidModl.sid,self.videoArray.count - self.videoArray.count%10];
        [self.presenter getVideoMoreListWithURLString:URLString ListID:sidModl.sid];
    }];
}

- (void)endMJRefresh
{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

@end
