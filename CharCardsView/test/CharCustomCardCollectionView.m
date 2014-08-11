//
//  CharCustomCardCollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCustomCardCollectionView.h"
#import "CharCardsNoneViewLayout.h"
#import "UIColor+Random.h"

@interface CharCustomCardCollectionView()
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *thumbnailView;
@property (strong, nonatomic) UITextView *descriptionView;

@property (strong, nonatomic) NSLayoutConstraint *thumbHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *thumbWidthConstraint;
@end

@implementation CharCustomCardCollectionView

#define HEIGHT (110.f)
#define MAX_IMG_HEIGHT (200.f)

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
//        self.scrollView.backgroundColor = [UIColor randomColor];
    }
    return self;
}

-(UIView *) thumbnailView {
    if(_thumbnailView) return _thumbnailView;
    _thumbnailView = [[UIView alloc] init];
    
    _thumbnailView.backgroundColor = [UIColor randomColor];
    _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_thumbnailView];
    return _thumbnailView;
}

-(UIView *) headerView {
    if(_headerView) return _headerView;
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor darkGrayColor];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_headerView];
    return _headerView;
}

-(UITextView *) descriptionView {
    if(_descriptionView) return _descriptionView;
    _descriptionView = [[UITextView alloc] init];
    _descriptionView.backgroundColor = [UIColor darkGrayColor];
    _descriptionView.alpha = 0.f;
    _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_descriptionView];
    return _descriptionView;
}

#pragma mark CharCardCollectionView

-(void) applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    
    CGSize size = layoutAttributes.size;
    if([layoutAttributes isKindOfClass:[CharCollectionViewNoneLayoutAttributes class]]) {
        CGSize originalSize = ((CharCollectionViewNoneLayoutAttributes *)layoutAttributes).originalSize;
        if(originalSize.height > 0) size = originalSize;
    }
    CGFloat thumbWidth = HEIGHT;
    CGFloat thumbHeight = MIN(MAX_IMG_HEIGHT, size.height);
    if(size.height > HEIGHT) thumbWidth = size.width;
    
    self.thumbnailView.frame = CGRectMake(0, 0, thumbWidth, thumbHeight);
}

- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout {
    [super willTransitionFromLayout:oldLayout toLayout:newLayout];
}

@end
