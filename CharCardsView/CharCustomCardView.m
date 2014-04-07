//
//  CharCustomCardView.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharCustomCardView.h"
@interface CharCustomCardView()
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *thumbnailView;
@property (strong, nonatomic) UIView *descriptionView;
@property (nonatomic) CGFloat minHeight;

@property (strong, nonatomic) NSLayoutConstraint *thumbHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *thumbWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descBottomConstraint;
@end

@implementation CharCustomCardView
CGFloat const maxThumbHeight = 200.f;

-(instancetype) init { return nil;}
-(instancetype) initWithMinHeight:(CGFloat) height {
    self = [super init];
    if(self) {
        self.minHeight = height;
        self.insetView = [[CharInsetView alloc] init];
        
        [self addConstraints:@[ [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.headerView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.thumbnailView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:8.f],
                                [NSLayoutConstraint constraintWithItem:self.headerView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.thumbnailView
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:8.f],
                                [NSLayoutConstraint constraintWithItem:self.headerView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.f
                                                              constant:-self.minHeight-16.f],
                                [NSLayoutConstraint constraintWithItem:self.headerView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.f
                                                              constant:self.minHeight-16.f],
                                [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:8.f],
                                [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:-8.f]
                               ]];
        
        self.thumbHeightConstraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:0.f
                                                                   constant:self.minHeight];
        self.thumbWidthConstraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:0.f
                                                                  constant:self.minHeight];
        
        self.descTopConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.thumbnailView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.f
                                                               constant:8.f];
        
        self.descBottomConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.f
                                                                  constant:-8.f];
        
        [self addConstraint:self.thumbHeightConstraint];
        [self addConstraint:self.thumbWidthConstraint];
        [self addConstraint:self.descTopConstraint];
        [self addConstraint:self.descBottomConstraint];
    }
    return self;
}

-(UIView *) headerView {
    if(_headerView) return _headerView;
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor darkGrayColor];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_headerView];
    return _headerView;
}

-(UIView *) thumbnailView {
    if(_thumbnailView) return _thumbnailView;
    _thumbnailView = [[UIView alloc] init];
    
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    _thumbnailView.backgroundColor = randColor;
    _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_thumbnailView];
    return _thumbnailView;
}

-(UIView *) descriptionView {
    if(_descriptionView) return _descriptionView;
    _descriptionView = [[UIView alloc] init];
    _descriptionView.backgroundColor = [UIColor darkGrayColor];
    _descriptionView.alpha = 0.f;
    _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_descriptionView];
    return _descriptionView;
}

-(void) willChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    [super willChangeState:newState fromOldState:oldState];
    
    if(newState == CharCardsViewStateMax) {
        self.thumbHeightConstraint.constant = maxThumbHeight;
        self.thumbWidthConstraint.constant = self.bounds.size.width;
        self.descriptionView.alpha = 1.f;
    } else if(newState == CharCardsViewStateMin) {
        self.thumbHeightConstraint.constant = self.minHeight;
        self.thumbWidthConstraint.constant = self.minHeight;
        self.descriptionView.alpha = 0.f;
    }
    
    [self layoutIfNeeded];
}
-(void) didChangeState:(CharCardsViewState) newState fromOldState: (CharCardsViewState) oldState {
    [super didChangeState:newState fromOldState:oldState];
}
-(void) didChangeVerticalPositionFromBottom:(CGFloat) position inHeight:(CGFloat) height {
    [super didChangeVerticalPositionFromBottom:position inHeight:height];
    
    self.descriptionView.alpha =  (position/height);
    self.headerView.alpha =  1.f - (position/height);
    self.thumbHeightConstraint.constant = self.minHeight + (maxThumbHeight - self.minHeight)*(position/height);
    self.thumbWidthConstraint.constant = self.minHeight + (self.bounds.size.width - self.minHeight)*(position/height);
}
@end


@interface CharInsetView()
@property (strong, nonatomic) UIButton *button;
@end

@implementation CharInsetView: UIView
-(instancetype) init {
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addConstraints:@[ [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0],
                                ]];

    }
    return self;
}

-(UIButton *) button {
    if(_button) return _button;
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button setTitle:@"not clickable" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_button];
    return _button;
}

-(void) buttonClicked {
    
}
@end;