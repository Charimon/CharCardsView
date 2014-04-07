//
//  CharCardView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardsConstants.h"

@class CharCardsView;
//#import "CharCardsView.h"

@interface CharCardView : UIView
-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState;
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState;
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *insetView;

@property (weak, nonatomic) CharCardsView *cardsView;
@end
