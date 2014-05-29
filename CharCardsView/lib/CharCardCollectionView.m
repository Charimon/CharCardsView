//
//  CharCard2CollectionView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/22/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardCollectionView.h"
#import "CharCardsCollectionView.h"

#import "CharCardsMaxViewLayout.h"
#import "CharCardsMinViewLayout.h"

@interface CharCardCollectionView()<UIScrollViewDelegate>
@end

@implementation CharCardCollectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView.frame = frame;
        self.shadowHeight = 6.f;
    }
    return self;
}

-(UIScrollView *) scrollView {
    if(_scrollView) return _scrollView;
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.delaysContentTouches = YES;
    _scrollView.delegate = self;
    _scrollView.scrollEnabled = NO;
    [self.contentView addSubview:_scrollView];
    return _scrollView;
}

-(void) setInsetView:(UIView *)insetView {
    _insetView = insetView;
    [self addSubview:insetView];
    [self bringSubviewToFront:self.contentView];
}

-(CAGradientLayer *) shadow {
    if(_shadow) return _shadow;
    _shadow = [CAGradientLayer layer];
    _shadow.colors = @[ (id)[UIColor colorWithWhite:79.f/255.f alpha:0].CGColor, (id)[UIColor colorWithWhite:79.f/255.f alpha:.22f].CGColor, (id)[UIColor colorWithWhite:79.f/255.f alpha:.6f].CGColor ];
    _shadow.locations = @[ [NSNumber numberWithFloat:0], [NSNumber numberWithFloat:.8f], [NSNumber numberWithFloat:1.f] ];
    [self.layer addSublayer:_shadow];
    return _shadow;
}

-(CGFloat) maxHeight {
    return self.superview.bounds.size.height - self.cardsView.topInset;
}

-(void) layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if(layer == self.layer) {
        self.shadow.bounds = CGRectMake(0, 0, layer.bounds.size.width, self.shadowHeight);
        self.shadow.position = CGPointMake(0, -self.shadowHeight);
        self.shadow.anchorPoint = CGPointMake(0, 0);
    }
}

-(CharCardsCollectionView *) cardsView {
    if([self.superview.superview isKindOfClass:[CharCardsCollectionView class]]) {
        return (CharCardsCollectionView *)self.superview.superview;
    } else {
        return nil;
    }
}


-(void) didMoveToSuperview {
    [super didMoveToSuperview];
    if([self.superview isKindOfClass:[UICollectionView class]]) {
        self.cardsView = (CharCardsCollectionView *) self.superview;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    } else {
        self.cardsView = nil;
        [self resignFirstResponder];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


-(void) applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    self.scrollView.frame = CGRectMake(0, 0, layoutAttributes.size.width, layoutAttributes.size.height);
    
    CGFloat percentChange = 0;
    
    if((self.maxHeight > 0 || self.cardsView.minHeight > 0) && (self.cardsView.minHeight != self.maxHeight)) {
        percentChange = (layoutAttributes.size.height - self.cardsView.minHeight)/(self.maxHeight - self.cardsView.minHeight);
    }
    CGFloat insetHeight = self.superview.frame.size.height - self.maxHeight;
    if(self.maxHeight == 0) insetHeight = 0;
    
    if(insetHeight < 0) insetHeight = 0;
    self.insetView.frame = CGRectMake(0, -insetHeight*percentChange, layoutAttributes.size.width, insetHeight);
}

- (void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout {
    [super willTransitionFromLayout:oldLayout toLayout:newLayout];
    
    CharCardsMaxViewLayout *maxLayout;
    CharCardsMinViewLayout *minLayout;
    if([newLayout isKindOfClass:[CharCardsMaxViewLayout class]]) maxLayout = (id) newLayout;
    else if([newLayout isKindOfClass:[CharCardsMinViewLayout class]]) minLayout = (id) newLayout;
    else if([newLayout isKindOfClass:[UICollectionViewTransitionLayout class]]) {
        UICollectionViewTransitionLayout *transitional = (id) newLayout;
        if([transitional.nextLayout isKindOfClass:[CharCardsMaxViewLayout class]]) maxLayout = (id)transitional.nextLayout;
        else if([transitional.currentLayout isKindOfClass:[CharCardsMaxViewLayout class]]) maxLayout = (id)transitional.currentLayout;
        
        if([transitional.nextLayout isKindOfClass:[CharCardsMinViewLayout class]]) minLayout = (id)transitional.nextLayout;
        else if([transitional.currentLayout isKindOfClass:[CharCardsMinViewLayout class]]) minLayout = (id)transitional.currentLayout;
    }
}

-(void) didTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout {
    if([newLayout isKindOfClass:[CharCardsMaxViewLayout class]] && self.insetView) {
        self.shadow.opacity = 0.f;
    } else {
        self.shadow.opacity = 1.f;
    }
}

-(void) updateWithData:(id) data layout:(UICollectionViewLayout *) layout {
    CharCardsMaxViewLayout *maxLayout;
    CharCardsMinViewLayout *minLayout;
    if([layout isKindOfClass:[CharCardsMaxViewLayout class]]) maxLayout = (id) layout;
    else if([layout isKindOfClass:[CharCardsMinViewLayout class]]) minLayout = (id) layout;
    else if([layout isKindOfClass:[UICollectionViewTransitionLayout class]]) {
        UICollectionViewTransitionLayout *transitional = (id) layout;
        if([transitional.nextLayout isKindOfClass:[CharCardsMaxViewLayout class]]) maxLayout = (id)transitional.nextLayout;
        else if([transitional.currentLayout isKindOfClass:[CharCardsMaxViewLayout class]]) maxLayout = (id)transitional.currentLayout;
        
        if([transitional.nextLayout isKindOfClass:[CharCardsMinViewLayout class]]) minLayout = (id)transitional.nextLayout;
        else if([transitional.currentLayout isKindOfClass:[CharCardsMinViewLayout class]]) minLayout = (id)transitional.currentLayout;
    }
}


#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y <= 0) scrollView.contentOffset = CGPointMake(0, 0);
}

#pragma mark NSNotificationCenter keybaord
-(void) keyboardWillShow: (NSNotification *) notification {
    CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.contentView convertRect:keyboardFrameEnd fromView:nil];
    
    CGFloat bottomInset = self.contentView.frame.size.height - keyboardFrameEnd.origin.y;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}
-(void) keyboardDidShow: (NSNotification *) notification {}
-(void) keyboardWillHide: (NSNotification *) notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}
-(void) keyboardDidHide: (NSNotification *) notification {}
-(void) keyboardWillChangeFrame: (NSNotification *) notification {}
-(void) keyboardDidChangeFrame: (NSNotification *) notification {}

@end
