//
//  PipelineView.m
//  Neediator
//
//  Created by adverto on 27/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "PipelineView.h"

@implementation PipelineView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect drawRect = CGRectMake(rect.origin.x, rect.origin.y,rect.size.width, _currentHeight);
    
    CGContextSetRGBFillColor(context, 100.0f/255.0f, 100.0f/255.0f, 100.0f/255.0f, 1.0f);
    
    CGContextFillRect(context, drawRect);
}


@end
