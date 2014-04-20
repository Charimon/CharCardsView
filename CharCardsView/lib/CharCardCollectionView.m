//
//  CharCardCollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardCollectionView.h"
#import "CharCardsCollectionView.h"

@interface CharCardCollectionView() <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSLayoutConstraint *scrollViewTopConstraint;
@end

@implementation CharCardCollectionView
-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.scrollView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.scrollView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.scrollView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.contentView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.f
                                                             constant:0.f],
                               ]];
        self.scrollViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.f
                                                                     constant:0.f];
        [self.contentView addConstraint:self.scrollViewTopConstraint];
        
        [self addGestureRecognizer:self.maxInsetTapRecognizer];
    }
    return self;
}

-(UITapGestureRecognizer *) maxInsetTapRecognizer {
    if(_maxInsetTapRecognizer) return _maxInsetTapRecognizer;
    _maxInsetTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maxInsetTapped:)];
    _maxInsetTapRecognizer.delegate = self;
    return _maxInsetTapRecognizer;
}

-(void) maxInsetTapped: (UITapGestureRecognizer *) maxInsetTapRecognizer{
    [self.cardsCollectionView setState:CharCardsViewStateMin animated:YES];
}

-(UIScrollView *) scrollView {
    if(_scrollView) return _scrollView;
    _scrollView = [[UIScrollView alloc] init];
    [self.contentView addSubview:_scrollView];
    _scrollView.opaque = YES;
    _scrollView.delegate = self;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    return _scrollView;
}

-(void) updateWithState:(CharCardsViewState) state data:(id)data {}
-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    if(newState == CharCardsViewStateMax) self.scrollViewTopConstraint.constant = self.maxTopInset;
    else self.scrollViewTopConstraint.constant = 0;
    [self layoutIfNeeded];
}
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {}
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height {
    self.scrollViewTopConstraint.constant =  (self.maxTopInset)*(position/height);
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollView.contentOffset.y <= 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
        self.cardsCollectionView.panRecognizer.enabled = YES;
    } else {
        self.cardsCollectionView.panRecognizer.enabled = NO;
    }
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(gestureRecognizer == self.maxInsetTapRecognizer) {
        return !CGRectContainsPoint(self.scrollView.bounds, [touch locationInView:self.scrollView]);
    } else return YES;
}
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
