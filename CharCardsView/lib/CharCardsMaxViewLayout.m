//
//  CharCardsMaxViewLayout.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsMaxViewLayout.h"

@interface CharCardsMaxViewLayout()
@property (nonatomic, strong) NSMutableSet *deleteIndexPaths;
@property (nonatomic, strong) NSMutableSet *insertIndexPaths;
@property (nonatomic) NSUInteger numberOfItems;
@property (nonatomic) BOOL animatingBoundsChange;
@end

@implementation CharCardsMaxViewLayout
-(instancetype) initWithTopInset:(CGFloat) topInset {
    self = [super init];
    if(self) {
        self.topInset = topInset;
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
    
    for (UICollectionViewUpdateItem *update in updateItems) {
        if (update.updateAction == UICollectionUpdateActionDelete) [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        else if (update.updateAction == UICollectionUpdateActionInsert) [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
    }
}

-(UICollectionViewLayoutAttributes *) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    if(self.animatingBoundsChange) return nil;

    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath: itemIndexPath];
    if (![self.insertIndexPaths containsObject:itemIndexPath]) return attributes;
    
    
    CGFloat centerX = self.collectionView.center.x;
    CGFloat centerY = self.collectionView.center.y + self.topInset/2;
    
    if(self.numberOfItems > 1) {
        centerX = self.collectionView.bounds.size.width + self.collectionView.center.x-1;
    }
    
    attributes.alpha = 1.f;
    attributes.center = CGPointMake(centerX, centerY);
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height - self.topInset);

    return attributes;
}

-(CGSize)collectionViewContentSize { return self.collectionView.bounds.size;}

-(NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for(NSUInteger i=0; i<self.numberOfItems; i++) {
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
    }
    return attributes;
}
-(UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat centerX = self.collectionView.center.x;
    CGFloat centerY = self.collectionView.center.y + self.topInset/2;
    if(indexPath.row != self.numberOfItems - 1) centerX = -self.collectionView.center.x;

    attributes.alpha = 1.f;
    attributes.center = CGPointMake(centerX, centerY);
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height - self.topInset);
    
    return attributes;
}

-(BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds { return YES; }

-(void) prepareForAnimatedBoundsChange:(CGRect)oldBounds {
    [super prepareForAnimatedBoundsChange:oldBounds];
    self.animatingBoundsChange = YES;
}

-(void) finalizeAnimatedBoundsChange {
    [super finalizeAnimatedBoundsChange];
    self.animatingBoundsChange = NO;
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}
@end
