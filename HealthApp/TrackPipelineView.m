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

@end
