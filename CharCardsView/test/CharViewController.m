//
//  CharViewController.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharViewController.h"
#import "CharCardsView.h"
#import "CharCardsCollectionView.h"
#import "CharCustomCardView.h"
#import "UIColor+Random.h"
#import "CharCustomCardCollectionView.h"
#import "CharCardCollectionView.h"
#import <MapKit/MapKit.h>

@interface CharViewController ()
@property (strong, nonatomic) CharCardsCollectionView *cardsView;
@property (strong, nonatomic) UIButton *noneStateButton;
@property (strong, nonatomic) UIButton *minStateButton;
@property (strong, nonatomic) UIButton *maxStateButton;
@property (strong, nonatomic) UIButton *autoStateButton;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSTimer *autoTimer;
@end

@implementation CharViewController

CGFloat const MIN_HEIGHT = 110.f;
CGFloat const MAX_TOP_INSET = 100.f;
NSString *const COLLECTION_VIEW_CELL = @"COLLECTION_VIEW_CELL";
NSString *const CARD_VIEW_ID = @"CARD_VIEW_ID";

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.mapView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.mapView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.mapView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.mapView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                
                                [NSLayoutConstraint constraintWithItem:self.noneStateButton
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.noneStateButton
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.minStateButton
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.minStateButton
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.noneStateButton
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.minStateButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.noneStateButton
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.maxStateButton
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.maxStateButton
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.minStateButton
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.maxStateButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.minStateButton
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.autoStateButton
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.autoStateButton
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.maxStateButton
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.autoStateButton
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.autoStateButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.maxStateButton
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.f
                                                              constant:0.f],
                                
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:20.f],
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.noneStateButton
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.cardsView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.f
                                                              constant:0.f]
                                ]];
}

-(MKMapView *) mapView {
    if(_mapView) return _mapView;
    _mapView = [[MKMapView alloc] init];
    _mapView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_mapView];
    _mapView.translatesAutoresizingMaskIntoConstraints = NO;
    return _mapView;
}

-(UIButton *) noneStateButton {
    if(_noneStateButton) return _noneStateButton;
    _noneStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _noneStateButton.backgroundColor = [UIColor whiteColor];
    [_noneStateButton setContentEdgeInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
    [_noneStateButton setTitle:@"NONE" forState:UIControlStateNormal];
    [_noneStateButton setTitleColor:[UIColor colorWithWhite:.2 alpha:1.f] forState:UIControlStateNormal];
    [_noneStateButton addTarget:self action:@selector(noneStateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_noneStateButton];
    _noneStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    return _noneStateButton;
}
-(void) noneStateButtonClicked:(id) sender {
    [self.cardsView setState:CharCardsViewStateNone animation:nil completion:nil];
}

-(UIButton *) minStateButton {
    if(_minStateButton) return _minStateButton;
    _minStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_minStateButton setTitle:@"MIN" forState:UIControlStateNormal];
    [_minStateButton setContentEdgeInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
    [_minStateButton addTarget:self action:@selector(minStateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _minStateButton.backgroundColor = [UIColor randomColor];
    [self.view addSubview:_minStateButton];
    _minStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    return _minStateButton;
}
-(void) minStateButtonClicked:(id) sender {
    CharCustomCardView *card = [[CharCustomCardView alloc] initWithMinHeight:MIN_HEIGHT];
    card.maxTopInset = MAX_TOP_INSET;
    UIColor *randColor = [UIColor randomColor];
    card.contentView.backgroundColor = randColor;
    card.shadow.backgroundColor = randColor.CGColor;
    [self.cardsView push:@"" withIdentifier:CARD_VIEW_ID animation:nil completion:nil];
}

-(UIButton *) maxStateButton {
    if(_maxStateButton) return _maxStateButton;
    _maxStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_maxStateButton setTitle:@"MAX" forState:UIControlStateNormal];
    [_maxStateButton setContentEdgeInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
    [_maxStateButton addTarget:self action:@selector(maxStateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _maxStateButton.backgroundColor = [UIColor randomColor];
    [self.view addSubview:_maxStateButton];
    _maxStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    return _maxStateButton;
}
-(void) maxStateButtonClicked:(id) sender {
    CharCustomCardView *card = [[CharCustomCardView alloc] initWithMinHeight:MIN_HEIGHT];
    card.maxTopInset = MAX_TOP_INSET;
    UIColor *randColor = [UIColor randomColor];
    card.contentView.backgroundColor = randColor;
    card.shadow.backgroundColor = randColor.CGColor;
    [self.cardsView push:@"" withIdentifier:CARD_VIEW_ID animation:nil completion:nil];
//    [self.cardsView push:@"" withIdentifier:CARD_VIEW_ID state:CharCardsViewStateMax];
//    [self.cardsView appendWithIdentifier:CARD_VIEW_ID data:[UIColor randomColor] atState:CharCardsViewStateMax animated:YES];
}

-(UIButton *) autoStateButton {
    if(_autoStateButton) return _autoStateButton;
    _autoStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_autoStateButton setTitle:@"auto" forState:UIControlStateNormal];
    [_autoStateButton setTitle:@"AUTO" forState:UIControlStateSelected];
    [_autoStateButton setContentEdgeInsets:UIEdgeInsetsMake(20, 0, 20, 0)];
    [_autoStateButton addTarget:self action:@selector(autoStateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _autoStateButton.backgroundColor = [UIColor randomColor];
    [self.view addSubview:_autoStateButton];
    _autoStateButton.translatesAutoresizingMaskIntoConstraints = NO;
    return _autoStateButton;
}
-(void) autoStateButtonClicked:(UIButton *) sender {
    sender.selected = !sender.selected;
    if(sender.selected) {
        self.autoTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(autoChange:) userInfo:nil repeats:YES];
    } else {
        [self.autoTimer invalidate];
    }
}

-(void) autoChange: (NSTimer *) sender {
    if(sender.isValid) {
        CharCustomCardView *card = [[CharCustomCardView alloc] initWithMinHeight:MIN_HEIGHT];
        card.maxTopInset = MAX_TOP_INSET;
        UIColor *randColor = [UIColor randomColor];
        card.contentView.backgroundColor = randColor;
        card.shadow.backgroundColor = randColor.CGColor;
//        [self.cardsView appendCard:card animated:YES];
    }
}

-(CharCardsCollectionView *) cardsView {
    if(_cardsView) return _cardsView;
    _cardsView = [[CharCardsCollectionView alloc] init];
    [_cardsView registerClass:[CharCustomCardCollectionView class] forCardWithReuseIdentifier:CARD_VIEW_ID];
    _cardsView.minHeight = MIN_HEIGHT;
    _cardsView.topInset = MAX_TOP_INSET;
    _cardsView.backgroundColor = [UIColor clearColor];
    _cardsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_cardsView];
    return _cardsView;
}

@end
