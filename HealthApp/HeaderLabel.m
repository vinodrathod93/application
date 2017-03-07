//
//  HeaderLabel.m
//  Chemist Plus
//
//  Created by adverto on 24/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "HeaderLabel.h"

@implementation HeaderLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
