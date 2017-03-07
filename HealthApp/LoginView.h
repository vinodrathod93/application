//
//  LoginView.h
//  Neediator
//
//  Created by adverto on 21/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeMessage;
@property (weak, nonatomic) IBOutlet UILabel *detailMessage;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@end
