//
//  CharCardsView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsView.h"

@interface CharCardsView() <UIGestureRecognizerDelegate>
@property (atomic) BOOL animating;
@property (atomic) BOOL panning;
@end

@implementation CharCardsView

//if the view has moved less that maxMovementDistance*snapRatio, it will snap back to where it was
CGFloat const snapRatio = .3333333f;

-(instancetype) init {
    self = [super init];
    if(self) {
        self.state = CharCardsViewStateNone;
        self.clipsToBounds = YES;
        self.topInsetTapRecognizerEnabled = YES;
        self.minStateTapRecognizerEnabled = YES;
        self.dragRecognizerEnabled = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(!self.card || self.state == CharCardsViewStateNone) return NO;
    if(self.card && self.state != CharCardsViewStateMax) {
        return [self.card pointInside:[self convertPoint:point toView:self.card] withEvent:event];
    }
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(gestureRecognizer == self.topInsetTapRecognizer) {
        return !CGRectContainsPoint(self.card.bounds, [touch locationInView:self.card]);
    } else if(gestureRecognizer == self.minStateTapRecognizer) {
        return CGRectContainsPoint(self.card.bounds, [touch locationInView:self.card]);
    } else if(gestureRecognizer == self.dragRecognizer) {
        if(self.state == CharCardsViewStateMin && !self.panning) {
            return CGRectContainsPoint(self.card.bounds, [touch locationInView:self.card]);
        } else return YES;
    } else return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void) layoutSubviews {
    if(self.state == CharCardsViewStateMax && !self.animating && !self.panning) {
        //autolayout changes
        self.topConstraint.constant = self.maxTopInset-self.bounds.size.height;
        self.heightConstraint.constant = self.bounds.size.height - self.maxTopInset;
    }
    //super must be after changes in autolayout
    [super layoutSubviews];
}

-(void) setTopInsetTapRecognizerEnabled:(BOOL)topInsetTapRecognizerEnabled {
    _topInsetTapRecognizerEnabled = topInsetTapRecognizerEnabled;
    self.topInsetTapRecognizer.enabled = topInsetTapRecognizerEnabled;
}
-(void) setMinStateTapRecognizerEnabled:(BOOL)minStateTapRecognizerEnabled {
    _minStateTapRecognizerEnabled = minStateTapRecognizerEnabled;
    self.minStateTapRecognizer.enabled = minStateTapRecognizerEnabled;
}
-(void) setDragRecognizerEnabled:(BOOL)dragRecognizerEnabled {
    _dragRecognizerEnabled = dragRecognizerEnabled;
    self.dragRecognizer.enabled = dragRecognizerEnabled;
}

-(void) topInsetTapRecognizerTapped:(UITapGestureRecognizer *) topInsetTapRecognizer {[self setState:CharCardsViewStateMin animated:YES callingDelegate:YES];}
-(void) minStateTapRecognizerTapped:(UITapGestureRecognizer *) minStateTapRecognizer {[self setState:CharCardsViewStateMax animated:YES callingDelegate:YES];}
-(void) dragging:(UIPanGestureRecognizer *) dragRecognizer {
    if(dragRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panning = YES;
        self.topInsetTapRecognizer.enabled = NO;
        self.minStateTapRecognizer.enabled = NO;
    } else if(dragRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [dragRecognizer translationInView:dragRecognizer.view];
        
        if(self.state == CharCardsViewStateMin) {
            self.topConstraint.constant = -self.minHeight + translation.y;
            if(self.topConstraint.constant > -self.minHeight){
                self.topConstraint.constant = -self.minHeight;
                [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
            }
            if(self.topConstraint.constant < self.maxTopInset-self.bounds.size.height){
                self.topConstraint.constant = self.maxTopInset-self.bounds.size.height;
                [dragRecognizer setTranslation:CGPointMake(0, translation.y) inView:dragRecognizer.view];
            }
        } else if(self.state == CharCardsViewStateMax) {
            self.topConstraint.constant = self.maxTopInset-self.bounds.size.height + translation.y;
            if(self.topConstraint.constant > -self.minHeight){
                self.topConstraint.constant = -self.minHeight;
                [dragRecognizer setTranslation:CGPointMake(0, translation.y) inView:dragRecognizer.view];
            }
            if(self.topConstraint.constant < self.maxTopInset-self.bounds.size.height){
                self.topConstraint.constant = self.maxTopInset-self.bounds.size.height;
                [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
            }
        }
        CGFloat distanceFromBottom = -self.minHeight - self.topConstraint.constant;
        CGFloat maxDistance = self.bounds.size.height - self.maxTopInset - self.minHeight;
        if([self.delegate respondsToSelector:@selector(cardsView:didChangeVerticalPositionFromBottom:inHeight:)]) {
            [self.delegate cardsView:self didChangeVerticalPositionFromBottom:distanceFromBottom inHeight:maxDistance];
        }
        [self.card didChangeVerticalPositionFromBottom:distanceFromBottom inHeight:maxDistance];
        
    } else if(dragRecognizer.state == UIGestureRecognizerStateEnded || dragRecognizer.state == UIGestureRecognizerStateCancelled || dragRecognizer.state == UIGestureRecognizerStateFailed) {
        self.panning = NO;
        CGFloat distanceFromBottom = -self.minHeight - self.topConstraint.constant;
        CGFloat maxDistance = self.bounds.size.height - self.maxTopInset - self.minHeight;
        
        if(self.state == CharCardsViewStateMin) {
            if(distanceFromBottom < maxDistance*snapRatio) [self setState:CharCardsViewStateMin animated:YES callingDelegate:YES];
            else [self setState:CharCardsViewStateMax animated:YES callingDelegate:YES];
        } else if(self.state == CharCardsViewStateMax) {
            if( (maxDistance-distanceFromBottom) < maxDistance*snapRatio) [self setState:CharCardsViewStateMax animated:YES callingDelegate:YES];
            else [self setState:CharCardsViewStateMin animated:YES callingDelegate:YES];
        }

        if(self.topInsetTapRecognizerEnabled) self.topInsetTapRecognizer.enabled = YES;
        if(self.minStateTapRecognizerEnabled) self.minStateTapRecognizer.enabled = YES;
    }
}

-(void) willSetState:(CharCardsViewState) state {
    if(state == CharCardsViewStateNone) {
        self.topConstraint.constant = 0;
    } else if(state == CharCardsViewStateMin) {
        self.topConstraint.constant = -self.minHeight;
//        self.heightConstraint.constant = self.minHeight;
        self.heightConstraint.constant = self.bounds.size.height - self.maxTopInset;
    } else if(state == CharCardsViewStateMax) {
        self.topConstraint.constant = self.maxTopInset-self.bounds.size.height;
        self.heightConstraint.constant = self.bounds.size.height - self.maxTopInset;
    }
    
    [self removeGestureRecognizer:self.topInsetTapRecognizer];
    self.topInsetTapRecognizer = nil;
    [self removeGestureRecognizer:self.minStateTapRecognizer];
    self.minStateTapRecognizer = nil;
    [self removeGestureRecognizer:self.dragRecognizer];
    self.dragRecognizer = nil;
}

-(void) didSetState:(CharCardsViewState) state {
    [self removeGestureRecognizer:self.topInsetTapRecognizer];
    self.topInsetTapRecognizer = nil;
    if(state == CharCardsViewStateNone) {
        [self.card removeFromSuperview];
        self.card = nil;
        self.topConstraint = nil;
        self.heightConstraint = nil;
    } else if(state == CharCardsViewStateMin) {
        self.minStateTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minStateTapRecognizerTapped:)];
        self.minStateTapRecognizer.delegate = self;
        self.minStateTapRecognizer.enabled = self.minStateTapRecognizerEnabled;
        [self addGestureRecognizer:self.minStateTapRecognizer];
        
        self.dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        self.dragRecognizer.delegate = self;
        self.dragRecognizer.enabled = self.dragRecognizerEnabled;
        [self addGestureRecognizer:self.dragRecognizer];
    } else if(state == CharCardsViewStateMax) {
        self.topInsetTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topInsetTapRecognizerTapped:)];
        self.topInsetTapRecognizer.delegate = self;
        self.topInsetTapRecognizer.enabled = self.topInsetTapRecognizerEnabled;
        [self addGestureRecognizer:self.topInsetTapRecognizer];
        
        self.dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        self.dragRecognizer.delegate = self;
        self.dragRecognizer.enabled = self.dragRecognizerEnabled;
        [self addGestureRecognizer:self.dragRecognizer];
    }
    
    self.state = state;
}

-(void) setBaseConstraints {
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.f
                                                         constant:0.f];
    self.leadingConstraint = [NSLayoutConstraint constraintWithItem:self.card
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.f
                                                           constant:0.f];
    self.topConstraint = [NSLayoutConstraint constraintWithItem:self.card
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1.f
                                                       constant:0.f];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.card
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.f
                                                          constant:self.bounds.size.height - self.maxTopInset];
    [self addConstraint:self.widthConstraint];
    [self addConstraint:self.leadingConstraint];
    [self addConstraint:self.topConstraint];
    [self addConstraint:self.heightConstraint];
}

-(void) setState:(CharCardsViewState) state animated:(BOOL) animated callingDelegate:(BOOL) shouldCallegate {
    [self setState:state animated:animated callingDelegate:shouldCallegate completion:nil];
}

-(void) setState:(CharCardsViewState) state animated:(BOOL) animated callingDelegate:(BOOL) shouldCallegate completion: (void (^)(void)) completion{
    if(!self.card) return;
    
    if(!self.card.superview) {
        self.card.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.card];
        [self setBaseConstraints];
        [self layoutIfNeeded];
    }
    
    if(animated) {
        self.animating = YES;
        [UIView animateWithDuration:.6f
                              delay:0
             usingSpringWithDamping:.8f
              initialSpringVelocity:1.1f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self willSetState:state];
                             
                             if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:willChangeState:fromOldState:)]) {
                                 [self.delegate cardsView:self willChangeState:state fromOldState:self.state];
                             }
                             if(shouldCallegate) [self.card willChangeState:state fromOldState:self.state];
                             [self layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             [self didSetState:state];
                             
                             if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:didChangeState:fromOldState:)]) {
                                 [self.delegate cardsView:self didChangeState:state fromOldState:self.state];
                             }
                             if(shouldCallegate) [self.card didChangeState:state fromOldState:self.state];
                             self.animating = NO;
                             if(completion) completion();
                         }];
    } else {
        [self willSetState:state];
        if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:willChangeState:fromOldState:)]) {
            [self.delegate cardsView:self willChangeState:state fromOldState:self.state];
        }
        if(shouldCallegate) [self.card willChangeState:state fromOldState:self.state];
        
        [self didSetState:state];
        if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:didChangeState:fromOldState:)]) {
            [self.delegate cardsView:self didChangeState:state fromOldState:self.state];
        }
        if(shouldCallegate) [self.card didChangeState:state fromOldState:self.state];
        
        if(completion) completion();
    }
}

-(void) createAppendCard:(CharCardView *) card {
    self.card = card;
    self.card.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.card];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.f
                                                         constant:0.f]
                           ]];
    [self layoutIfNeeded];
    [self setState:self.state animated:NO callingDelegate:YES];
}

-(void) willAppendCard { self.leadingConstraint.constant = - self.frame.size.width; }
-(void) didAppendCard {
    [self.oldCard removeFromSuperview];
    self.oldCard = nil;
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *con, NSUInteger idx, BOOL *stop) {
        if(con.firstItem == self.card) [self removeConstraint:con];
    }];
    [self setBaseConstraints];
    
    //don't call delgate methods again, we already called them earlier
    [self setState:self.state animated:NO callingDelegate:NO];
}

-(void) appendCard: (CharCardView *) card atState:(CharCardsViewState) state animated:(BOOL) animated {
    if(!card ||  state == CharCardsViewStateNone) return;
    if(self.card == card) return;
    
    if(self.card) {
        if(self.state != state){
            __typeof__(self) __weak weakSelf = self;
            [self setState:state animated:animated callingDelegate:NO completion:^{
                weakSelf.oldCard = weakSelf.card;
                
                [weakSelf createAppendCard: card];
                
                if(animated) {
                    weakSelf.animating = YES;
                    [UIView animateWithDuration:.3f
                                          delay:0
                         usingSpringWithDamping:1.f
                          initialSpringVelocity:1.f
                                        options:UIViewAnimationOptionBeginFromCurrentState
                                     animations:^{
                                         [weakSelf willAppendCard];
                                         [weakSelf layoutIfNeeded];
                                     } completion:^(BOOL finished) {
                                         [weakSelf didAppendCard];
                                         weakSelf.animating = NO;
                                     }];
                } else {
                    [weakSelf willAppendCard];
                    [weakSelf didAppendCard];
                }
            }];
        } else {
            self.oldCard = self.card;
            
            [self createAppendCard: card];

            if(animated) {
                self.animating = YES;
                [UIView animateWithDuration:.6f
                                      delay:0
                     usingSpringWithDamping:1.f
                      initialSpringVelocity:1.f
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     [self willAppendCard];
                                     [self layoutIfNeeded];
                                 } completion:^(BOOL finished) {
                                     [self didAppendCard];
                                     self.animating = NO;
                                 }];
            } else {
                [self willAppendCard];
                [self didAppendCard];
            }
        }
        
    } else {
        self.card = card;
        [self setState:state animated:animated callingDelegate:YES];
    }
}

-(void) createPrependCard:(CharCardView *) card {
    self.card = card;
    self.card.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.card];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.card
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.oldCard
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.f
                                                         constant:0.f]
                           ]];
    [self layoutIfNeeded];
    [self setState:self.state animated:NO callingDelegate:YES];
}

-(void) willPrependCard { self.leadingConstraint.constant = + self.frame.size.width; }
-(void) didPrependCard {
    [self.oldCard removeFromSuperview];
    self.oldCard = nil;
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *con, NSUInteger idx, BOOL *stop) {
        if(con.firstItem == self.card) [self removeConstraint:con];
    }];
    [self setBaseConstraints];
    
    //don't call delgate methods again, we already called them earlier
    [self setState:self.state animated:NO callingDelegate:NO];
}


-(void) prependCard: (CharCardView *) card atState:(CharCardsViewState) state animated:(BOOL) animated {
    if(!card || state == CharCardsViewStateNone) return;
    if(self.card == card) return;
    
    if(self.card) {
        if(self.state != state) {
            __typeof__(self) __weak weakSelf = self;
            [self setState:state animated:animated callingDelegate:YES completion:^{
                weakSelf.oldCard = weakSelf.card;
                
                [weakSelf createPrependCard: card];
                
                if(animated) {
                    weakSelf.animating = YES;
                    [UIView animateWithDuration:.3f
                                          delay:0
                         usingSpringWithDamping:1.f
                          initialSpringVelocity:1.f
                                        options:UIViewAnimationOptionBeginFromCurrentState
                                     animations:^{
                                         [weakSelf willPrependCard];
                                         [weakSelf layoutIfNeeded];
                                     } completion:^(BOOL finished) {
                                         [weakSelf didPrependCard];
                                         weakSelf.animating = NO;
                                     }];
                } else {
                    [weakSelf willPrependCard];
                    [weakSelf didPrependCard];
                }
            }];
        } else {
            self.oldCard = self.card;
            
            [self createPrependCard: card];
            
            if(animated) {
                self.animating = YES;
                [UIView animateWithDuration:.6f
                                      delay:0
                     usingSpringWithDamping:1.f
                      initialSpringVelocity:1.f
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     [self willPrependCard];
                                     [self layoutIfNeeded];
                                 } completion:^(BOOL finished) {
                                     [self didPrependCard];
                                     self.animating = NO;
                                 }];
            } else {
                [self willPrependCard];
                [self didPrependCard];
            }
        }
        
    } else {
        self.card = card;
        [self setState:state animated:animated callingDelegate:YES];
    }
}

@end
