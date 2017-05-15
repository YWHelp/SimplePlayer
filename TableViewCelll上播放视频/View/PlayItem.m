//
//  PlayItem.m
//  视频播放
//
//  Created by changcai on 17/5/8.
//  Copyright © 2017年 changcai. All rights reserved.
//

#import "PlayItem.h"

static  NSUInteger currentSelecteIndex = MAXFLOAT;
@interface PlayItem()

/** 标题  */
@property (strong, nonatomic) UILabel *titleLabel;
/** 描述  */
@property (strong, nonatomic) UILabel *descriptionLabel;
/**   */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PlayItem

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView setUserInteractionEnabled:YES];
        [self initUI];
    }
    return self;
}

- (void)initUI
{

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel sizeToFit];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).with.offset(8);
        make.left.equalTo(self.contentView.mas_left).with.offset(8);
        make.right.equalTo(self.contentView.mas_right).with.offset(8);
        make.height.mas_equalTo(20);
    }];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = [UIFont systemFontOfSize:14.0f];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    self.descriptionLabel.textColor = [UIColor blackColor];
    self.descriptionLabel.numberOfLines = 1;
    self.descriptionLabel.hidden = YES;
    [self.contentView addSubview:self.descriptionLabel];
    [self.descriptionLabel sizeToFit];
    
    self.backgroundImage = [[UIImageView alloc]init];
    self.backgroundImage.userInteractionEnabled = YES;
    [self.contentView addSubview:self.backgroundImage];
    
    //播放按钮
    self.playBtn = [[UIButton alloc] init];
    [self.contentView addSubview:self.playBtn];
    [self.playBtn setImage:[UIImage imageNamed:@"video_play_btn_bg"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(selectedItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.backgroundImage);
        make.height.mas_equalTo(64);
        make.width.mas_equalTo(64);
    }];
    
}

- (void) refreshItemWithVideoItem:(VideoItem *)videoModel indexPath:(NSIndexPath *)indexPath
{
    self.videoModel = videoModel;
    self.playBtn.tag = indexPath.section;
    self.titleLabel.text = videoModel.title;
    if(videoModel.descriptionDe.length > 0){
        self.descriptionLabel.hidden = NO;
         self.descriptionLabel.text = videoModel.descriptionDe;
        [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
            make.left.equalTo(self.contentView.mas_left).with.offset(8);
            make.right.equalTo(self.contentView.mas_right).with.offset(8);
            make.height.mas_equalTo(17);
        }];
        [self.backgroundImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.descriptionLabel.mas_bottom).with.offset(8);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.height.mas_equalTo(220);
        }];
    }else{
        self.descriptionLabel.hidden = YES;
        self.descriptionLabel.text = nil;
        [self.backgroundImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(8);
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.height.mas_equalTo(220);
        }];
    }
    [self.backgroundImage sd_setImageWithURL:[NSURL URLWithString:videoModel.cover] placeholderImage:[UIImage imageNamed:@"logo"]];

}

- (void) selectedItem:(UIButton *)sender
{
    currentSelecteIndex = sender.tag;
    self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:sender.tag];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(playItem:startPlayVideo:)]){
        [self.delegate playItem:self startPlayVideo:sender];
    }
}
@end
