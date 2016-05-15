//
//  GoogleReportsViewController.h
//  Neediator
//
//  Created by Vinod Rathod on 08/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLService.h"

@interface GoogleReportsViewController : UIViewController

@property (nonatomic, strong) GTLService *service;
@property (nonatomic, strong) UITextView *output;

@end
