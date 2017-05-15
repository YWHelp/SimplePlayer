//
//  HomeVideoInfoListPresenter.m
//  TableViewCelll上播放视频
//
//  Created by changcai on 17/5/9.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "HomeVideoInfoListPresenter.h"
#import "NetworkManager.h"
#import "VideoItem.h"
#import "SidModel.h"
@implementation HomeVideoInfoListPresenter

- (void) acquireHomeVideoInfoListWithUrl:(NSString *)url  parameters:(id)parameters
{
    NetworkManager *manager = [NetworkManager shareManager];
    [manager getVideoInfoListWithURLStr:url parameters:parameters  success:^(NSArray *sidArray, NSArray *videoArray, NSDictionary *responseBody) {
        
        NSMutableArray<VideoItem *> *videoList = [NSMutableArray array];
        for (NSDictionary * video in  videoArray) {
            VideoItem * model = [VideoItem  mj_objectWithKeyValues:video];
            [videoList addObject:model];
        }
        NSMutableArray<SidModel *> *sidList = [NSMutableArray array];
        for (NSDictionary * sid in  sidArray) {
             SidModel* model = [SidModel  mj_objectWithKeyValues:sid];
            [sidList addObject:model];
        }
        if(videoList.count > 0 || sidList.count > 0){
            if(self.delegate && [self.delegate respondsToSelector:@selector(acquireHomeVideoSidListSuccess:)]){
                [self.delegate acquireHomeVideoSidListSuccess:sidList];
            }
        }
    } failed:^(NSError *error) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(acquireHomeVideoInfoListFailed)]){
            [self.delegate acquireHomeVideoInfoListFailed];
        }
    }];
}

- (void)getVideoMoreListWithURLString:(NSString *)URLString ListID:(NSString *)ID {
    NSMutableArray<VideoItem *> *listArray = [NSMutableArray array];
    NetworkManager *manager = [NetworkManager shareManager];
    [manager  getVideoInfoListWithURLStr:URLString parameters:nil success:^(NSArray *sidArray, NSArray *videoArray, NSDictionary *responseBody) {
        NSArray *videoList = [responseBody objectForKey:ID];
        for (NSDictionary * video in videoList) {
            VideoItem * model = [VideoItem mj_objectWithKeyValues:video];
            [listArray addObject:model];
        }
        
        if(listArray.count > 0){
            if(self.delegate && [self.delegate respondsToSelector:@selector(acquireHomeVideoListSuccess:)]){
                [self.delegate acquireHomeVideoListSuccess:listArray];
            }
        }
        
    } failed:^(NSError *error) {
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(acquireHomeVideoInfoListFailed)]){
            [self.delegate acquireHomeVideoInfoListFailed];
        }
    }];
  
    
    
}

@end
