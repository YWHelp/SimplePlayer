# SimplePlayer
tableView上面播放视频
在iOS中播放视频可以使用两个框架来实现：
1、MediaPlayer框架的MPMoviePlayerController和MPMoviePlayerViewController（MPMoviePlayerController在iOS9被Apple废弃了）
2、AVFoundation框架中的AVPlayer

3、AVKit框架的AVPlayerViewController【iOS8之后才有】

AVPlayer视频播放使用步骤：
1、创建视频资源地址URL，可以是网络URL
2、通过URL创建视频内容对象AVPlayerItem，一个视频对应一个AVPlayerItem
3、创建AVPlayer视频播放器对象，需要一个AVPlayerItem进行初始化
4、创建AVPlayerLayer播放图层对象，添加到显示视图上去
5、播放器播放play，播放器暂停pause
6、添加通知中心监听视频播放完成，使用KVO监听播放内容的属性变化
7、进度条监听是调用AVPlayer的对象方法：
-(id)addPeriodicTimeObserverForInterval:(CMTime)interval/*监听频率*/ 
queue:(dispatch_queue_t)queue /*监听GCD线程*/
usingBlock:(void (^)(CMTime time))block;/*监听回调*/
