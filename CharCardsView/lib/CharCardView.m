//
//  CharCardView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardView.h"
#import "CharCardsView.h"

@interface CharCardView()
@property (nonatomic, readwrite) CharCardsViewState state;
@property (strong, nonatomic) NSLayoutConstraint *insetViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *insetViewTopConstraint;
@end

@implementation CharCardView
-(instancetype) init {
    self = [super init];
    if(self) {
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.f
                                                             constant:0.f],
                               ]];
    }
    return self;
}

-(void) didMoveToSuperview {
    [super didMoveToSuperview];
    if([self.superview isKindOfClass:[CharCardsView class]]) {
        self.cardsView = (CharCardsView *) self.superview;
        self.cardsView.topInsetTapRecognizerEnabled = !self.insetView;
    } else {
        self.cardsView = nil;
    }
}

-(void) setInsetView:(UIView *)insetView {
    if(_insetView) {
        [_insetView removeFromSuperview];
        self.insetViewHeightConstraint = nil;
        self.insetViewTopConstraint = nil;
    }
    
    if(insetView) self.cardsView.topInsetTapRecognizerEnabled = NO;
    else {
        self.cardsView.topInsetTapRecognizerEnabled = YES;
        return;
    }
    
    _insetView = insetView;
    [self addSubview:_insetView];
    [self sendSubviewToBack:_insetView];
    _insetView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.insetView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.insetView
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.f
                                                         constant:0.f],
                           ]];
    self.insetViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.insetView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.f
                                                                constant:0.f];
    self.insetViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.insetView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0.f
                                                                   constant:0.f];
    if(self.state == CharCardsViewStateMax) {
        self.insetViewTopConstraint.constant = -self.cardsView.maxTopInset;
        self.insetViewHeightConstraint.constant = self.cardsView.maxTopInset;
    } else if (self.state == CharCardsViewStateMin) {
        self.insetViewTopConstraint.constant = 0;
        self.insetViewHeightConstraint.constant = self.cardsView.minHeight;
    }
    [self addConstraint:self.insetViewTopConstraint];
    [self addConstraint:self.insetViewHeightConstraint];
}

-(UIScrollView *) contentView {
    if(_contentView) return _contentView;
    _contentView = [[UIScrollView alloc] init];
    [self addSubview:_contentView];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    return _contentView;
}

-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    if(newState == CharCardsViewStateMax) {
        self.insetViewTopConstraint.constant = -self.cardsView.maxTopInset;
        self.insetViewHeightConstraint.constant = self.cardsView.maxTopInset;
    } else if (newState == CharCardsViewStateMin) {
        self.insetViewTopConstraint.constant = 0;
        self.insetViewHeightConstraint.constant = self.cardsView.minHeight;
    }
}
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    self.state = newState;
}
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height {
    self.insetViewTopConstraint.constant = -self.cardsView.maxTopInset * (position/height);
    self.insetViewHeightConstraint.constant = self.cardsView.minHeight + (self.cardsView.maxTopInset - self.cardsView.minHeight)* (position/height);
}
@end
