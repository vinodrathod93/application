//
//  NeediatorUtitity.m
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorUtitity.h"
#import "SearchViewController.h"

@implementation NeediatorUtitity


/* Bar Button */

+ (UIBarButtonItem *)locationBarButton {
    
    Location *location = [Location savedLocation];
    NSArray *string_array = [location.location_name componentsSeparatedByString:@","];
    
    
//    UIButton *locButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    locButton.titleLabel.numberOfLines = 0;
//    [locButton setTitle:string_array[0] forState:UIControlStateNormal];
//    [locButton sizeToFit];
//    
//    UIBarButtonItem *customButton = [[UIBarButtonItem alloc] initWithCustomView:locButton];
    
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
    
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    [tabBarController setSelectedIndex:1];
    
    NSLog(@"%@", [tabBarController selectedViewController]);
    
    UINavigationController *searchNavigation = [tabBarController selectedViewController];
    
    NSLog(@"%@", [searchNavigation topViewController]);
    SearchViewController *searchVC = (SearchViewController *)[searchNavigation topViewController];
    
    
    [searchVC activateSearchBar];
    [searchVC showLocationScope];
    
}



+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message onController:(UIViewController *)controller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void)showLoginOnController:(UIViewController *)controller isPlacingOrder:(BOOL)isPlacing {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    LogSignViewController *logSignVC = (LogSignViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
    logSignVC.isPlacingOrder = isPlacing;
    
    UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
    logSignNav.navigationBar.tintColor = controller.view.tintColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
    }
    
    [controller presentViewController:logSignNav animated:YES completion:nil];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



/* Fonts */

+ (UIFont *)regularFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
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



#pragma mark - Views

+ (UIView *)showDimViewWithFrame:(CGRect)frame {
    UIView *dimView = [[UIView alloc] initWithFrame:frame];
    
    
    return dimView;
}





#pragma mark - Color

+(UIColor *)defaultColor {
    return [UIColor colorWithRed:235/255.f green:235/255.f blue:240/255.f alpha:1.0];
}


+(UIColor *)mainColor {
    return [UIColor colorWithRed:246/255.f green:236/255.f blue:84/255.f alpha:1.0];
}


+(UIColor *)blurredDefaultColor {
    return [UIColor colorWithRed:247/255.f green:247/255.f blue:249/255.f alpha:1.0];
}


#pragma mark - Functions 



+(NSString *)getFormattedDate:(NSString *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    
    NSDate *completedDate = [dateFormatter dateFromString:date];
    
    [dateFormatter setDateFormat:@"EEEE, MMMM dd, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:completedDate];
    
    
    return dateString;
}


+(NSString *)getFormattedTime:(NSString *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    
    NSDate *completedDate = [dateFormatter dateFromString:date];
    
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:completedDate];
    
    return timeString;
}



//+(void)checkRunningTask:(NSURLSessionDataTask *)task WithCompletion:()
@end
