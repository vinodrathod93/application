//
//  MyBookingCell.m
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "MyBookingCell.h"

@implementation MyBookingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    self.cancelOrderButton.layer.cornerRadius   = 5.f;
    self.cancelOrderButton.layer.masksToBounds  = YES;

    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
