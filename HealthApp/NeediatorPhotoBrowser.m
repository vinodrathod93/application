//
//  NeediatorPhotoBrowser.m
//  Neediator
//
//  Created by adverto on 25/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorPhotoBrowser.h"


@interface NeediatorPhotoBrowser ()

@end

@implementation NeediatorPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    for (id view in self.view.subviews) {
        
        
        if ([view isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolbar = (UIToolbar *)view;
            
            toolbar.barStyle = UIBarStyleDefault;
        }
        
        if ([view isKindOfClass:[UIScrollView class]])
        {
            
            UIScrollView *_pagingScrollView = (UIScrollView *)view;
            _pagingScrollView.backgroundColor = [UIColor whiteColor];
            
            for (id zoomView in _pagingScrollView.subviews) {
                if ([zoomView isKindOfClass:[MWZoomingScrollView class]]) {
                    MWZoomingScrollView *zoomScrollView = (MWZoomingScrollView *)zoomView;
                    
                    for (id insideZoomView in zoomScrollView.subviews)
                    {
                        if ([insideZoomView isKindOfClass:[MWTapDetectingView class]]) {
                            MWTapDetectingView *tapDetectingView = (MWTapDetectingView *)insideZoomView;
                            tapDetectingView.backgroundColor = [UIColor whiteColor];
                        }
                        else if ([insideZoomView isKindOfClass:[MWTapDetectingImageView class]])
                        {
                            MWTapDetectingImageView *tapDetectingImageView = (MWTapDetectingImageView *)insideZoomView;
                            tapDetectingImageView.backgroundColor = [UIColor whiteColor];
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    
    
//    UINavigationBar *navBar = self.navigationController.navigationBar;
//    navBar.barStyle = UIBarStyleBlackTranslucent;
//    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    // Do any additional setup after loading the view.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
