//
//  RootTabBarControllerDelegate.m
//  Chemist Plus
//
//  Created by adverto on 12/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "RootTabBarControllerDelegate.h"
#import "LogSignViewController.h"
#import "User.h"

@implementation RootTabBarControllerDelegate

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"clicked");
    
    if (tabBarController.selectedIndex == 3) {
        
        User *user = [User savedUser];
        NSLog(@"register clicked %lu",(unsigned long)tabBarController.selectedIndex);
        
        if (user == nil) {
            NSLog(@"go back to home index");
            
            [tabBarController setSelectedIndex:0];
            LogSignViewController *logsignVC = [tabBarController.selectedViewController.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
            [tabBarController.selectedViewController presentViewController:logsignVC animated:YES completion:nil];
        }
    }
}





@end
