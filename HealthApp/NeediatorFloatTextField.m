//
//  NeediatorFloatTextField.m
//  Neediator
//
//  Created by Vinod Rathod on 22/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "NeediatorFloatTextField.h"

static CGFloat leftMargin   = 10;
static CGFloat YOffset      = 5;

@implementation NeediatorFloatTextField

-(void)awakeFromNib {
    
    [super awakeFromNib];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - 0.5f, self.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = [UIColor darkGrayColor].CGColor;
    [self.layer addSublayer:bottomBorder];
}


// placeholder position

- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    bounds.origin.y += YOffset;
    
    return bounds;
}

// editing text position

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    bounds.origin.y += YOffset;
    
    return bounds;
}

@end
