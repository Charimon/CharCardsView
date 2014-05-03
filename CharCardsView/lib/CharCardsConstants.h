//
//  CharCardsConstants.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CharCardsViewState) {
    CharCardsViewStateCurrent = -1,
    CharCardsViewStateNone = 0,
    CharCardsViewStateMin = 1,
    CharCardsViewStateMax = 2
};

typedef NS_ENUM(NSUInteger, CharCardsTransitionType) {
    CharCardsTransitionSlideFromRight,
    CharCardsTransitionSlidOverFromRight
};