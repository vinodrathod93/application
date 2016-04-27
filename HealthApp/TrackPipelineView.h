//
//  TrackPipelineView.h
//  Neediator
//
//  Created by adverto on 07/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PipelineView.h"

@interface TrackPipelineView : UIView

@property (weak, nonatomic) IBOutlet PipelineView *pipelineView;


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stages;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stageImages;

-(void)drawCurrentOrderState:(NSString *)orderState orderDateTime:(NSString *)dateTime withCode:(int)statusCode;
@end
