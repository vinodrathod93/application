//
//  StoreTaxonHeaderViewCell.h
//  Neediator
//
//  Created by adverto on 11/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface StoreTaxonHeaderViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *uploadPrescriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *quickOrderButton;


@property (weak, nonatomic) IBOutlet RatingView *ratingView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;

@property (weak, nonatomic) IBOutlet UIView *offersView;
@property (weak, nonatomic) IBOutlet UIImageView *offersImageView;

@property (weak, nonatomic) IBOutlet UIView *optionsView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@end
