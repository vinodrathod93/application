//
//  BannerTableViewCell.m
//  Neediator
//
//  Created by adverto on 17/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "BannerTableViewCell.h"

@implementation BannerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.carousel.vertical = YES;
    self.carousel.type = iCarouselTypeInvertedCylinder;
    self.carousel.pagingEnabled = YES;
    self.pageControl.transform  = CGAffineTransformMakeRotation(M_PI / 2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
