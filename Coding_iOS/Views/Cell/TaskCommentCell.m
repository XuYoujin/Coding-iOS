//
//  TaskCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTaskCommentCell_FontContent [UIFont systemFontOfSize:15]
#define kTaskCommentCell_LeftPading 35.0
#define kTaskCommentCell_LeftContentPading (kTaskCommentCell_LeftPading + 40)
#define kTaskCommentCell_ContentWidth (kScreen_Width - kTaskCommentCell_LeftContentPading - kTaskCommentCell_LeftPading)

#import "TaskCommentCell.h"
#import "UICustomCollectionView.h"
#import "TaskCommentCCell.h"

#import "MJPhotoBrowser.h"

@interface TaskCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *ownerIconView, *timeLineView, *contentBGView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;

@end

@implementation TaskCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat curBottomY = 15;
        if (!_contentBGView) {
            _contentBGView = [UIImageView new];
            _contentBGView.image = [[UIImage imageNamed:@"comment_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(35, 15, 5, 5)];
            ;
//            _contentBGView.backgroundColor = [UIColor lightGrayColor];
            [self.contentView addSubview:_contentBGView];
        }
        if (!_timeLineView) {
            _timeLineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2, 1)];
            [_timeLineView setImage:[UIImage imageNamed:@"timeline_line_read"]];
            [self.contentView addSubview:_timeLineView];
        }
        if (!_ownerIconView) {
            CGFloat borderWidth = 0;
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(20 - borderWidth, curBottomY, 25+ 2*borderWidth, 25 + 2*borderWidth)];
            
            _ownerIconView.layer.masksToBounds = YES;
            _ownerIconView.layer.cornerRadius = _ownerIconView.frame.size.width/2;
//            _ownerIconView.layer.borderWidth = borderWidth;
//            _ownerIconView.layer.borderColor = kColorTableBG.CGColor;
            
            [self.contentView addSubview:_ownerIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, curBottomY, kTaskCommentCell_ContentWidth, 30)];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _contentLabel.font = kTaskCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, 0, kTaskCommentCell_ContentWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TaskComment_Media]) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftContentPading, 0, kTaskCommentCell_ContentWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[TaskCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TaskCommentCCell];
                self.imageCollectionView.dataSource = self;
                self.imageCollectionView.delegate = self;
                [self.contentView addSubview:self.imageCollectionView];
            }
        }
        [_contentBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 60- 7, 5, 20));
        }];
    }
    return self;
}

- (void)setCurComment:(TaskComment *)curComment{
    _curComment = curComment;
    if (!_curComment) {
        return;
    }
    CGFloat curBottomY = 15;
    [_ownerIconView sd_setImageWithURL:[_curComment.owner.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundWidth(33.0)];
    
    NSString *contentStr = _curComment.content;
    [_contentLabel setLongString:contentStr withFitWidth:kTaskCommentCell_ContentWidth];
    
    for (HtmlMediaItem *item in _curComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(kTaskCommentCell_ContentWidth, CGFLOAT_MAX)] + 5;
    
    NSInteger imagesCount = _curComment.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kTaskCommentCell_LeftContentPading, curBottomY, kTaskCommentCell_ContentWidth, [TaskCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    }else{
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [TaskCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _curComment.owner.name, [_curComment.created_at stringTimesAgo]];
}

- (void)configTop:(BOOL)isTop andBottom:(BOOL)isBottom{
    if (isTop && isBottom) {
        _timeLineView.hidden = YES;
    }else{
        _timeLineView.hidden = NO;
        [_timeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(2.0);
            make.centerX.equalTo(_ownerIconView);
            make.top.equalTo(isTop? _ownerIconView.mas_centerY: self.contentView);
            make.bottom.equalTo(isBottom? _ownerIconView.mas_centerY: self.contentView);
        }];
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[TaskComment class]]) {
        TaskComment *curComment = (TaskComment *)obj;
        NSString *contentStr = curComment.content;
        cellHeight += 10 +[contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(kTaskCommentCell_ContentWidth, CGFLOAT_MAX)] + 5 +20 +10;
        cellHeight += [self imageCollectionViewHeightWithCount:curComment.htmlMedia.imageItems.count];
        cellHeight += 10;
    }
    return cellHeight;
}

+ (CGFloat)imageCollectionViewHeightWithCount:(NSInteger)countNum{
    if (countNum <= 0) {
        return 0;
    }
    NSInteger numInOneLine = floorf((kTaskCommentCell_ContentWidth +5)/(33 + 5));
    NSInteger numOfline = ceilf(countNum/(float)numInOneLine);
    return (43 *numOfline);
}


#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _curComment.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TaskCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TaskCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_curComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [TaskCommentCCell ccellSize];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //        显示大图
    int count = (int)_curComment.htmlMedia.imageItems.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        HtmlMediaItem *imageItem = [_curComment.htmlMedia.imageItems objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageItem.src]; // 图片路径
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end
