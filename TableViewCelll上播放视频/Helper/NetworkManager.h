//
//  NetworkManager.h
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Success)(NSArray *sidArray,NSArray *videoArray, NSDictionary *responseBody);
typedef void(^Failed)(NSError *error);

@interface NetworkManager : NSObject
+(NetworkManager *)shareManager;

- (void)getVideoInfoListWithURLStr:(NSString *)URLString parameters:(id)parameters success:(Success)success failed:(Failed)failed;
@end
