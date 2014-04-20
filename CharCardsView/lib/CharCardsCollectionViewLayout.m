//
//  CharCardsCollectionViewLayout.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsCollectionViewLayout.h"

@implementation CharCardsCollectionViewLayout

-(UICollectionViewLayoutAttributes *) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes* attrs = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    return attrs;
}

-(UICollectionViewLayoutAttributes *) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes* attrs = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    return attrs;
}
@end
