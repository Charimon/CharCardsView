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
//@property (atomic) BOOL changingState;
@end

@implementation CharCardsView

//if the view has moved less that maxMovementDistance*snapRatio, it will snap back to where it was
CGFloat const SNAP_RATIO = .3333333f;
CGFloat const DEFAULT_VERTICAL_DURATION = .5f;
CGFloat const DEFAULT_VERTICAL_DAMPING = .8f;
CGFloat const DEFAULT_HORIZONTAL_DURATION = .3f;

-(instancetype) init {
    self = [super init];
    if(self) {
        self.state = CharCardsViewStateNone;
        self.clipsToBounds = YES;
        self.topInsetTapRecognizerEnabled = YES;
        self.minStateTapRecognizerEnabled = YES;
        self.dragRecognizerEnabled = YES;
        self.animationMultiplier = 1.f;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL superPointInside = [super pointInside:point withEvent:event];
    if (!superPointInside) return NO;
    if(self.animating) return YES;
    if(!self.card || self.state == CharCardsViewStateNone) return NO;
    if(self.card && self.state != CharCardsViewStateMax) {
        return [self.card pointInside:[self convertPoint:point toView:self.card] withEvent:event];
    }
    if(self.card && self.state == CharCardsViewStateMax && !self.topInsetTapRecognizerEnabled) {
        return [self.card pointInside:[self convertPoint:point toView:self.card] withEvent:event];
    }
    return superPointInside;
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
        self.topConstraint.constant = self.card.maxTopInset-self.bounds.size.height;
        self.heightConstraint.constant = self.bounds.size.height - self.card.maxTopInset;
    }
    //super must be after changes in autolayout
    [super layoutSubviews];
}

-(void) setCard:(CharCardView *)card {
    if(_card) [_card removeFromSuperview];
    _card = card;
}

-(CharCardsViewState) state {
    if(!_card) return CharCardsViewStateNone;
    return _state;
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

-(void) topInsetTapRecognizerTapped:(UITapGestureRecognizer *) topInsetTapRecognizer {
    if(self.card.insetView) [self.card insetViewTapped];
    else [self _cardView:self.card setState:CharCardsViewStateMin animated:YES callingDelegate:YES];
}
-(void) minStateTapRecognizerTapped:(UITapGestureRecognizer *) minStateTapRecognizer {
    [self _cardView:self.card setState:CharCardsViewStateMax animated:YES callingDelegate:YES];
}
-(void) dragging:(UIPanGestureRecognizer *) dragRecognizer {
    if(dragRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panning = YES;
        self.topInsetTapRecognizer.enabled = NO;
        self.minStateTapRecognizer.enabled = NO;
    } else if(dragRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [dragRecognizer translationInView:dragRecognizer.view];
        
        if(self.card.contentView.contentOffset.y > 0) {
            [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
            return;
        }
        
        if(self.state == CharCardsViewStateMin) {
            self.topConstraint.constant = -self.minHeight + translation.y;
            if(self.topConstraint.constant > -self.minHeight){
                self.topConstraint.constant = -self.minHeight;
                [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
            }
            if(self.topConstraint.constant < self.card.maxTopInset-self.bounds.size.height){
                self.topConstraint.constant = self.card.maxTopInset-self.bounds.size.height;
                [dragRecognizer setTranslation:CGPointMake(0, translation.y) inView:dragRecognizer.view];
            }
        } else if(self.state == CharCardsViewStateMax) {
            self.card.contentView.scrollEnabled = NO;
            self.topConstraint.constant = self.card.maxTopInset-self.bounds.size.height + translation.y;
            if(self.topConstraint.constant > -self.minHeight){
                self.topConstraint.constant = -self.minHeight;
                [dragRecognizer setTranslation:CGPointMake(0, translation.y) inView:dragRecognizer.view];
            }
            if(self.topConstraint.constant < self.card.maxTopInset-self.bounds.size.height){
                self.topConstraint.constant = self.card.maxTopInset-self.bounds.size.height;
                [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
                self.card.contentView.scrollEnabled = YES;
            }
        }
        CGFloat distanceFromBottom = -self.minHeight - self.topConstraint.constant;
        CGFloat maxDistance = self.bounds.size.height - self.card.maxTopInset - self.minHeight;
        if([self.delegate respondsToSelector:@selector(cardsView:didChangeVerticalPositionFromBottom:inHeight:forCard:)]) {
            [self.delegate cardsView:self didChangeVerticalPositionFromBottom:distanceFromBottom inHeight:maxDistance forCard:self.card];
        }
        [self.card didChangeVerticalPositionFromBottom:distanceFromBottom inHeight:maxDistance];
        
    } else if(dragRecognizer.state == UIGestureRecognizerStateEnded || dragRecognizer.state == UIGestureRecognizerStateCancelled || dragRecognizer.state == UIGestureRecognizerStateFailed) {
        self.panning = NO;
        CGFloat maxDistance = self.bounds.size.height - self.card.maxTopInset - self.minHeight;
        CGFloat distanceFromBottom = -self.minHeight - self.topConstraint.constant;
        CGFloat distanceFromTop = maxDistance-distanceFromBottom;
        CGFloat yVelocity = [dragRecognizer velocityInView:dragRecognizer.view].y;
        
        
        if(self.state == CharCardsViewStateMin) {
            if(yVelocity < -1000){
                [self _cardView:self.card setState:CharCardsViewStateMax animated:YES callingDelegate:YES duration:DEFAULT_VERTICAL_DURATION damping:.95f velocity:ABS(yVelocity/distanceFromTop) completion:nil];
            }
            else if(distanceFromBottom < maxDistance*SNAP_RATIO){
                [self _cardView:self.card setState:CharCardsViewStateMin animated:YES callingDelegate:YES];
            }
            else {
                [self _cardView:self.card setState:CharCardsViewStateMax animated:YES callingDelegate:YES duration:DEFAULT_VERTICAL_DURATION damping:DEFAULT_VERTICAL_DAMPING velocity:ABS(yVelocity/distanceFromTop) completion:nil];
            }
        } else if(self.state == CharCardsViewStateMax) {
            if(yVelocity > 1000) {
                [self _cardView:self.card setState:CharCardsViewStateMin animated:YES callingDelegate:YES duration:DEFAULT_VERTICAL_DURATION damping:.95f velocity:ABS(yVelocity/distanceFromBottom) completion:nil];}
            else if( (maxDistance-distanceFromBottom) < maxDistance*SNAP_RATIO) {
                [self _cardView:self.card setState:CharCardsViewStateMax animated:YES callingDelegate:YES];
            }
            else {
                [self _cardView:self.card setState:CharCardsViewStateMin animated:YES callingDelegate:YES duration:DEFAULT_VERTICAL_DURATION damping:DEFAULT_VERTICAL_DAMPING velocity:ABS(yVelocity/distanceFromBottom) completion:nil];
            }
        }

        self.card.contentView.scrollEnabled = YES;
        if(self.topInsetTapRecognizerEnabled) self.topInsetTapRecognizer.enabled = YES;
        if(self.minStateTapRecognizerEnabled) self.minStateTapRecognizer.enabled = YES;
    }
}

-(void) setState:(CharCardsViewState) state animated:(BOOL) animated {
    if(!self.card) return;
    [self _cardView:self.card setState:state animated:animated callingDelegate:YES];
}

-(void) willSetState:(CharCardsViewState) state {
    if(state == CharCardsViewStateNone) {
        self.topConstraint.constant = 0;
    } else if(state == CharCardsViewStateMin) {
        self.topConstraint.constant = -self.minHeight;
        self.heightConstraint.constant = self.bounds.size.height - self.card.maxTopInset;
    } else if(state == CharCardsViewStateMax) {
        self.topConstraint.constant = self.card.maxTopInset-self.bounds.size.height;
        self.heightConstraint.constant = self.bounds.size.height - self.card.maxTopInset;
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
        
        self.card.contentView.scrollEnabled = NO;
    } else if(state == CharCardsViewStateMax) {
        self.topInsetTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topInsetTapRecognizerTapped:)];
        self.topInsetTapRecognizer.delegate = self;
        self.topInsetTapRecognizer.enabled = self.topInsetTapRecognizerEnabled;
        [self addGestureRecognizer:self.topInsetTapRecognizer];
        
        self.dragRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        self.dragRecognizer.delegate = self;
        self.dragRecognizer.enabled = self.dragRecognizerEnabled;
        [self addGestureRecognizer:self.dragRecognizer];
        
        self.card.contentView.scrollEnabled = YES;
    }
}

-(void) setBaseConstraints:(CharCardView *) card{
    if(!card) return;
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:card
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.f
                                                         constant:0.f];
    self.leadingConstraint = [NSLayoutConstraint constraintWithItem:card
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.f
                                                           constant:0.f];
    self.topConstraint = [NSLayoutConstraint constraintWithItem:card
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self
                                                      attribute:NSLayoutAttributeBottom
                                                     multiplier:1.f
                                                       constant:0.f];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:card
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.f
                                                          constant:self.bounds.size.height - card.maxTopInset];
    [self addConstraint:self.widthConstraint];
    [self addConstraint:self.leadingConstraint];
    [self addConstraint:self.topConstraint];
    [self addConstraint:self.heightConstraint];
}

-(void) _cardView:(CharCardView *) card setState:(CharCardsViewState) state animated:(BOOL) animated callingDelegate:(BOOL) shouldCallegate {
    [self _cardView:card setState:state animated:animated callingDelegate:shouldCallegate completion:nil];
}
-(void) _cardView:(CharCardView *) card setState:(CharCardsViewState) state animated:(BOOL) animated callingDelegate:(BOOL) shouldCallegate completion: (void (^)(void)) completion{
    [self _cardView:card setState:state animated:animated callingDelegate:shouldCallegate duration:DEFAULT_VERTICAL_DURATION damping:DEFAULT_VERTICAL_DAMPING velocity:1.1f completion:completion];
}

-(void) _cardView:(CharCardView *) card setState:(CharCardsViewState) state animated:(BOOL) animated callingDelegate:(BOOL) shouldCallegate duration:(CGFloat) duration damping:(CGFloat) damping velocity:(CGFloat) velocity completion: (void (^)(void)) completion{
    NSAssert(card, @"card must exist");
    
    if(!card.superview) {
        card.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:card];
        [self setBaseConstraints:card];
        [self layoutIfNeeded];
    }
    
    CharCardsViewState oldState = self.state;
    if(animated) {
        self.animating = YES;
        card.contentView.bounces = NO;
        
        [UIView animateWithDuration:duration * self.animationMultiplier
                              delay:0
             usingSpringWithDamping:damping
              initialSpringVelocity:velocity
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self willSetState:state];
                             
                             if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:willChangeState:fromOldState:forCard:)]) {
                                 [self.delegate cardsView:self willChangeState:state fromOldState:oldState forCard:card];
                             }
                             if(shouldCallegate) [card willChangeState:state fromOldState:oldState];
                             [self layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             if(finished) {
                                 
                                 [self didSetState:state];
                                 
                                 if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:didChangeState:fromOldState:forCard:)]) {
                                     [self.delegate cardsView:self didChangeState:state fromOldState:oldState forCard:card];
                                 }
                                 if(shouldCallegate) [card didChangeState:state fromOldState:oldState];
                                 card.contentView.bounces = NO;
                                 self.state = state;
                                 if(completion) completion();
                                 self.animating = NO;
                             }
                         }];
    } else {
        [self willSetState:state];
        if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:willChangeState:fromOldState:forCard:)]) {
            [self.delegate cardsView:self willChangeState:state fromOldState:oldState forCard:card];
        }
        if(shouldCallegate) [card willChangeState:state fromOldState:oldState];
        
        [self didSetState:state];
        if(shouldCallegate && [self.delegate respondsToSelector:@selector(cardsView:didChangeState:fromOldState:forCard:)]) {
            [self.delegate cardsView:self didChangeState:state fromOldState:oldState forCard:card];
        }
        if(shouldCallegate) [card didChangeState:state fromOldState:oldState];
        
        if(completion) completion();
        self.state = state;
    }
}

-(void) createAppendCard:(CharCardView *) card to:(CharCardView *) oldCard{
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:card];
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:card
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:oldCard
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:card
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:oldCard
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:card
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:oldCard
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:card
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:oldCard
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.f
                                                         constant:0.f]
                           ]];
    [self layoutIfNeeded];
    [self _cardView:card setState:self.state animated:NO callingDelegate:YES];
}

-(void) willAppendCard { self.leadingConstraint.constant = - self.frame.size.width; }
-(void) didAppendCard:(CharCardView *) card to:(CharCardView *) oldCard {
    [oldCard removeFromSuperview];
    oldCard = nil;
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *con, NSUInteger idx, BOOL *stop) {
        if(con.firstItem == card) [self removeConstraint:con];
    }];
    [self setBaseConstraints:card];
    
    //don't call delgate methods again, we already called them earlier
    self.card = card;
    [self _cardView:card setState:self.state animated:NO callingDelegate:NO];
}
-(void) appendCard: (CharCardView *) card animated:(BOOL) animated {
    if(self.state == CharCardsViewStateNone) [self appendCard:card atState:CharCardsViewStateMin animated:animated];
    else [self appendCard:card atState:self.state animated:animated];
}

//this actually does the horizontal sliding animation
-(void) transitionAppendCard: (CharCardView *) card animated:(BOOL) animated  completion: (void (^)(void)) completion{
    [self createAppendCard: card to:self.oldCard];
    if(animated) {
        self.animating = YES;
        [UIView animateWithDuration:DEFAULT_HORIZONTAL_DURATION * self.animationMultiplier
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self willAppendCard];
                             [self layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             if(finished) {
                                 [self didAppendCard:card to:self.oldCard];
                                 [self layoutIfNeeded];
                                 if(completion) completion();
                                 self.animating = NO;
                             }
                         }];
    } else {
        [self willAppendCard];
        [self didAppendCard:card to:self.oldCard];
        if(completion) completion();
    }
}
-(void) appendCard: (CharCardView *) card atState:(CharCardsViewState) state animated:(BOOL) animated {
    if(!card ||  state == CharCardsViewStateNone) return;
    if([self.card isEqual:card]) return;
    
    if(self.card) {
        if(self.state != state){
            __typeof__(self) __weak weakSelf = self;
            [self _cardView:self.card setState:state animated:animated callingDelegate:YES completion:^{
                weakSelf.oldCard = weakSelf.card;
                [weakSelf transitionAppendCard:card animated:animated completion:^{
                    weakSelf.animating = NO;
                }];
            }];
        } else {
            self.oldCard = self.card;
            __typeof__(self) __weak weakSelf = self;
            [self transitionAppendCard:card animated:animated completion:^{
                weakSelf.animating = NO;
            }];
        }
    } else {
        self.card = card;
        __typeof__(self) __weak weakSelf = self;
        [self _cardView:self.card setState:state animated:animated callingDelegate:YES completion:^{
            weakSelf.animating = NO;
        }];
    }
}

@end
