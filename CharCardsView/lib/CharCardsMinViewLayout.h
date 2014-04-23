//
//  CharCardsCollectionViewLayout.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharCardsConstants.h"

@interface CharCardsMinViewLayout : UICollectionViewLayout
@property (nonatomic) CGFloat minHeight;
-(instancetype) initWithMinHeight:(CGFloat) minHeight;
@end
