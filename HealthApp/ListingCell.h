//
//  ListingCell.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface ListingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *roundedContentView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageview;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *street;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet RatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *timing;
@property (weak, nonatomic) IBOutlet UILabel *minOrderLabel;

@property (weak, nonatomic) IBOutlet UIButton *offersButton;

@end
