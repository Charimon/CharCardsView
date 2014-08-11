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
@property (nonatomic) CGFloat originalHeight;
@end

#define CHAR_EPSILON (.25f)

@implementation CharCardsNoneViewLayout

-(void) prepareLayout {
    [super prepareLayout];
    self.numberOfItems = [self.collectionView numberOfItemsInSection:0];
    self.height = self.collectionView.frame.size.height;
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

+ (Class)layoutAttributesClass {
    return [CharCollectionViewNoneLayoutAttributes class];
}

-(CGSize)collectionViewContentSize { return self.collectionView.bounds.size;}

-(NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray array];
    for(NSUInteger i=0; i<self.numberOfItems; i++) {
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
    }
    return attributes;
}

-(CharCollectionViewNoneLayoutAttributes *) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    CharCollectionViewNoneLayoutAttributes *attributes = [CharCollectionViewNoneLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    attributes.alpha = 1.f;
    attributes.size = CGSizeMake(self.collectionView.frame.size.width, self.height);
    attributes.originalSize = CGSizeMake(self.collectionView.frame.size.width, self.originalHeight);
    attributes.center = CGPointMake(self.collectionView.center.x, self.collectionView.frame.size.height + self.height/2 - CHAR_EPSILON);
    return attributes;
}

-(UICollectionViewLayoutAttributes *) finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.animatingBoundsChange) return [self layoutAttributesForItemAtIndexPath:indexPath];
    
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath: indexPath];
    if(![self.deleteIndexPaths containsObject:indexPath]) return attributes;
    
    attributes.alpha = 1.f;
    attributes.center = CGPointMake(self.collectionView.center.x, self.collectionView.frame.size.height + self.height/2 - 1);

    return attributes;
}


-(void)prepareForTransitionToLayout:(UICollectionViewLayout *)newLayout {
    if([newLayout isKindOfClass:[CharCardsMaxViewLayout class]]) {
        self.height = self.collectionView.frame.size.height - ((CharCardsMaxViewLayout *)newLayout).topInset;
        self.originalHeight = self.height;
    } else if([newLayout isKindOfClass:[CharCardsMinViewLayout class]]) {
        self.height = ((CharCardsMinViewLayout *)newLayout).minHeight;
        self.originalHeight = self.height;
    } else {
        self.originalHeight = self.height;
        self.height = self.collectionView.frame.size.height;
    }
}

-(void)prepareForTransitionFromLayout:(UICollectionViewLayout *)oldLayout {
    if([oldLayout isKindOfClass:[CharCardsMaxViewLayout class]]) {
        self.height = self.collectionView.frame.size.height - ((CharCardsMaxViewLayout *)oldLayout).topInset;
        self.originalHeight = self.height;
    } else if([oldLayout isKindOfClass:[CharCardsMinViewLayout class]]) {
        self.height = ((CharCardsMinViewLayout *)oldLayout).minHeight;
        self.originalHeight = self.height;
    } else {
        self.originalHeight = self.height;
        self.height = self.collectionView.frame.size.height;
    }
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


@implementation CharCollectionViewNoneLayoutAttributes
- (id)copyWithZone:(NSZone *)zone {
    CharCollectionViewNoneLayoutAttributes *attributes = [super copyWithZone:zone];
    attributes.originalSize = _originalSize;
    return attributes;
}
@end