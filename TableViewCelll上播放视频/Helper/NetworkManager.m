//
//  NetworkManager.m
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetworking.h"
@implementation NetworkManager

+(NetworkManager *)shareManager{
    static NetworkManager* manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (void)getVideoInfoListWithURLStr:(NSString *)URLString parameters:(id)parameters success:(Success)success failed:(Failed)failed{
    //1.创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.封装参数
    //3.发送GET请求
    [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"success--%@--%@",[responseObject class],responseObject);
        NSDictionary * dict = responseObject;
        if(success ){
            success([dict objectForKey:@"videoSidList"], [dict objectForKey:@"videoList"],dict);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
         NSLog(@"failure--%@",error);
        if(failed){
            failed(error);
        }
    }];
    
}

@end
