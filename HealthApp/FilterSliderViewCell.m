//
//  FilterSliderViewCell.m
//  Neediator
//
//  Created by Vinod Rathod on 11/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FilterSliderViewCell.h"

@implementation FilterSliderViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)sliderChanged:(UISlider *)sender {
    int discreteValue = roundl([sender value]); // Rounds float to an integer
    [sender setValue:(float)discreteValue];
    
    self.sliderValue.text = [NSString stringWithFormat:@"%d", discreteValue];
    
    if ([_sliderDelegate respondsToSelector:@selector(sliderChanged:)]) {
        [_sliderDelegate sliderChanged:self];
    }
}

@end
