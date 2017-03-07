//
//  CancelOrderView.m
//  Neediator
//
//  Created by adverto on 27/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "CancelOrderView.h"

@implementation CancelOrderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib {
    
    self.SelectReasonBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.SelectReasonBtn.layer.borderWidth = 1.f;
    self.SelectReasonBtn.layer.masksToBounds = YES;
    
    self.SelectProductBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.SelectProductBtn.layer.borderWidth = 1.f;
    self.SelectProductBtn.layer.masksToBounds = YES;
    
    self.justifyTF.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.justifyTF.layer.borderWidth = 1.f;
    self.justifyTF.layer.masksToBounds = YES;

    
}

@end
