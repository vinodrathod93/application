//
//  TaxonHeaderView.m
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "TaxonHeaderView.h"

@implementation TaxonHeaderView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
    self.uploadPrescriptionButton.layer.cornerRadius    = 5.f;
    self.quickOrderButton.layer.cornerRadius            = 5.f;
    
    self.backgroundColor = [UIColor clearColor];
    self.buttonsContainerView.backgroundColor = [UIColor clearColor];
    
    
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

@end
