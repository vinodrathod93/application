//
//  NTextField.m
//  Neediator
//
//  Created by adverto on 16/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "NTextField.h"

@implementation NTextField

static CGFloat leftMargin = 10;

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.layer.borderColor    = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius   = 2.f;
    self.layer.borderWidth    = 0.5f;
    [self setTintColor:[UIColor whiteColor]];
}

// placeholder position

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    
    return bounds;
}

// editing text position

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    
    return bounds;
}

@end
