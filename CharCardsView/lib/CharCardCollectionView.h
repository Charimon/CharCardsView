//
//  CharCardCollectionView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardsConstants.h"

@class CharCardsCollectionView;

@interface CharCardCollectionView : UICollectionViewCell
//everything must be inside contentView
@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic) CGFloat maxTopInset;

-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState;
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState;
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height;
-(void) updateWithState:(CharCardsViewState) state data:(id) data;

@property (strong, nonatomic) UITapGestureRecognizer *maxInsetTapRecognizer;
@property (weak, nonatomic) CharCardsCollectionView *cardsCollectionView;
@end
