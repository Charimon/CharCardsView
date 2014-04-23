//
//  CharCardsCollectionViewLayout.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/19/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsMinViewLayout.h"
#import "CharCardsLayoutAttributes.h"
@interface CharCardsMinViewLayout()
@property (nonatomic, strong) NSMutableSet *deleteIndexPaths;
@property (nonatomic, strong) NSMutableSet *insertIndexPaths;
@property (nonatomic) NSUInteger numberOfItems;
@end

@implementation CharCardsMinViewLayout
-(instancetype) init {return nil;}
-(instancetype) initWithMinHeight:(CGFloat)minHeight {
    self = [super init];
    if(self) {
        self.minHeight = minHeight;
    }
    return self;
}


-(void) prepareLayout {
    [super prepareLayout];
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
}

-(void) prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableSet set];
    self.insertIndexPaths = [NSMutableSet set];
    
    for (UICollectionViewUpdateItem *update in updateItems)
    {
        if (update.updateAction == UICollectionUpdateActionDelete) [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        else if (update.updateAction == UICollectionUpdateActionInsert) [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
    }
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

-(UICollectionViewLayoutAttributes *) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath: itemIndexPath];
    if (![self.insertIndexPaths containsObject:itemIndexPath]) return attributes;
    
    CGFloat attrCenterX = self.collectionView.center.x;
    CGFloat attrCenterY = self.collectionView.bounds.size.height + self.minHeight/2;
    if(self.numberOfItems > 1) {
        attrCenterX = self.collectionView.bounds.size.width + self.collectionView.center.x;
        attrCenterY = self.collectionView.bounds.size.height - self.minHeight/2;
    }
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.minHeight);
    attributes.center = CGPointMake(attrCenterX, attrCenterY);
    return attributes;
}

-(UICollectionViewLayoutAttributes *) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath: itemIndexPath];
    if (![self.deleteIndexPaths containsObject:itemIndexPath]) return attributes;
    
    CGFloat attrCenterX = self.collectionView.center.x;
    CGFloat attrCenterY = self.collectionView.bounds.size.height + self.minHeight/2;
    if(self.numberOfItems > 0) {
        attrCenterX = self.collectionView.bounds.size.width + self.collectionView.center.x;
        attrCenterY = self.collectionView.bounds.size.height - self.minHeight/2;
    }
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.minHeight);
    attributes.center = CGPointMake(attrCenterX, attrCenterY);
    return attributes;
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
    CGFloat attrCenterY = self.collectionView.bounds.size.height - self.minHeight/2;
    if(indexPath.row == self.numberOfItems-1) attrCenterX = self.collectionView.center.x;
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.minHeight);
    attributes.center = CGPointMake(attrCenterX, attrCenterY);
    return attributes;
}

-(BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
@end
