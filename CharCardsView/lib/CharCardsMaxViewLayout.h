//
//  CharCardsMaxViewLayout.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardsConstants.h"

@interface CharCardsMaxViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat topInset;
-(instancetype) initWithTopInset:(CGFloat) topInset;
@property (nonatomic) CharCardsTransitionType transitionType;
@end
