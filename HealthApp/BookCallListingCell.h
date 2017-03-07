//
//  BookCallListingCell.h
//  Neediator
//
//  Created by adverto on 22/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface BookCallListingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet RatingView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *distance;
@property (weak, nonatomic) IBOutlet UILabel *timing;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageview;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIView *corneredView;




@property (weak, nonatomic) IBOutlet UILabel *DoctorLikes;
@property (weak, nonatomic) IBOutlet UILabel *DoctorArea;
@property (weak, nonatomic) IBOutlet UILabel *MinimumFees;




@property (weak, nonatomic) IBOutlet UILabel *Sunday_lbl;
@property (weak, nonatomic) IBOutlet UILabel *Monday_lbl;
@property (weak, nonatomic) IBOutlet UILabel *Tuesday_lbl;
@property (weak, nonatomic) IBOutlet UILabel *Wednesday_lbl;
@property (weak, nonatomic) IBOutlet UILabel *Thrusday_lbl;
@property (weak, nonatomic) IBOutlet UILabel *Friday_lbl;
@property (weak, nonatomic) IBOutlet UILabel *Saturday_lbl;




@end
