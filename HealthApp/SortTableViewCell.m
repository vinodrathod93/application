//
//  SortTableViewCell.m
//  Neediator
//
//  Created by Vinod Rathod on 20/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "SortTableViewCell.h"

@implementation SortTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.ascending.hidden   =   YES;
    self.descending.hidden  =   YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
