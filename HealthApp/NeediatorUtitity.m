//
//  NeediatorUtitity.m
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorUtitity.h"

@implementation NeediatorUtitity


+ (UIBarButtonItem *)locationBarButton {
    
    Location *location = [Location savedLocation];
    NSArray *string_array = [location.location_name componentsSeparatedByString:@","];
    
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithTitle:string_array[0] style:UIBarButtonItemStyleDone target:self action:@selector(showLocationView)];
    
    [locationButton setTitleTextAttributes:@{
                                            NSFontAttributeName : [self demiBoldFontWithSize:16.f],
                                            NSForegroundColorAttributeName : [UIColor darkGrayColor]
                                            }
                                  forState:UIControlStateNormal];
    
    
    
    return locationButton;
}

+ (void)showLocationView {
    NSLog(@"Location");
}


+ (UIFont *)mediumFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}


+ (UIFont *)boldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}

+ (UIFont *)demiBoldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size];
}


@end
