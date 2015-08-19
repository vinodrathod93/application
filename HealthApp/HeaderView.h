//
//  HeaderView.h
//  Chemist Plus
//
//  Created by adverto on 10/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView

@property (strong, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIScrollView *imagePagesView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)askPharmacistPressed:(id)sender;
- (IBAction)askDoctorPressed:(id)sender;
- (IBAction)uploadPrescriptionPressed:(id)sender;
@end
