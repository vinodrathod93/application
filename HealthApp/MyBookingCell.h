//
//  MyBookingCell.h
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBookingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ReferenceNo;
@property (weak, nonatomic) IBOutlet UILabel *DoctorName;
@property (weak, nonatomic) IBOutlet UILabel *DoctorArea;
@property (weak, nonatomic) IBOutlet UILabel *AppointmentLbl;
@property (weak, nonatomic) IBOutlet UILabel *DateLbl;
@property (weak, nonatomic) IBOutlet UILabel *TimeLbl;
@property (weak, nonatomic) IBOutlet UIButton *ShowInfo;
@property (weak, nonatomic) IBOutlet UILabel *Statuslabel;

@property (weak, nonatomic) IBOutlet UIView *beforeCompleteOptionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelOrderButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BeforeViewConstraintOutlet;




@property (weak, nonatomic) IBOutlet UILabel *stlabel;


@end
