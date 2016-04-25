//
//  NeediatorMWZoomingScrollView.m
//  Neediator
//
//  Created by adverto on 25/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorMWZoomingScrollView.h"

@implementation NeediatorMWZoomingScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithPhotoBrowser:(MWPhotoBrowser *)browser {
    if ((self = [super init])) {
        
        
        // Setup
        self.backgroundColor = [UIColor blackColor];
        
        for (id insideZoomView in self.subviews) {
            if ([insideZoomView isKindOfClass:[MWTapDetectingView class]]) {
                MWTapDetectingView *tapDetectingView = (MWTapDetectingView *)insideZoomView;
                
                tapDetectingView.backgroundColor = [UIColor whiteColor];
            }
            else if ([insideZoomView isKindOfClass:[MWTapDetectingImageView class]]) {
                MWTapDetectingImageView *tapDetectingImageView = (MWTapDetectingImageView *)insideZoomView;
                
                tapDetectingImageView.backgroundColor = [UIColor whiteColor];
            }
        }
        
        
    }
    return self;
}

@end
