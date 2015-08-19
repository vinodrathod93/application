//
//  OrderConfirmationViewController.m
//  Chemist Plus
//
//  Created by adverto on 08/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "OrderConfirmationViewController.h"

@interface OrderConfirmationViewController ()

@end

@implementation OrderConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.orderMessageView.layer setCornerRadius:10.0f];
    
    self.orderIDLabel.text = self.orderIDString;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)continuePressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
