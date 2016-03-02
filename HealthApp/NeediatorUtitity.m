//
//  NeediatorUtitity.m
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorUtitity.h"

@implementation NeediatorUtitity


/* Bar Button */

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








/* Fonts */

+ (UIFont *)mediumFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}


+ (UIFont *)boldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size];
}

+ (UIFont *)demiBoldFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size];
}


/* Saving Data */

+ (void)save:(id)data forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:key];
    [defaults synchronize];
}


+ (id)savedDataForKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id data = [defaults objectForKey:key];
    if (data)
    {
        return data;
    }
    
    return nil;
}

+ (void)clearDataForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}



@end
