//
//  StoresViewCell.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoresViewCell.h"

@implementation StoresViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.storeImageView.layer.cornerRadius = self.storeImageView.frame.size.width / 2.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
