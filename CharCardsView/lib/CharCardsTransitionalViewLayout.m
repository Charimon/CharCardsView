//
//  CharCardsTransitionalViewLayout.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsTransitionalViewLayout.h"

@interface CharCardsTransitionalViewLayout()
@property (nonatomic) NSUInteger numberOfItems;
@end

@implementation CharCardsTransitionalViewLayout

-(void) prepareLayout {
    [super prepareLayout];
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
}

-(CGSize)collectionViewContentSize { return self.collectionView.bounds.size;}

-(NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for(NSUInteger i=0; i<self.numberOfItems; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}
-(UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat attrCenterX = -self.collectionView.center.x;
    CGFloat attrCenterY = self.collectionView.center.y;
    if(indexPath.row == self.numberOfItems-1) attrCenterX = self.collectionView.center.x;
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height - self.panningCenter.y);
    attributes.center = CGPointMake(attrCenterX, attrCenterY + self.panningCenter.y);
    return attributes;
}

@end
