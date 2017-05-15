//
//  VideoItem.h
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoItem : NSObject
@property (nonatomic, strong) NSString * cover;
@property (nonatomic, strong) NSString * descriptionDe;
@property (nonatomic, assign) NSInteger  length;
@property (nonatomic, strong) NSString * m3u8_url;
@property (nonatomic, strong) NSString * m3u8Hd_url;
@property (nonatomic, strong) NSString * mp4_url;
@property (nonatomic, strong) NSString * mp4_Hd_url;
@property (nonatomic, assign) NSInteger  playCount;
@property (nonatomic, strong) NSString * playersize;
@property (nonatomic, strong) NSString * ptime;
@property (nonatomic, strong) NSString * replyBoard;
@property (nonatomic, strong) NSString * replyCount;
@property (nonatomic, strong) NSString * replyid;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * vid;
@property (nonatomic, strong) NSString * videosource;

@end
