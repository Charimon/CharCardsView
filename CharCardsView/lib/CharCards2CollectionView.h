//
//  CharCards2CollectionView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardsConstants.h"
#import "CharCard2CollectionView.h"

@interface CharCards2CollectionView : UIView
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat topInset;
@property (strong, nonatomic, readonly) CharCard2CollectionView *topCard;
@property (nonatomic, readonly) CharCardsViewState state;

-(void) registerClass:(Class)cardClass forCardWithReuseIdentifier:(NSString *)identifier;
-(void) setState:(CharCardsViewState) state;

-(void) push:(id) data withIdentifier:(NSString *) identifier;
-(void) push:(id) data withIdentifier:(NSString *) identifier state:(CharCardsViewState) state;
@end
