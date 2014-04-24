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
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat topInset;
@property (strong, nonatomic, readonly) CharCardCollectionView *topCard;
@property (weak, nonatomic) id<CharCardsCollectionViewDelegate> delegate;

-(void) registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier;
-(void) setState:(CharCardsViewState) state;

-(void) push:(id) data withIdentifier:(NSString *) identifier;
@end
