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
        
        [self.contentView addConstraints:@[ [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.thumbnailView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
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
                                                                toItem:self.contentView
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
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:8.f],
                                            
                                [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.contentView
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.f
                                                              constant:-16.f],
                                [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.f
                                                              constant:300.f]
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
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.f
                                                                  constant:-8.f];
        
        [self.contentView addConstraint:self.thumbHeightConstraint];
        [self.contentView addConstraint:self.thumbWidthConstraint];
        [self.contentView addConstraint:self.descTopConstraint];
        [self.contentView addConstraint:self.descBottomConstraint];
    }
    return self;
}

-(UIView *) headerView {
    if(_headerView) return _headerView;
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor darkGrayColor];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_headerView];
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
    [self.contentView addSubview:_thumbnailView];
    return _thumbnailView;
}

-(UIView *) descriptionView {
    if(_descriptionView) return _descriptionView;
    _descriptionView = [[UIView alloc] init];
    _descriptionView.backgroundColor = [UIColor darkGrayColor];
    _descriptionView.alpha = 0.f;
    _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_descriptionView];
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

-(void) insetViewTapped {
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    self.insetView.backgroundColor = randColor;
    
}
@end


@interface CharInsetView()
@property (strong, nonatomic) UILabel *label;
@end

@implementation CharInsetView: UIView
-(instancetype) init {
    self = [super init];
    if(self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addConstraints:@[ [NSLayoutConstraint constraintWithItem:self.label
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.label
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.label
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.f
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.label
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

-(UILabel *) label {
    if(_label) return _label;
    _label = [[UILabel alloc] init];
    _label.backgroundColor = [UIColor clearColor];
    _label.textColor = [UIColor blackColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"click me";
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_label];
    return _label;
}
@end;