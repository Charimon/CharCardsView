//
//  CharCardsCollectionView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardsConstants.h"
#import "CharCardCollectionView.h"
@class CharCardsCollectionView;

@protocol CharCardsCollectionViewDelegate <NSObject>
@optional
-(void) cardsView:(CharCardsCollectionView *) cardsView willChangeState:(CharCardsViewState) newState fromOldState:(CharCardsViewState) oldState;
-(void) cardsView:(CharCardsCollectionView *) cardsView didChangeState:(CharCardsViewState) newState fromOldState:(CharCardsViewState) oldState;
@end

@interface CharCardsCollectionView : UIView
-(instancetype) initWithTransitionType: (CharCardsTransitionType) transitionType;

@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat topInset;
@property (strong, nonatomic, readonly) CharCardCollectionView *topCard;
@property (weak, nonatomic) id<CharCardsCollectionViewDelegate> delegate;

@property (nonatomic) BOOL panningEnabled;
@property (nonatomic) BOOL tapEnabled;
@property (nonatomic) CGFloat animationDuration;

@property (nonatomic) BOOL propagateTapEvents;

-(void) registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier;
-(void) setState:(CharCardsViewState) state;
-(CharCardsViewState) currentState;

-(void) push:(id)data withIdentifier:(NSString *) identifier state:(CharCardsViewState) state completion:(void (^)(BOOL finished, CharCardsViewState state))completion;
@end
