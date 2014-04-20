//
//  CharCardsCollectionView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardCollectionView.h"
#import "CharCardsConstants.h"

@class CharCardsCollectionView;

@protocol CharCardsCollectionViewDelegate <NSObject>
@optional
-(void) cardsView:(CharCardsCollectionView *) cardsView willChangeState:(CharCardsViewState) newState fromOldState:(CharCardsViewState) oldState forIdentifier:(NSString *) identifier data:(id) data;
-(void) cardsView:(CharCardsCollectionView *) cardsView didChangeState:(CharCardsViewState) newState fromOldState:(CharCardsViewState) oldState forIdentifier:(NSString *) identifier data:(id) data;
-(void) cardsView:(CharCardsCollectionView *) cardsView didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height forIdentifier:(NSString *) identifier data:(id) data;
@end

@interface CharCardsCollectionView : UIView
@property (nonatomic) CGFloat minHeight;
@property (strong, nonatomic) UIPanGestureRecognizer *panRecognizer;

//state changes only AFTER animation finishes
@property (nonatomic) CharCardsViewState state;
@property (strong, nonatomic, readonly) CharCardCollectionView *visibleCard;
@property (weak, nonatomic) id<CharCardsCollectionViewDelegate> cardsDelegate;
-(void)registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier;


-(void) setState:(CharCardsViewState) state animated:(BOOL) animated;
//appends at current state, or MIN if current state is NONE
-(void) appendWithIdentifier: (NSString *) identifier data:(id) data animated:(BOOL) animated;
-(void) appendWithIdentifier: (NSString *) identifier data:(id) data atState:(CharCardsViewState) state animated:(BOOL) animated;



@end
