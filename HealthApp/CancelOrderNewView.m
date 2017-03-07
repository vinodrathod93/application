//
//  CancelOrderNewView.m
//  Neediator
//
//  Created by adverto on 23/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "CancelOrderNewView.h"

@implementation CancelOrderNewView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)awakeFromNib {
    
    self.selectReasonBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.selectReasonBtn.layer.borderWidth = 1.f;
    self.selectReasonBtn.layer.masksToBounds = YES;
    
    self.TextView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.TextView.layer.borderWidth = 1.f;
    self.TextView.layer.masksToBounds = YES;
    
    
    
    
}


@end
