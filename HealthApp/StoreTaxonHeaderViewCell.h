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
@property (weak, nonatomic) IBOutlet UIScrollView *offersScrollView;

@property (weak, nonatomic) IBOutlet UIView *offersContentView;
@property (weak, nonatomic) IBOutlet UILabel *offersLabel;




@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollviewbottom;
@property (weak, nonatomic) IBOutlet UIScrollView *nooffersLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offersViewBottom;

@end
