//
//  CharCardsMaxViewLayout.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardsMaxViewLayout.h"
#import "CharCardsLayoutAttributes.h"

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

+(Class) layoutAttributesClass { return [CharCardsLayoutAttributes class]; }

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

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

-(UICollectionViewLayoutAttributes *) initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    if(self.animatingBoundsChange) return nil;
    
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath: itemIndexPath];
    if (![self.insertIndexPaths containsObject:itemIndexPath]) return attributes;
    
    CGFloat height = self.collectionView.bounds.size.height - self.topInset;
    CGFloat attrCenterX = self.collectionView.center.x;
    CGFloat attrCenterY = self.collectionView.bounds.size.height + height/2;
    if(self.numberOfItems > 1) {
        attrCenterX = self.collectionView.bounds.size.width + self.collectionView.center.x;
        attrCenterY = self.collectionView.bounds.size.height - height/2;
    }
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, height);
    attributes.center = CGPointMake(attrCenterX, attrCenterY);
    
    if(self.transitionType == CharCardsTransitionSlideFromRight) {
        attributes.center = CGPointMake(attrCenterX, attrCenterY);
    } else if(self.transitionType == CharCardsTransitionSlideOverFromRight) {
        attributes.center = CGPointMake(self.collectionView.bounds.size.width + self.collectionView.center.x, self.collectionView.bounds.size.height - height/2);
    }
    
    return attributes;
}

-(UICollectionViewLayoutAttributes *) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    if (self.animatingBoundsChange) return [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath: itemIndexPath];
    if (![self.deleteIndexPaths containsObject:itemIndexPath]) return attributes;
    
    CGFloat height = self.collectionView.bounds.size.height - self.topInset;
    CGFloat attrCenterX = self.collectionView.center.x;
    CGFloat attrCenterY = self.collectionView.bounds.size.height + height;
    if(self.numberOfItems > 0) {
        attrCenterX = self.collectionView.bounds.size.width + self.collectionView.center.x;
        attrCenterY = self.collectionView.bounds.size.height - height;
    }
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, height);
    
    if(self.transitionType == CharCardsTransitionSlideFromRight) {
        attributes.center = CGPointMake(attrCenterX, attrCenterY);
    } else if(self.transitionType == CharCardsTransitionSlideOverFromRight) {
        attributes.center = CGPointMake(self.collectionView.bounds.size.width + self.collectionView.center.x, self.collectionView.bounds.size.height - height/2);
    }
    
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
    CGFloat attrCenterY = self.collectionView.center.y;
    if(indexPath.row == self.numberOfItems-1) attrCenterX = self.collectionView.center.x;
    
    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height - self.topInset);
    attributes.center = CGPointMake(attrCenterX, attrCenterY + self.topInset/2);
    
    if(self.transitionType == CharCardsTransitionSlideFromRight) {
        attributes.center = CGPointMake(attrCenterX, attrCenterY + self.topInset/2);
    } else if(self.transitionType == CharCardsTransitionSlideOverFromRight) {
        attributes.center = CGPointMake(self.collectionView.center.x, attrCenterY + self.topInset/2);
    }
    
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
