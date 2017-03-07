//
//  TaxonHeaderView.h
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface TaxonHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *blurBackgroundView;


@property (weak, nonatomic) IBOutlet UIView *offersView;




@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *uploadPrescriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *quickOrderButton;



@end
