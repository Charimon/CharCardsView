//
//  CharCardsCollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsCollectionView.h"
#import "CharCardsCollectionViewLayout.h"

@interface CharCardsCollectionView() <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSLayoutConstraint *collectionViewTopConstraint;

//cardsType have to be in sync
@property (strong, nonatomic) NSMutableArray *cardsType;
@property (strong, nonatomic) NSMutableArray *cardsData;

//@property (strong, nonatomic) UITapGestureRecognizer *topInsetTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *minStateTapRecognizer;

@property (atomic) BOOL panning;

//only used for collectionView:cellForItemAtIndexPath:
@property (nonatomic) CharCardsViewState desiredState;
@end

@implementation CharCardsCollectionView


CGFloat const CCV_DEFAULT_VERTICAL_DURATION = .5f;
CGFloat const CCV_DEFAULT_VERTICAL_DAMPING = .8f;
CGFloat const CCV_DEFAULT_VERTICAL_VELOCITY = 1.1f;
CGFloat const CCV_SNAP_RATIO = .3333333f;


-(instancetype) init {
    self = [super init];
    if(self) {
        self.clipsToBounds = YES;
        self.cardsType = [[NSMutableArray alloc] init];
        self.cardsData = [[NSMutableArray alloc] init];
        [self addGestureRecognizer:self.minStateTapRecognizer];
        [self addGestureRecognizer:self.panRecognizer];
        
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
                               ]];
        self.collectionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.f
                                                                         constant:0.f];
        
        [self addConstraint: self.collectionViewTopConstraint];
    }
    return self;
}

-(CharCardCollectionView *) visibleCard {
    NSArray *visibleCells = [self.collectionView visibleCells];
    if(visibleCells.count > 0) {
        return [visibleCells objectAtIndex:0];
    } else return nil;
}

-(UITapGestureRecognizer *) minStateTapRecognizer {
    if(_minStateTapRecognizer) return _minStateTapRecognizer;
    _minStateTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(minStateTapped:)];
    _minStateTapRecognizer.delegate = self;
    return _minStateTapRecognizer;
}
-(void) minStateTapped: (UITapGestureRecognizer *) minStateTapRecognizer {
    [self _setState:CharCardsViewStateMax withVelocity:CCV_DEFAULT_VERTICAL_VELOCITY];
}

-(void) _setState:(CharCardsViewState) state withVelocity:(CGFloat) velocity{
    [UIView animateWithDuration:CCV_DEFAULT_VERTICAL_DURATION
                          delay:0
         usingSpringWithDamping:CCV_DEFAULT_VERTICAL_DAMPING
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if(state == CharCardsViewStateNone) self.collectionViewTopConstraint.constant = 0;
                         else if(state == CharCardsViewStateMin) self.collectionViewTopConstraint.constant = -self.minHeight;
                         else if(state == CharCardsViewStateMax) self.collectionViewTopConstraint.constant = -self.bounds.size.height;
                         
                         if([self.cardsDelegate respondsToSelector:@selector(cardsView:willChangeState:fromOldState:forIdentifier:data:)]) {
                             [self.cardsDelegate cardsView:self willChangeState:state fromOldState:self.state forIdentifier:nil data:nil];
                         }
                         [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(CharCardCollectionView *card, NSUInteger idx, BOOL *stop) {
                             [card willChangeState:state fromOldState:self.state];
                         }];
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if(finished) {
                             if([self.cardsDelegate respondsToSelector:@selector(cardsView:didChangeState:fromOldState:forIdentifier:data:)]) {
                                 [self.cardsDelegate cardsView:self didChangeState:state fromOldState:self.state forIdentifier:nil data:nil];
                             }
                             
                             [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(CharCardCollectionView *card, NSUInteger idx, BOOL *stop) {
                                 [card didChangeState:state fromOldState:self.state];
                                 [card.scrollView setContentOffset:CGPointZero animated:NO];
                                 if(state == CharCardsViewStateMax) {card.scrollView.scrollEnabled = YES;}
                             }];
                             
                             if(state == CharCardsViewStateNone){
                                 self.cardsType = [[NSMutableArray alloc] init];
                                 self.cardsData = [[NSMutableArray alloc] init];
                                 
                                 NSInteger count = [self.collectionView numberOfItemsInSection:0];
                                 NSMutableArray *removePaths = [[NSMutableArray alloc] initWithCapacity:count];
                                 
                                 for(NSInteger i=0; i<count; i++) {
                                     [removePaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                 }
                                 
                                 [self.collectionView performBatchUpdates:^{
                                     [self.collectionView deleteItemsAtIndexPaths:removePaths];
                                 } completion:^(BOOL finished) {}];
                             } else if(state == CharCardsViewStateMin) {
                                 self.minStateTapRecognizer.enabled = YES;
                             } else if(state == CharCardsViewStateMax) {
                                 self.minStateTapRecognizer.enabled = NO;
                             }
                             
                             self.state = state;
                         }
                     }];
}

-(UIPanGestureRecognizer *) panRecognizer {
    if(_panRecognizer) return _panRecognizer;
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    _panRecognizer.delegate = self;
    return _panRecognizer;
}

-(void) dragging:(UIPanGestureRecognizer *) dragRecognizer {
    if(dragRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panning = YES;
        self.minStateTapRecognizer.enabled = NO;
    } else if(dragRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [dragRecognizer translationInView:dragRecognizer.view];
        
//        if(self.card.contentView.contentOffset.y > 0) {
//            [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
//            return;
//        }
        
        if(self.state == CharCardsViewStateMin) {
            self.collectionViewTopConstraint.constant = -self.minHeight + translation.y;
            if(self.collectionViewTopConstraint.constant > -self.minHeight){
                self.collectionViewTopConstraint.constant = -self.minHeight;
                [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
            }
            if(self.collectionViewTopConstraint.constant < -self.bounds.size.height){
                self.collectionViewTopConstraint.constant = -self.bounds.size.height;
                [dragRecognizer setTranslation:CGPointMake(0, translation.y) inView:dragRecognizer.view];
            }
        } else if(self.state == CharCardsViewStateMax) {
            self.collectionViewTopConstraint.constant = -self.bounds.size.height + translation.y;
            if(self.collectionViewTopConstraint.constant > -self.minHeight){
                self.collectionViewTopConstraint.constant = -self.minHeight;
                [dragRecognizer setTranslation:CGPointMake(0, translation.y) inView:dragRecognizer.view];
            }
            if(self.collectionViewTopConstraint.constant < -self.bounds.size.height){
                self.collectionViewTopConstraint.constant = -self.bounds.size.height;
                [dragRecognizer setTranslation:CGPointZero inView:dragRecognizer.view];
            }
        }
        CGFloat distanceFromBottom = -self.collectionViewTopConstraint.constant - self.minHeight;
        CGFloat maxDistance = self.collectionView.bounds.size.height - self.minHeight;
        
        [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(CharCardCollectionView *card, NSUInteger idx, BOOL *stop) {
            [card didChangeVerticalPositionFromBottom:distanceFromBottom inHeight:maxDistance];
            if([self.cardsDelegate respondsToSelector:@selector(cardsView:didChangeVerticalPositionFromBottom:inHeight:forIdentifier:data:)]) {
                [self.cardsDelegate cardsView:self didChangeVerticalPositionFromBottom:distanceFromBottom inHeight:maxDistance forIdentifier:@"" data:nil];
            }
            card.scrollView.scrollEnabled = NO;
        }];
        
    } else if(dragRecognizer.state == UIGestureRecognizerStateEnded ||
              dragRecognizer.state == UIGestureRecognizerStateCancelled ||
              dragRecognizer.state == UIGestureRecognizerStateFailed) {
        
        self.panning = NO;
        CGFloat maxDistance = self.collectionView.bounds.size.height - self.minHeight;
        CGFloat distanceFromBottom = -self.collectionViewTopConstraint.constant;
        
        
        CGFloat distanceFromTop = maxDistance-distanceFromBottom;
        CGFloat yVelocity = [dragRecognizer velocityInView:dragRecognizer.view].y;

        if(self.state == CharCardsViewStateMin) {
            if(yVelocity < -1000){
                [self _setState:CharCardsViewStateMax withVelocity:ABS(yVelocity/distanceFromTop)];
            }
            else if(distanceFromBottom < maxDistance*CCV_SNAP_RATIO){
                [self _setState:CharCardsViewStateMin withVelocity:CCV_DEFAULT_VERTICAL_VELOCITY];
            }
            else {
                NSLog(@"distance: %f", distanceFromTop);
                [self _setState:CharCardsViewStateMax withVelocity:ABS(yVelocity/distanceFromTop)];
            }
        } else if(self.state == CharCardsViewStateMax) {
            if(yVelocity > 1000) [self _setState:CharCardsViewStateMin withVelocity:ABS(yVelocity/distanceFromBottom)];
            else if( (maxDistance-distanceFromBottom) < maxDistance*CCV_SNAP_RATIO) [self _setState:CharCardsViewStateMax withVelocity:CCV_DEFAULT_VERTICAL_VELOCITY];
            else [self _setState:CharCardsViewStateMin withVelocity:ABS(yVelocity/distanceFromBottom)];
        }
    }
}


-(UICollectionView *) collectionView {
    if(_collectionView) return _collectionView;
    CharCardsCollectionViewLayout* layout = [[CharCardsCollectionViewLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.allowsSelection = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.clipsToBounds = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_collectionView];
    return _collectionView;
}

- (void)registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier { [self.collectionView registerClass:cardClass forCellWithReuseIdentifier:identifier]; }
-(void) setState:(CharCardsViewState) state animated:(BOOL) animated {
    self.desiredState = state;
    [self _setState:state withVelocity:CCV_DEFAULT_VERTICAL_VELOCITY];
}

-(void) appendWithIdentifier: (NSString *) identifier data:(id) data animated:(BOOL) animated; {
    if(self.state == CharCardsViewStateNone) [self appendWithIdentifier:identifier data:data atState:CharCardsViewStateMin animated:animated];
    else [self appendWithIdentifier:identifier data:data atState:self.state animated:animated];
}
-(void) appendWithIdentifier: (NSString *) identifier data:(id) data atState:(CharCardsViewState) state animated:(BOOL) animated {
    if(!identifier || state == CharCardsViewStateNone) return;
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.cardsType.count inSection:0];
    [self.cardsType addObject:identifier];
    [self.cardsData addObject:data];
    
    [self.collectionView performBatchUpdates:^{
        self.desiredState = state;
        [self.collectionView insertItemsAtIndexPaths:@[path]];
    } completion:^(BOOL finished) {
        [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        
        if(self.cardsType.count == 1 || self.state != state) {
            [self _setState:state withVelocity:CCV_DEFAULT_VERTICAL_VELOCITY];
        }
    }];
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.cardsType = [[NSMutableArray alloc] initWithObjects:self.cardsType.lastObject, nil] ;
    self.cardsData = [[NSMutableArray alloc] initWithObjects:self.cardsData.lastObject, nil] ;
    [self.collectionView reloadData];

}

#pragma mark UICollectionViewDataSource
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {return 1;}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cardsType.count;
}
-(CharCardCollectionView *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self.cardsType objectAtIndex:indexPath.row];
    id data = [self.cardsData objectAtIndex:indexPath.row];

    CharCardCollectionView *card = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    card.cardsCollectionView = self;
    [card updateWithState:(self.state == CharCardsViewStateNone?self.desiredState:self.state) data:data];
    return card;
}

#pragma mark UICollectionViewDelegate
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section { return 0.f; }
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section { return 0.f; }
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if(gestureRecognizer == self.minStateTapRecognizer) {
        return self.state == CharCardsViewStateMin;
    } else if(gestureRecognizer == self.panRecognizer) {
        return CGRectContainsPoint(self.collectionView.bounds, [touch locationInView:self.collectionView]);
    } else return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint collectinoViewPoint = [self convertPoint:point toView:self.collectionView];
    BOOL pointInside = [self.collectionView pointInside:collectinoViewPoint withEvent:event];
    return pointInside;
}

-(void) setNeedsDisplay {
    [super setNeedsDisplay];
    self.visibleCard.bounds = self.collectionView.bounds;
}

@end
