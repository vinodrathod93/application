//
//  BannerTableViewCell.h
//  Neediator
//
//  Created by adverto on 17/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface BannerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
