//
//  StoreTaxonHeaderViewCell.m
//  Neediator
//
//  Created by adverto on 11/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "StoreTaxonHeaderViewCell.h"

@implementation StoreTaxonHeaderViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.uploadPrescriptionButton.layer.cornerRadius    = 5.f;
    self.quickOrderButton.layer.cornerRadius            = 5.f;
    
    self.backgroundColor = [UIColor clearColor];
//    self.buttonsContainerView.backgroundColor = [UIColor clearColor];
    
    
    self.uploadPrescriptionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.uploadPrescriptionButton.titleLabel.numberOfLines = 2;
    self.uploadPrescriptionButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.uploadPrescriptionButton.layer.shadowOpacity = 0.5;
    self.uploadPrescriptionButton.layer.shadowRadius = 3;
    self.uploadPrescriptionButton.layer.shadowOffset = CGSizeMake(-3.f, 3.f);
    
    
    self.quickOrderButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.quickOrderButton.layer.shadowOpacity = 0.5;
    self.quickOrderButton.layer.shadowRadius = 1.5;
    self.quickOrderButton.layer.shadowOffset = CGSizeMake(3.f, 3.f);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    
}

@end
