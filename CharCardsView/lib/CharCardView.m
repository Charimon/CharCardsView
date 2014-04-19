//
//  CharCardView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCardView.h"
#import "CharCardsView.h"

@interface CharCardView()
@property (nonatomic, readwrite) CharCardsViewState state;
@property (strong, nonatomic) NSLayoutConstraint *insetViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *insetViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *contentViewBottomConstraint;
@property (nonatomic) CGFloat shadowTopOffset;
@end

@implementation CharCardView

CGFloat const GRADIENT_SIZE = 6.f;

-(instancetype) init {
    self = [super init];
    if(self) {
        self.shadow = [CAGradientLayer layer];
        self.shadow.colors = @[ (id)[UIColor colorWithWhite:79.f/255.f alpha:0].CGColor, (id)[UIColor colorWithWhite:79.f/255.f alpha:.22f].CGColor, (id)[UIColor colorWithWhite:79.f/255.f alpha:.6f].CGColor ];
        self.shadow.locations = @[ [NSNumber numberWithFloat:0], [NSNumber numberWithFloat:.8f], [NSNumber numberWithFloat:1.f] ];
        [self.layer addSublayer:self.shadow];
        self.shadowTopOffset = -GRADIENT_SIZE;
        
        [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.f
                                                             constant:0.f],
                               [NSLayoutConstraint constraintWithItem:self.contentView
                                                            attribute:NSLayoutAttributeTrailing
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTrailing
                                                           multiplier:1.f
                                                             constant:0.f],
                               ]];
        
        self.contentViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.f
                                                                         constant:0.f];
        [self addConstraint:self.contentViewBottomConstraint];

    }
    return self;
}

-(void) didMoveToSuperview {
    [super didMoveToSuperview];
    if([self.superview isKindOfClass:[CharCardsView class]]) {
        self.cardsView = (CharCardsView *) self.superview;
        
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
        [self.shadow removeFromSuperlayer];
        self.shadow = nil;
    }
}

-(void) setMaxTopInset:(CGFloat)maxTopInset animated:(BOOL) animated {
    _maxTopInset = maxTopInset;
    if(animated) [self.cardsView setState:self.state animated:YES];
}

-(void) setInsetView:(UIView *)insetView {
    if(_insetView) {
        [_insetView removeFromSuperview];
        self.insetViewHeightConstraint = nil;
        self.insetViewTopConstraint = nil;
    }
    
    if(!insetView) return;
    
    _insetView = insetView;
    _insetView.clipsToBounds = YES;
    [self addSubview:_insetView];
    [self sendSubviewToBack:_insetView];
    _insetView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.insetView
                                                        attribute:NSLayoutAttributeLeading
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeLeading
                                                       multiplier:1.f
                                                         constant:0.f],
                           [NSLayoutConstraint constraintWithItem:self.insetView
                                                        attribute:NSLayoutAttributeTrailing
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeTrailing
                                                       multiplier:1.f
                                                         constant:0.f],
                           ]];
    self.insetViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.insetView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.f
                                                                constant:0.f];
    self.insetViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.insetView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0.f
                                                                   constant:0.f];
    if(self.state == CharCardsViewStateMax) {
        self.insetViewTopConstraint.constant = -self.maxTopInset;
        self.insetViewHeightConstraint.constant = self.maxTopInset;
    } else if (self.state == CharCardsViewStateMin) {
        self.insetViewTopConstraint.constant = 0;
        self.insetViewHeightConstraint.constant = self.cardsView.minHeight;
    }
    [self addConstraint:self.insetViewTopConstraint];
    [self addConstraint:self.insetViewHeightConstraint];
}

-(UIScrollView *) contentView {
    if(_contentView) return _contentView;
    _contentView = [[UIScrollView alloc] init];
    [self addSubview:_contentView];

    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    return _contentView;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    self.shadow.frame = CGRectMake(0, self.shadowTopOffset, self.bounds.size.width, GRADIENT_SIZE);
}

-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    if(newState == CharCardsViewStateMax) {
        self.insetViewTopConstraint.constant = -self.maxTopInset;
        self.insetViewHeightConstraint.constant = self.maxTopInset;
        self.shadowTopOffset = self.insetView?0.f:-GRADIENT_SIZE;
    } else if (newState == CharCardsViewStateMin) {
        self.insetViewTopConstraint.constant = 0;
        self.insetViewHeightConstraint.constant = self.cardsView.minHeight;
        self.shadowTopOffset = -GRADIENT_SIZE;
    }
}
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    self.state = newState;
}
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height {
    self.insetViewTopConstraint.constant = -self.maxTopInset * (position/height);
    self.insetViewHeightConstraint.constant = self.cardsView.minHeight + (self.maxTopInset - self.cardsView.minHeight)* (position/height);
}

-(void) insetViewTapped {}

#pragma mark NSNotificationCenter keybaord
-(void) keyboardWillShow: (NSNotification *) notification {
    CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrameEnd = [self.contentView convertRect:keyboardFrameEnd fromView:nil];
    
    CGFloat bottomInset = self.contentView.frame.size.height - keyboardFrameEnd.origin.y;
    self.contentView.contentInset = UIEdgeInsetsMake(0, 0, bottomInset, 0);
    self.contentView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottomInset, 0);
}
-(void) keyboardDidShow: (NSNotification *) notification {}
-(void) keyboardWillHide: (NSNotification *) notification {
    self.contentView.contentInset = UIEdgeInsetsZero;
    self.contentView.scrollIndicatorInsets = UIEdgeInsetsZero;
}
-(void) keyboardDidHide: (NSNotification *) notification {}
-(void) keyboardWillChangeFrame: (NSNotification *) notification {}
-(void) keyboardDidChangeFrame: (NSNotification *) notification {}

@end
