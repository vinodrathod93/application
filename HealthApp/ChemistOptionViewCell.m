//
//  ChemistOptionViewCell.m
//  Neediator
//
//  Created by adverto on 02/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ChemistOptionViewCell.h"

@implementation ChemistOptionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    
    self.sendPrescriptionView.layer.cornerRadius = 12.f;
    self.sendPrescriptionView.layer.masksToBounds = YES;
    
    self.quickOrderView.layer.cornerRadius = 12.f;
    self.quickOrderView.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
