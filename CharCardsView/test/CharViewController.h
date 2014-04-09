//
//  CharViewController.h
//  CharCardsView
//
//  Created by Andrew Charkin on 4/6/14.
//  Copyright (c) 2014 Charimon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharViewController : UIViewController
@end

@interface CharUICollectionViewCell: UICollectionViewCell
@property (strong, nonatomic) UILabel *label;
@end

@interface Tuple: NSObject
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *color;
-(instancetype) initWithText: (NSString *) text color: (UIColor *) color;
@end