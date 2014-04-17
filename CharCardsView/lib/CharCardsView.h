//
//  CharCardsView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardView.h"
#import "CharCardsConstants.h"
@class CharCardsView;

@protocol CharCardsViewDelegate <NSObject>
-(void) cardsView:(CharCardsView *) cardsView willChangeState:(CharCardsViewState) newState fromOldState:(CharCardsViewState) oldState forCard:(CharCardView *) card;
-(void) cardsView:(CharCardsView *) cardsView didChangeState:(CharCardsViewState) newState fromOldState:(CharCardsViewState) oldState forCard:(CharCardView *) card;
-(void) cardsView:(CharCardsView *) cardsView didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height forCard:(CharCardView *) card;;
@end

@interface CharCardsView : UIView
//public
@property (strong, nonatomic) CharCardView *card;
@property (strong, nonatomic) id<CharCardsViewDelegate> delegate;
-(void) setState:(CharCardsViewState) state animated:(BOOL) animated;
-(void) appendCard: (CharCardView *) card animated:(BOOL) animated; //appends at current state, or MIN if current state is NONE
-(void) appendCard: (CharCardView *) card atState:(CharCardsViewState) state animated:(BOOL) animated;
//prepends at current state, or MIN if current state is NONE
//-(void) prependCard: (CharCardView *) card animated:(BOOL) animated;
//-(void) prependCard: (CharCardView *) card atState:(CharCardsViewState) state animated:(BOOL) animated;
@property (nonatomic) CGFloat minHeight; //height of card at MIN state

//most useful for debug, any animation durations are multiplied by this multiplier, 1.f by default
@property (nonatomic) CGFloat animationMultiplier;

//all 3 enabled by default
@property (nonatomic) BOOL topInsetTapRecognizerEnabled; //tapping on space created by maxTopInset, causing it to got to MIN
@property (nonatomic) BOOL minStateTapRecognizerEnabled; //tapping on the card in MIN state, causing it to go to MAX
@property (nonatomic) BOOL dragRecognizerEnabled; //draging of the card


//protected
@property (strong, nonatomic) CharCardView *oldCard; //only exists during animation
@property (nonatomic) CharCardsViewState state;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) NSLayoutConstraint *leadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) UITapGestureRecognizer *topInsetTapRecognizer; //gets deleted and reinstantiated sporadically
@property (strong, nonatomic) UITapGestureRecognizer *minStateTapRecognizer; //gets deleted and reinstantiated sporadically
@property (strong, nonatomic) UIPanGestureRecognizer *dragRecognizer; //gets deleted and reinstantiated sporadically
@end
