//
//  CharViewController.m
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import "CharViewController.h"
#import "CharCardsView.h"
#import "CharCustomCardView.h"

@interface CharViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) CharCardsView *cardsView;
@property (strong, nonatomic) UICollectionView *buttonsView;
@property (strong, nonatomic) NSMutableArray *buttonColors;
@end

@implementation CharViewController

CGFloat const MIN_HEIGHT = 110.f;
CGFloat const MAX_TOP_INSET = 100.f;
NSString *const COLLECTION_VIEW_CELL = @"COLLECTION_VIEW_CELL";

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.buttonsView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.buttonsView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.buttonsView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0.f],
                                [NSLayoutConstraint constraintWithItem:self.buttonsView
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
    
    self.buttonColors = [[NSMutableArray alloc] init];
    int i = 15;
    while(i-- > 0) {
        NSInteger aRedValue = arc4random()%255;
        NSInteger aGreenValue = arc4random()%255;
        NSInteger aBlueValue = arc4random()%255;
        UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
        
        NSString *title = [@[@"MIN", @"MAX", @"NONE"] objectAtIndex:arc4random()%3];
        [self.buttonColors addObject:[[Tuple alloc] initWithText:title color:randColor]];
    }
    
}

-(UICollectionView *) buttonsView {
    if(_buttonsView) return _buttonsView;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    _buttonsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    _buttonsView.backgroundColor = [UIColor clearColor];
    _buttonsView.dataSource = self;
    _buttonsView.delegate = self;
    [_buttonsView registerClass:[CharUICollectionViewCell class] forCellWithReuseIdentifier:COLLECTION_VIEW_CELL];
    
    [self.view addSubview:_buttonsView];
    _buttonsView.translatesAutoresizingMaskIntoConstraints = NO;
    return _buttonsView;
}

-(void) buttonClicked {
    CharCustomCardView *card = [[CharCustomCardView alloc] initWithMinHeight:MIN_HEIGHT];
    card.maxTopInset = MAX_TOP_INSET;
    
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    card.contentView.backgroundColor = randColor;
    [self.cardsView appendCard:card atState:CharCardsViewStateMin animated:YES];
}

-(CharCardsView *) cardsView {
    if(_cardsView) return _cardsView;
    _cardsView = [[CharCardsView alloc] init];
    _cardsView.minHeight = MIN_HEIGHT;
    _cardsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_cardsView];
    return _cardsView;
}

#pragma mark UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView { return 1; }
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return self.buttonColors.count;}
- (CharUICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CharUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VIEW_CELL forIndexPath:indexPath];
    Tuple *t = [self.buttonColors objectAtIndex:indexPath.row];
    cell.contentView.backgroundColor = t.color;
    cell.label.text = t.text;
    
    return cell;
}

#pragma mark UICollectionViewDelegate
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section { return 0.f; }
- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section { return 0; }
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(((int)collectionView.bounds.size.width/3), ((int)collectionView.bounds.size.width/3));
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    CharCustomCardView *card = [[CharCustomCardView alloc] initWithMinHeight:MIN_HEIGHT];
    card.contentView.backgroundColor = [[self.buttonColors objectAtIndex:indexPath.row] color];
    NSString *title = [[self.buttonColors objectAtIndex:indexPath.row] text];
    if([title isEqualToString:@"MIN"]) [self.cardsView appendCard:card atState:CharCardsViewStateMin animated:YES];
    else if([title isEqualToString:@"MAX"]) [self.cardsView appendCard:card atState:CharCardsViewStateMax animated:YES];
    else if([title isEqualToString:@"NONE"]) [self.cardsView setState:CharCardsViewStateNone animated:YES];

}

@end

@implementation CharUICollectionViewCell: UICollectionViewCell
-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self.contentView addConstraints:@[[NSLayoutConstraint constraintWithItem:self.label
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.f
                                                                  constant:0.f],
                                    [NSLayoutConstraint constraintWithItem:self.label
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.f
                                                                  constant:0.f],
                                    [NSLayoutConstraint constraintWithItem:self.label
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.f
                                                                  constant:0.f],
                                    [NSLayoutConstraint constraintWithItem:self.label
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.f
                                                                  constant:0.f]
                                    ]];

    }
    return self;
}

-(UILabel *) label {
    if(_label) return _label;
    _label = [[UILabel alloc] init];
    _label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _label.textColor = [UIColor colorWithWhite:.1 alpha:1.f];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_label];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    return _label;
}

@end

@implementation Tuple
-(instancetype) initWithText: (NSString *) text color: (UIColor *) color {
    self = [super init];
    if(self) {
        self.text = text;
        self.color = color;
    }
    return self;
}
@end