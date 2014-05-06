//
//  CharCardsCollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsCollectionView.h"
#import "CharCardsNoneViewLayout.h"
#import "CharCardsMinViewLayout.h"
#import "CharCardsMaxViewLayout.h"

@interface CharCardsCollectionView() <UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

@property (strong, nonatomic) CharCardsNoneViewLayout *noneLayout;
@property (strong, nonatomic) CharCardsMinViewLayout *minLayout;
@property (strong, nonatomic) CharCardsMaxViewLayout *maxLayout;
@property (strong, nonatomic) UICollectionViewLayout *currentTransitioningLayout;
@property (nonatomic) CharCardsTransitionType transitionType;
@property (nonatomic) BOOL shouldRestartTransition;

@property (strong, nonatomic, readwrite) CharCardCollectionView *topCard;

//cardsType have to be in sync
@property (strong, nonatomic) NSMutableArray *cardsType;
@property (strong, nonatomic) NSMutableArray *cardsData;
@end

@implementation CharCardsCollectionView

CGFloat const CC2_SNAP_RATIO = .3333333f;
CGFloat const CC2_SNAP_VELOCITY = 1000.f;

-(instancetype) init {
    self = [super init];
    if(self) {
        self.panningEnabled = YES;
        self.tapEnabled = YES;
        self.clipsToBounds = YES;
        self.cardsType = [[NSMutableArray alloc] init];
        self.cardsData = [[NSMutableArray alloc] init];
        self.shouldRestartTransition = YES;
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.collectionView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.collectionView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.collectionView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.collectionView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f],
                               ]];
        
        [self addGestureRecognizer:self.tapRecognizer];
        [self addGestureRecognizer:self.panRecognizer];
        
        self.tapRecognizer.enabled = self.tapEnabled;
        self.panRecognizer.enabled = self.panningEnabled;
    }
    return self;
}

-(instancetype) initWithTransitionType: (CharCardsTransitionType) transitionType {
    self = [self init];
    if(self) {
        self.transitionType = transitionType;
    }
    return self;
}

-(CharCardsViewState) currentState {
    if(self.collectionView.collectionViewLayout == self.minLayout) return CharCardsViewStateMin;
    else if(self.collectionView.collectionViewLayout == self.maxLayout) return CharCardsViewStateMax;
    else if(self.collectionView.collectionViewLayout == self.noneLayout) return CharCardsViewStateNone;
    else return CharCardsViewStateTransitioning;
}

-(CharCardsNoneViewLayout *) noneLayout {
    if(_noneLayout) return _noneLayout;
    _noneLayout = [[CharCardsNoneViewLayout alloc] init];
    _noneLayout.transitionType = self.transitionType;
    return _noneLayout;
}

-(CharCardsMinViewLayout *) minLayout {
    if(_minLayout) return _minLayout;
    _minLayout = [[CharCardsMinViewLayout alloc] initWithMinHeight:self.minHeight];
    _minLayout.transitionType = self.transitionType;
    return _minLayout;
}

-(CharCardsMaxViewLayout *) maxLayout {
    if(_maxLayout) return _maxLayout;
    _maxLayout = [[CharCardsMaxViewLayout alloc] initWithTopInset:self.topInset];
    _maxLayout.transitionType = self.transitionType;
    return _maxLayout;
}

-(CharCardCollectionView *) topCard {
    if([self.collectionView visibleCells].count > 0) return [[self.collectionView visibleCells] objectAtIndex:0];
    else return nil;
}

-(void) setTapEnabled:(BOOL)tapEnabled {
    _tapEnabled = tapEnabled;
    self.tapRecognizer.enabled = tapEnabled;
}

-(void) setPanningEnabled:(BOOL)panningEnabled {
    _panningEnabled = panningEnabled;
    self.panRecognizer.enabled = panningEnabled;
}

-(UITapGestureRecognizer *) tapRecognizer {
    if(_tapRecognizer) return _tapRecognizer;
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerTapped:)];
    _tapRecognizer.delegate = self;
    return _tapRecognizer;
}

-(void) tapRecognizerTapped: (UITapGestureRecognizer *) tapRecognizer {
    CGPoint tapPoint = [tapRecognizer locationInView:self.collectionView];
    if(self.topCard.insetView && CGRectContainsPoint(self.topCard.insetView.bounds, tapPoint)) return;

    CharCardsViewState state = [self currentState];
    if(state == CharCardsViewStateMin && [self.collectionView indexPathForItemAtPoint:tapPoint]) {
        [self _setState:CharCardsViewStateMax fromState:state];
    } else if(state == CharCardsViewStateMax && ![self.collectionView indexPathForItemAtPoint:tapPoint]) {
        [self _setState:CharCardsViewStateMin fromState:state];
    }
}

-(UIPanGestureRecognizer *) panRecognizer {
    if(_panRecognizer) return _panRecognizer;
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    _panRecognizer.delegate = self;
    return _panRecognizer;
}

-(void) panning:(UIPanGestureRecognizer *) panRecognizer {
    if(panRecognizer.state == UIGestureRecognizerStateBegan) {
        if(self.topCard.scrollView.contentOffset.y < 0) self.topCard.scrollView.scrollEnabled = NO;
        
        CGPoint transition = [panRecognizer translationInView:self.panRecognizer.view];
        if(self.topCard.scrollView.scrollEnabled && transition.y < 0) return;
        
        UICollectionViewLayout *newLayout = ([self currentState] == CharCardsViewStateMax)?self.minLayout:self.maxLayout;
        if(self.shouldRestartTransition && self.currentTransitioningLayout != self.collectionView.collectionViewLayout) {
            self.shouldRestartTransition = NO;
            
            CharCardsViewState state = [self currentState];
            
            self.currentTransitioningLayout = [self.collectionView startInteractiveTransitionToCollectionViewLayout:newLayout completion:^(BOOL completed, BOOL finish) {
                if(state == CharCardsViewStateMax) self.topCard.scrollView.scrollEnabled = YES;
                else self.topCard.scrollView.scrollEnabled = NO;
                
                self.shouldRestartTransition = YES;
                self.currentTransitioningLayout = nil;
                
                if(self.panningEnabled) self.panRecognizer.enabled = YES;
                
                if(state == CharCardsViewStateMin && finish) {
                    [self _setState:CharCardsViewStateMin fromState:state];
                } else if(state == CharCardsViewStateMax && finish) {
                    [self _setState:state fromState:state];
                } else if( state == CharCardsViewStateMin && !finish) {
                    [self _setState:state fromState:CharCardsViewStateMin];
                } else if( state == CharCardsViewStateMax && !finish) {
                    [self _setState:state fromState:CharCardsViewStateMax];
                }
                
            }];
        }
    } else if(panRecognizer.state == UIGestureRecognizerStateChanged) {
        if(![self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewTransitionLayout class]]) return;
        if(self.topCard.scrollView.contentOffset.y > 0) {
            [panRecognizer setTranslation:CGPointZero inView:panRecognizer.view];
            return;
        }
        
        self.topCard.scrollView.scrollEnabled = NO;
        
        CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
        UICollectionViewTransitionLayout *transitionalLayout;
        if([self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewTransitionLayout class]]) {
            transitionalLayout = (id)self.collectionView.collectionViewLayout;
        }
        
        if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMinViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:[CharCardsMaxViewLayout class]]) {
            CharCardsMinViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
            CharCardsMaxViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
            CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.minHeight - nextLayout.topInset;
            
            if(translation.y < 0) {
                transitionalLayout.transitionProgress = -translation.y/maxDistance;
                if(transitionalLayout.transitionProgress > 1) [panRecognizer setTranslation:CGPointMake(0, translation.y) inView:panRecognizer.view];
            } else {
                transitionalLayout.transitionProgress = 0.f;
                [panRecognizer setTranslation:CGPointZero inView:panRecognizer.view];
            }
            
        } else if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMaxViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:
                                                                                                      [CharCardsMinViewLayout class]]) {
            CharCardsMaxViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
            CharCardsMinViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
            CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.topInset - nextLayout.minHeight;
            
            if(translation.y > 0) {
                transitionalLayout.transitionProgress = translation.y/maxDistance;
                if(transitionalLayout.transitionProgress > 1) [panRecognizer setTranslation:CGPointMake(0, translation.y) inView:panRecognizer.view];
            } else {
                transitionalLayout.transitionProgress = 0.f;
                [panRecognizer setTranslation:CGPointMake(0, translation.y) inView:panRecognizer.view];
            }
        }
        
    } else if(panRecognizer.state == UIGestureRecognizerStateEnded ||
              panRecognizer.state == UIGestureRecognizerStateCancelled ||
              panRecognizer.state == UIGestureRecognizerStateFailed) {
        if(![self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewTransitionLayout class]]) return;
        if(self.topCard.scrollView.contentOffset.y > 0) {
            [panRecognizer setTranslation:CGPointZero inView:panRecognizer.view];
            self.topCard.scrollView.scrollEnabled = YES;
            return;
        }
        
        CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
        CGPoint velocity = [panRecognizer velocityInView:panRecognizer.view];
        UICollectionViewTransitionLayout *transitionalLayout = (id)self.collectionView.collectionViewLayout;
        
        if(self.collectionView.collectionViewLayout == self.currentTransitioningLayout) {
            if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMinViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:[CharCardsMaxViewLayout class]]) {
                CharCardsMinViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
                CharCardsMaxViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
                CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.minHeight - nextLayout.topInset;
                
                if(-velocity.y > CC2_SNAP_VELOCITY) [self.collectionView finishInteractiveTransition];
                else if(-velocity.y < -CC2_SNAP_VELOCITY) [self.collectionView cancelInteractiveTransition];
                else if(-translation.y < maxDistance*CC2_SNAP_RATIO) [self.collectionView cancelInteractiveTransition];
                else [self.collectionView finishInteractiveTransition];
                self.panRecognizer.enabled = NO;
            } else if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMaxViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:[CharCardsMinViewLayout class]]) {
                CharCardsMaxViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
                CharCardsMinViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
                CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.topInset - nextLayout.minHeight;
                
                if(velocity.y > CC2_SNAP_VELOCITY) [self.collectionView finishInteractiveTransition];
                else if(velocity.y < -CC2_SNAP_VELOCITY) [self.collectionView cancelInteractiveTransition];
                else if(translation.y < maxDistance*CC2_SNAP_RATIO) [self.collectionView cancelInteractiveTransition];
                else [self.collectionView finishInteractiveTransition];
                self.panRecognizer.enabled = NO;
            }
        }
    }
}

-(UICollectionView *) collectionView {
    if(_collectionView) return _collectionView;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.noneLayout];
    _collectionView.pagingEnabled = YES;
    _collectionView.dataSource = self;
    _collectionView.allowsSelection = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.clipsToBounds = NO;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_collectionView];
    return _collectionView;
}

-(void) setMinHeight:(CGFloat)minHeight {
    _minHeight = minHeight;
    self.minLayout.minHeight = minHeight;
    [self.minLayout invalidateLayout];
}
-(void) setTopInset:(CGFloat)topInset {
    _topInset = topInset;
    NSLog(@"set inset: %f", topInset);
    self.maxLayout.topInset = topInset;
    [self.maxLayout invalidateLayout];
}

-(void) push:(id) data withIdentifier:(NSString *) identifier completion:(void (^)(BOOL finished))completion {
    [self push:data withIdentifier:identifier state:CharCardsViewStateMin completion:completion];
}

-(void) push:(id)data withIdentifier:(NSString *) identifier state:(CharCardsViewState) state completion:(void (^)(BOOL finished))completion {
    self.panRecognizer.enabled = NO;
    
    CharCardsViewState oldState = [self currentState];
    if(oldState == CharCardsViewStateTransitioning) oldState = CharCardsViewStateMin;
    
    if(state == CharCardsViewStateCurrent) state = (oldState == CharCardsViewStateNone)?CharCardsViewStateMin:oldState;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.cardsType.count inSection:0];
    [self.cardsType addObject:identifier];
    [self.cardsData addObject:data];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[path]];
    } completion:^(BOOL finished) {
        if(completion) completion(finished);
        
        if(self.panningEnabled) self.panRecognizer.enabled = YES;
        
        if(oldState == CharCardsViewStateNone) [self _setState:state fromState:oldState];
        if([self currentState] == CharCardsViewStateMax) self.topCard.scrollView.scrollEnabled = YES;
        else self.topCard.scrollView.scrollEnabled = NO;
    }];
}

-(void) setState:(CharCardsViewState) state {
    self.topCard.scrollView.scrollEnabled = NO;
    if(state == CharCardsViewStateNone) {
        CharCardsViewState oldState = [self currentState];
        if(oldState == CharCardsViewStateTransitioning) oldState = CharCardsViewStateMin;
        [self _setState:state fromState:oldState];
        
        NSMutableArray *pathsToRemove = [NSMutableArray array];
        for(NSUInteger i=0; i<self.cardsType.count; i++) { [pathsToRemove addObject:[NSIndexPath indexPathForRow:i inSection:0]];}
        self.cardsType = [NSMutableArray array];
        self.cardsData = [NSMutableArray array];
        
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:pathsToRemove];
        } completion:^(BOOL finished) {}];
        
    } else if(state == CharCardsViewStateMin) {
        CharCardsViewState oldState = [self currentState];
        if(oldState == CharCardsViewStateTransitioning) oldState = CharCardsViewStateMin;
        [self _setState:state fromState:oldState];
    } else if(state == CharCardsViewStateMax) {
        CharCardsViewState oldState = [self currentState];
        if(oldState == CharCardsViewStateTransitioning) oldState = CharCardsViewStateMin;
        [self _setState:state fromState:oldState];
    }
}

-(void) _setState:(CharCardsViewState) newState fromState:(CharCardsViewState) oldState {
    BOOL transitional = [[self.collectionView collectionViewLayout] isKindOfClass:[UICollectionViewTransitionLayout class]];
    
    [UIView animateWithDuration:0.6f
                          delay:0
         usingSpringWithDamping:.8f initialSpringVelocity:1.1f
                        options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                            if(newState == CharCardsViewStateNone && !transitional) {
                                self.collectionView.collectionViewLayout = self.noneLayout;
                            } else if(newState == CharCardsViewStateMin && !transitional) {
                                self.collectionView.collectionViewLayout = self.minLayout;
                                [self.topCard.scrollView setContentOffset:CGPointZero animated:NO];
                            } else if(newState == CharCardsViewStateMax && !transitional) {
                                self.collectionView.collectionViewLayout = self.maxLayout;
                            }
                            [self.delegate cardsView:self willChangeState:newState fromOldState:oldState];
                            
                        } completion:^(BOOL finished) {
                            self.topCard.scrollView.scrollEnabled = (newState == CharCardsViewStateMax);
                            [self.delegate cardsView:self didChangeState:newState fromOldState:oldState];
                        }];
}

-(void)registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier { [self.collectionView registerClass:cardClass forCellWithReuseIdentifier:identifier]; }

#pragma mark UICollectionViewDataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {return 1;}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cardsType.count;
}
-(CharCardCollectionView *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self.cardsType objectAtIndex:indexPath.row];
    id data = [self.cardsData objectAtIndex:indexPath.row];
    if(data == [NSNull null]) data = nil;
    
    CharCardCollectionView *card = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [card updateWithData:data layout:self.collectionView.collectionViewLayout];
    return card;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CharCardsViewState state = [self currentState];
    if(state == CharCardsViewStateNone) { return NO;}
    else if(state == CharCardsViewStateMin) {
        CGPoint cPoint = [self convertPoint:point toView:self.collectionView];
        return [self.collectionView indexPathForItemAtPoint:cPoint] != nil;
    } else if(self.propagateTapEvents) {
        CGPoint tPoint = [self convertPoint:point toView:self.topCard];
        return [self.topCard pointInside:tPoint withEvent:event];
    } else return [super pointInside:point withEvent:event];
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void) setNeedsDisplay {
    [super setNeedsDisplay];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

@end
