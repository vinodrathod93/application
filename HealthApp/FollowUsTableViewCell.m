//
//  FollowUsTableViewCell.m
//  Neediator
//
//  Created by Vinod Rathod on 12/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FollowUsTableViewCell.h"

@implementation FollowUsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1.0];
    [self.contentView addSubview:separatorLineView];
    
    UIView* bottomSeparatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, self.frame.size.width, 1)];
    bottomSeparatorLineView.backgroundColor  = [UIColor colorWithRed:239/255.f green:239/255.f blue:244/255.f alpha:1.0];
    [self.contentView addSubview:bottomSeparatorLineView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
