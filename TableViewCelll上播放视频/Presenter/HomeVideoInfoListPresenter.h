//
//  HomeVideoInfoListPresenter.h
//  TableViewCelll上播放视频
//
//  Created by changcai on 17/5/9.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VideoItem;
@class SidModel;
@protocol HomeVideoInfoListPresenterDelegate <NSObject>

- (void) acquireHomeVideoListSuccess:(NSArray <VideoItem *> *)videoList;

- (void) acquireHomeVideoSidListSuccess:(NSArray <SidModel *> *)videoSidList;

- (void) acquireHomeVideoInfoListFailed;
@end

@interface HomeVideoInfoListPresenter : NSObject


/**  */
@property (nonatomic, weak) id<HomeVideoInfoListPresenterDelegate>delegate;
- (void) acquireHomeVideoInfoListWithUrl:(NSString *)url  parameters:(id)parameters;
- (void)getVideoMoreListWithURLString:(NSString *)URLString ListID:(NSString *)ID;
@end
