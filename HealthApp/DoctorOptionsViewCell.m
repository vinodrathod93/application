//
//  DoctorOptionsViewCell.m
//  Neediator
//
//  Created by adverto on 02/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "DoctorOptionsViewCell.h"

@implementation DoctorOptionsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.appointmentView.layer.cornerRadius = 12.f;
    self.appointmentView.layer.masksToBounds = YES;
    
    self.sendReportsView.layer.cornerRadius = 12.f;
    self.sendReportsView.layer.masksToBounds = YES;
    
    self.homeRequestView.layer.cornerRadius = 12.f;
    self.homeRequestView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
