//
//  DoctorViewCell.h
//  Chemist Plus
//
//  Created by adverto on 31/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoctorViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *doctorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *clinicName;
@property (weak, nonatomic) IBOutlet UILabel *clinicLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *consultationFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distance;

@end
