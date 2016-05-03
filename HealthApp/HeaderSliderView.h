//
//  HeaderSliderView.h
//  Chemist Plus
//
//  Created by adverto on 14/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface HeaderSliderView : UICollectionReusableView

@property (nonatomic, weak) IBOutlet iCarousel *carousel;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *askDoctorButton;
@property (weak, nonatomic) IBOutlet UIButton *askPharmacistButton;

@end
