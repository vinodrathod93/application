//
//  FilterSliderViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 11/05/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SliderFilterDelegate <NSObject>

-(void)sliderChanged:(id)self;

@end

@interface FilterSliderViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel * sliderValue;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *filterName;

-(IBAction)sliderChanged:(id)sender;

@property (weak, nonatomic) id<SliderFilterDelegate>sliderDelegate;

@end
