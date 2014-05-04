//
//  CharCard2CollectionView.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CharCardsCollectionView;

@interface CharCardCollectionView : UICollectionViewCell
-(void) updateWithData:(id) data layout:(UICollectionViewLayout *) layout;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) CAGradientLayer *shadow;
@property (strong, nonatomic) UIView *insetView;
@property (weak, nonatomic) CharCardsCollectionView* cardsView;

//default shadowHeight = 6.f
@property (nonatomic) CGFloat shadowHeight;
@property (nonatomic) CGFloat maxHeight;

-(void) keyboardWillShow: (NSNotification *) notification;
-(void) keyboardDidShow: (NSNotification *) notification;
-(void) keyboardWillHide: (NSNotification *) notification;
-(void) keyboardDidHide: (NSNotification *) notification;
-(void) keyboardWillChangeFrame: (NSNotification *) notification;
-(void) keyboardDidChangeFrame: (NSNotification *) notification;

@end
