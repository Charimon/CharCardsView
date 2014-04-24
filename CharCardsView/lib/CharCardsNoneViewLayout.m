//
//  CharCardsNoneViewLayout.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/23/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsNoneViewLayout.h"
#import "CharCardsMaxViewLayout.h"
#import "CharCardsMinViewLayout.h"

@interface CharCardsNoneViewLayout()
@property (nonatomic, strong) NSMutableSet *deleteIndexPaths;
@property (nonatomic, strong) NSMutableSet *insertIndexPaths;
@property (nonatomic) NSUInteger numberOfItems;
@property (nonatomic) BOOL animatingBoundsChange;
@property (nonatomic) CGFloat height;
@end

@implementation CharCardsNoneViewLayout
-(void) prepareLayout {
    [super prepareLayout];
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
}

- (void)prepareForTransitionFromLayout:(UICollectionViewLayout*)oldLayout {
    if([oldLayout isKindOfClass:[CharCardsMinViewLayout class]]) {
        self.height = ((CharCardsMinViewLayout *)oldLayout).minHeight;
    } else if([oldLayout isKindOfClass:[CharCardsMaxViewLayout class]]) {
        self.height = self.collectionView.bounds.size.height - ((CharCardsMaxViewLayout *)oldLayout).topInset;
    }
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
    if(self.animatingBoundsChange) return nil;
    
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath: itemIndexPath];
    if (![self.insertIndexPaths containsObject:itemIndexPath]) return attributes;
    
    attributes.alpha = 1.f;
    attributes.center = CGPointMake(self.collectionView.center.x, self.collectionView.bounds.size.height + self.height/2);
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.height);
    return attributes;
}

-(UICollectionViewLayoutAttributes *) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    if (self.animatingBoundsChange) return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath: itemIndexPath];
    if (![self.deleteIndexPaths containsObject:itemIndexPath]) return attributes;
    
    attributes.alpha = 1.f;
    attributes.center = CGPointMake(self.collectionView.center.x, self.collectionView.bounds.size.height + self.height/2);
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.height);
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
    attributes.alpha = 1.f;
    attributes.center = CGPointMake(self.collectionView.center.x, self.collectionView.bounds.size.height + self.height/2 - 1);
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.height);
    return attributes;
}

-(void) prepareForAnimatedBoundsChange:(CGRect)oldBounds {
    [super prepareForAnimatedBoundsChange:oldBounds];
    self.animatingBoundsChange = YES;
}

-(void)finalizeAnimatedBoundsChange {
    [super finalizeAnimatedBoundsChange];
    self.animatingBoundsChange = NO;
}
-(BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds { return YES; }

@end
