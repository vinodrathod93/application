//
//  TrackPipelineView.m
//  Neediator
//
//  Created by adverto on 07/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "TrackPipelineView.h"

@implementation TrackPipelineView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.pipelineView.backgroundColor = [UIColor clearColor];
    
    self.pipelineView.layer.cornerRadius = self.pipelineView.frame.size.width/2;
    self.pipelineView.layer.borderColor = [UIColor blackColor].CGColor;
    self.pipelineView.layer.borderWidth = 1.f;
    
    self.pipelineView.layer.masksToBounds = YES;
}


-(void)drawCurrentOrderState:(NSString *)orderState orderDateTime:(NSString *)dateTime withCode:(int)statusCode {
    CGFloat actualHeight = self.pipelineView.frame.size.height;
    
    NSString *value = [NSString stringWithFormat:@"0.%d",statusCode];
    CGFloat toDrawHeight = actualHeight * value.floatValue;
    
    
    
    
    self.pipelineView.currentHeight = toDrawHeight;
    [self.pipelineView setNeedsDisplay];
    
    
    
    if (statusCode < self.stages.count) {
        
        
        NSString *date = [NeediatorUtitity getFormattedDate:dateTime];
        NSString *time = [NeediatorUtitity getFormattedTime:dateTime];
        
//        int ceilInt = (int)value.floatValue;
        
        UIButton *button = self.stages[statusCode-1];
        UIImageView *imageView = self.stageImages[statusCode-1];
        
        NSString *currentOrderState = [NSString stringWithFormat:@"(%@, %@) %@",date, time, button.titleLabel.text];
        
        [button setTitle:currentOrderState forState:UIControlStateNormal];
        [imageView setImage:[UIImage imageNamed:@"icon"]];
        
    }
    
    
    
}
@end
