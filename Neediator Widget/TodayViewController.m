//
//  TodayViewController.m
//  Neediator Widget
//
//  Created by adverto on 05/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.preferredContentSize = CGSizeMake(0, 130);
    
    [self.ordersButton addTarget:self action:@selector(openMyAccount) forControlEvents:UIControlEventTouchUpInside];
    [self.searchButton addTarget:self action:@selector(openSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.qrButton addTarget:self action:@selector(openQRCode) forControlEvents:UIControlEventTouchUpInside];
    
    [self.favouriteButton addTarget:self action:@selector(openFavourites) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.ordersButton.layer.cornerRadius = 6.f;
    self.ordersButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}


-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

-(void)openMyAccount {
    NSURL *url = [NSURL URLWithString:@"neediator://myaccount"];
    [self.extensionContext openURL:url completionHandler:nil];
}

-(void)openSearch {
    NSURL *url = [NSURL URLWithString:@"neediator://search"];
    [self.extensionContext openURL:url completionHandler:nil];
}

-(void)openQRCode {
    NSURL *url = [NSURL URLWithString:@"neediator://qrcode"];
    [self.extensionContext openURL:url completionHandler:nil];
}

-(void)openFavourites {
    NSURL *url = [NSURL URLWithString:@"neediator://myFavourites"];
    [self.extensionContext openURL:url completionHandler:nil];
}
@end
