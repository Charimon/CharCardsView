//
//  CharCustomCardCollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCustomCardCollectionView.h"
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
        self.scrollView.backgroundColor = [UIColor randomColor];
        
//        self.maxTopInset = 200.f;
//        [self.scrollView addConstraints:@[ [NSLayoutConstraint constraintWithItem:self.thumbnailView
//                                                                         attribute:NSLayoutAttributeTop
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self.scrollView
//                                                                         attribute:NSLayoutAttributeTop
//                                                                        multiplier:1.f
//                                                                          constant:0],
//                                            [NSLayoutConstraint constraintWithItem:self.thumbnailView
//                                                                         attribute:NSLayoutAttributeLeading
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self.scrollView
//                                                                         attribute:NSLayoutAttributeLeading
//                                                                        multiplier:1.f
//                                                                          constant:0],
//                                           [NSLayoutConstraint constraintWithItem:self.headerView
//                                                                        attribute:NSLayoutAttributeTop
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.thumbnailView
//                                                                        attribute:NSLayoutAttributeTop
//                                                                       multiplier:1.f
//                                                                         constant:8.f],
//                                           [NSLayoutConstraint constraintWithItem:self.headerView
//                                                                        attribute:NSLayoutAttributeLeading
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.thumbnailView
//                                                                        attribute:NSLayoutAttributeTrailing
//                                                                       multiplier:1.f
//                                                                         constant:8.f],
//                                           [NSLayoutConstraint constraintWithItem:self.headerView
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.scrollView
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                       multiplier:1.f
//                                                                         constant:-HEIGHT-16.f],
//                                           [NSLayoutConstraint constraintWithItem:self.headerView
//                                                                        attribute:NSLayoutAttributeHeight
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:nil
//                                                                        attribute:NSLayoutAttributeNotAnAttribute
//                                                                       multiplier:0.f
//                                                                         constant:HEIGHT-16.f],
//                                            ]];
//        
//        self.thumbHeightConstraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView
//                                                                 attribute:NSLayoutAttributeHeight
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:nil
//                                                                 attribute:NSLayoutAttributeNotAnAttribute
//                                                                multiplier:0.f
//                                                                  constant:HEIGHT];
//        self.thumbWidthConstraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView
//                                                                 attribute:NSLayoutAttributeWidth
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:nil
//                                                                 attribute:NSLayoutAttributeNotAnAttribute
//                                                                multiplier:0.f
//                                                                  constant:HEIGHT];
//        
//        
//        [self.scrollView addConstraint:self.thumbHeightConstraint];
//        [self.scrollView addConstraint:self.thumbWidthConstraint];
    }
    return self;
}

-(UIView *) thumbnailView {
    if(_thumbnailView) return _thumbnailView;
    _thumbnailView = [[UIView alloc] init];
    
    _thumbnailView.backgroundColor = [UIColor grayColor];
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

//-(void) updateWithState:(CharCardsViewState) state data:(id) data {
//    [super updateWithState:state data:data];
//    self.scrollView.backgroundColor = data;
//    
//    [self willChangeState:state fromOldState:CharCardsViewStateNone];
//    [self didChangeState:state fromOldState:CharCardsViewStateNone];
//}

#pragma mark CharCardCollectionView
//-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
//    [super willChangeState:newState fromOldState:oldState];
//    
//    if(newState == CharCardsViewStateMax) {
//        self.thumbHeightConstraint.constant = MAX_IMG_HEIGHT;
//        self.thumbWidthConstraint.constant = self.bounds.size.width;
//    } else if(newState == CharCardsViewStateMin) {
//        self.thumbHeightConstraint.constant = HEIGHT;
//        self.thumbWidthConstraint.constant = HEIGHT;
//    }
//    
//    [self layoutIfNeeded];
//}
//-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
//    [super didChangeState:newState fromOldState:oldState];
//}
//-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height {
//    [super didChangeVerticalPositionFromBottom:position inHeight:height];
//    
//    self.headerView.alpha =  1.f - (position/height);
//    self.thumbHeightConstraint.constant = HEIGHT + (MAX_IMG_HEIGHT - HEIGHT)*(position/height);
//    self.thumbWidthConstraint.constant = HEIGHT + (self.bounds.size.width - HEIGHT)*(position/height);
//}

//-(void)layoutSubviews {
//    [super layoutSubviews];
//    NSLog(@"layout: %@", NSStringFromCGRect(self.bounds));
//    
//    CGFloat width = 100.f;
//    if(self.bounds.size.height > 200) width = self.bounds.size.width;
//    self.thumbnailView.frame = CGRectMake(0, 0, width, 100);
//}

-(void) applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    CGFloat thumbWidth = HEIGHT;
    CGFloat thumbHeight = MIN(MAX_IMG_HEIGHT, layoutAttributes.size.height);
    if(layoutAttributes.size.height > HEIGHT) thumbWidth = layoutAttributes.size.width;
    
    self.thumbnailView.frame = CGRectMake(0, 0, thumbWidth, thumbHeight);
}

- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout {
    [super willTransitionFromLayout:oldLayout toLayout:newLayout];
}

@end
