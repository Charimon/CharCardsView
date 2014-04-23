//
//  CharCards2CollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCards2CollectionView.h"
#import "CharCardsMinViewLayout.h"
#import "CharCardsMaxViewLayout.h"

@interface CharCards2CollectionView() <UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

@property (strong, nonatomic) CharCardsMinViewLayout *minLayout;
@property (strong, nonatomic) CharCardsMaxViewLayout *maxLayout;

@property (atomic) BOOL transitioning;

@property (strong, nonatomic, readwrite) CharCard2CollectionView *topCard;

//cardsType have to be in sync
@property (strong, nonatomic) NSMutableArray *cardsType;
@property (strong, nonatomic) NSMutableArray *cardsData;
@end

@implementation CharCards2CollectionView

CGFloat const CC2_SNAP_RATIO = .3333333f;
CGFloat const CC2_SNAP_VELOCITY = 1000.f;

-(instancetype) init {
    self = [super init];
    if(self) {
        self.clipsToBounds = YES;
        self.cardsType = [[NSMutableArray alloc] init];
        self.cardsData = [[NSMutableArray alloc] init];
        
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
    }
    return self;
}

-(CharCardsViewState ) state {
    if(self.collectionView.collectionViewLayout == self.minLayout) return CharCardsViewStateMin;
    else if(self.collectionView.collectionViewLayout == self.maxLayout) return CharCardsViewStateMax;
    else return CharCardsViewStateNone;
}

-(CharCardsMinViewLayout *) minLayout {
    if(_minLayout) return _minLayout;
    _minLayout = [[CharCardsMinViewLayout alloc] initWithMinHeight:self.minHeight];
    return _minLayout;
}

-(CharCardsMaxViewLayout *) maxLayout {
    if(_maxLayout) return _maxLayout;
    _maxLayout = [[CharCardsMaxViewLayout alloc] initWithTopInset:self.topInset];
    return _maxLayout;
}

-(CharCard2CollectionView *) topCard {
    if([self.collectionView visibleCells].count > 0) return [[self.collectionView visibleCells] objectAtIndex:0];
    else return nil;
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

    if(self.collectionView.collectionViewLayout == self.minLayout && [self.collectionView indexPathForItemAtPoint:tapPoint]) {
        [self.collectionView setCollectionViewLayout:self.maxLayout animated:YES];
    } else if(self.collectionView.collectionViewLayout == self.maxLayout && ![self.collectionView indexPathForItemAtPoint:tapPoint]) {
        [self.collectionView setCollectionViewLayout:self.minLayout animated:YES];
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
        
        if(self.transitioning) return;
        UICollectionViewLayout *newLayout = (self.collectionView.collectionViewLayout == self.maxLayout)?self.minLayout:self.maxLayout;
        self.transitioning = YES;
        [self.collectionView startInteractiveTransitionToCollectionViewLayout:newLayout completion:^(BOOL completed, BOOL finish) {
            self.transitioning = NO;
            if(self.collectionView.collectionViewLayout == self.minLayout) self.topCard.scrollView.scrollEnabled = NO;
        }];
    } else if(panRecognizer.state == UIGestureRecognizerStateChanged) {
        if(![self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewTransitionLayout class]]) return;
        if(self.topCard.scrollView.contentOffset.y > 0) {
            [panRecognizer setTranslation:CGPointZero inView:panRecognizer.view];
            return;
        }
        
        self.topCard.scrollView.scrollEnabled = NO;
        
        CGPoint translation = [panRecognizer translationInView:panRecognizer.view];
        UICollectionViewTransitionLayout *transitionalLayout = (id)self.collectionView.collectionViewLayout;
        
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
            
        } else if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMaxViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:[CharCardsMinViewLayout class]]) {
            CharCardsMaxViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
            CharCardsMinViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
            CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.topInset - nextLayout.minHeight;
            
            if(translation.y > 0) {
                transitionalLayout.transitionProgress = translation.y/maxDistance;
                if(transitionalLayout.transitionProgress > 1) [panRecognizer setTranslation:CGPointZero inView:panRecognizer.view];
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
        
        if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMinViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:[CharCardsMaxViewLayout class]]) {
            CharCardsMinViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
            CharCardsMaxViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
            CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.minHeight - nextLayout.topInset;
            
            if(-velocity.y > CC2_SNAP_VELOCITY) [self.collectionView finishInteractiveTransition];
            else if(-velocity.y < -CC2_SNAP_VELOCITY) [self.collectionView cancelInteractiveTransition];
            else if(-translation.y < maxDistance*CC2_SNAP_RATIO) [self.collectionView cancelInteractiveTransition];
            else [self.collectionView finishInteractiveTransition];
        } else if([transitionalLayout.currentLayout isKindOfClass:[CharCardsMaxViewLayout class]] && [transitionalLayout.nextLayout isKindOfClass:[CharCardsMinViewLayout class]]) {
            CharCardsMaxViewLayout *currentLayout = (id)transitionalLayout.currentLayout;
            CharCardsMinViewLayout *nextLayout = (id)transitionalLayout.nextLayout;
            CGFloat maxDistance = self.collectionView.bounds.size.height - currentLayout.topInset - nextLayout.minHeight;
            
            if(velocity.y > CC2_SNAP_VELOCITY) [self.collectionView finishInteractiveTransition];
            else if(velocity.y < -CC2_SNAP_VELOCITY) [self.collectionView cancelInteractiveTransition];
            else if(translation.y < maxDistance*CC2_SNAP_RATIO) [self.collectionView cancelInteractiveTransition];
            else [self.collectionView finishInteractiveTransition];
        }
        self.topCard.scrollView.scrollEnabled = YES;
    }
}

-(UICollectionView *) collectionView {
    if(_collectionView) return _collectionView;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.minLayout];
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
    self.maxLayout.topInset = topInset;
    [self.maxLayout invalidateLayout];
}

-(void) push:(id) data withIdentifier:(NSString *) identifier {
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.cardsType.count inSection:0];
    [self.cardsType addObject:identifier];
    [self.cardsData addObject:data];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[path]];
    } completion:^(BOOL finished) {
        if(self.collectionView.collectionViewLayout == self.maxLayout) self.topCard.scrollView.scrollEnabled = YES;
        else self.topCard.scrollView.scrollEnabled = NO;
    }];
}
-(void) push:(id) data withIdentifier:(NSString *) identifier state:(CharCardsViewState) state {
    if(state == CharCardsViewStateNone) return;
    else if(state == CharCardsViewStateMin) {
        [self.collectionView setCollectionViewLayout:self.minLayout animated:YES completion:^(BOOL finished) {}];
        [self push:data withIdentifier:identifier];
    } else if(state == CharCardsViewStateMax) {
        [self.collectionView setCollectionViewLayout:self.maxLayout animated:YES completion:^(BOOL finished) {}];
        [self push:data withIdentifier:identifier];
    }
}

-(void) setState:(CharCardsViewState) state {
    self.topCard.scrollView.scrollEnabled = NO;
    if(state == CharCardsViewStateNone) {
        NSMutableArray *pathsToRemove = [NSMutableArray array];
        for(NSUInteger i=0; i<self.cardsType.count; i++) { [pathsToRemove addObject:[NSIndexPath indexPathForRow:i inSection:0]];}
        self.cardsType = [NSMutableArray array];
        self.cardsData = [NSMutableArray array];
        [self.collectionView performBatchUpdates:^{ [self.collectionView deleteItemsAtIndexPaths:pathsToRemove];} completion:^(BOOL finished) {}];
    } else if(state == CharCardsViewStateMin) {
        __typeof__(self) __weak weakSelf = self;
        [self.collectionView setCollectionViewLayout:self.minLayout animated:YES completion:^(BOOL finished) {
            if(weakSelf.collectionView.collectionViewLayout == weakSelf.maxLayout) weakSelf.topCard.scrollView.scrollEnabled = YES;
            else weakSelf.topCard.scrollView.scrollEnabled = NO;
        }];
    } else if(state == CharCardsViewStateMax) {
        __typeof__(self) __weak weakSelf = self;
        [self.collectionView setCollectionViewLayout:self.maxLayout animated:YES completion:^(BOOL finished) {
            if(weakSelf.collectionView.collectionViewLayout == weakSelf.maxLayout) weakSelf.topCard.scrollView.scrollEnabled = YES;
            else weakSelf.topCard.scrollView.scrollEnabled = NO;
        }];

    }
}

-(void)registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:cardClass forCellWithReuseIdentifier:identifier];
}

#pragma mark UICollectionViewDataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {return 1;}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cardsType.count;
}
-(CharCard2CollectionView *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self.cardsType objectAtIndex:indexPath.row];
    id data = [self.cardsData objectAtIndex:indexPath.row];
    CharCard2CollectionView *card = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [card updateWithData:data];
    return card;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(self.collectionView.collectionViewLayout == self.minLayout) {
        CGPoint cPoint = [self convertPoint:point toView:self.collectionView];
        return [self.collectionView indexPathForItemAtPoint:cPoint] != nil;
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
