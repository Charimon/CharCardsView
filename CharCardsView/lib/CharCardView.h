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

@interface CharCardView : UIView
-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState;
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState;
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height;
-(void) insetViewTapped;

//everything must be inside contentView
@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIView *insetView;
@property (strong, nonatomic) CAGradientLayer *shadow;

@property (weak, nonatomic) CharCardsView *cardsView;


//protected keyboard events
-(void) keyboardWillShow: (NSNotification *) notification;
-(void) keyboardDidShow: (NSNotification *) notification;
-(void) keyboardWillHide: (NSNotification *) notification;
-(void) keyboardDidHide: (NSNotification *) notification;
-(void) keyboardWillChangeFrame: (NSNotification *) notification;
-(void) keyboardDidChangeFrame: (NSNotification *) notification;
@end
