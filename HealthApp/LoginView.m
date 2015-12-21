//
//  LoginView.m
//  Neediator
//
//  Created by adverto on 21/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "LoginView.h"

@implementation LoginView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.signinButton.layer.cornerRadius = 5.f;
}

@end
