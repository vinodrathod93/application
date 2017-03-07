//
//  ImageModalViewController.h
//  Neediator
//
//  Created by adverto on 19/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingModel.h"

@interface ImageModalViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;

@property (strong, nonatomic) ListingModel *model;
@property (strong, nonatomic) UIImage *image;

@end
