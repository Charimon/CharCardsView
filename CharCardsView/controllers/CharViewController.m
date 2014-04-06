//
//  CharViewController.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharViewController.h"
#import "CharCardsView.h"

@interface CharViewController ()
@property (strong, nonatomic) CharCardsView *cardsView;
@property (strong, nonatomic) UIButton *button;
@end

@implementation CharViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.button
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0.f]
                                ]];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:8.f],
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:-8.f],
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:8.f],
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:-8.f]
                                ]];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(UIButton *) button {
    if(_button) return _button;
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.backgroundColor = [UIColor lightGrayColor];
    [_button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    return _button;
}
-(void) buttonClicked {
    CharCardView *card = [[CharCardView alloc] init];
    
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    card.backgroundColor = randColor;
    [self.cardsView appendCard:card atState:CharCardsViewStateMax animated:YES];
}

-(CharCardsView *) cardsView {
    if(_cardsView) return _cardsView;
    _cardsView = [[CharCardsView alloc] init];
    _cardsView.maxTopInset = 100.f;
    _cardsView.minHeight = 110.f;
    _cardsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_cardsView];
    return _cardsView;
}

@end
