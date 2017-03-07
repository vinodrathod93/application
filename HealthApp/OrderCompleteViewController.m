//
//  OrderCompleteViewController.m
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "OrderCompleteViewController.h"
#import "PaymentViewController.h"
#import "BookConfirmViewController.h"
#import "BookingViewController.h"
#import "PaymentOptionsViewController.h"
#import "UploadPrescriptionViewController.h"
#import "UploadPreviewController.h"
#import "MyOrdersViewController.h"

@interface OrderCompleteViewController ()

@end

@implementation OrderCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeVC)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    if (self.booking_id != nil) {
        self.order_number.text = self.booking_id;
        self.viewButton.hidden = YES;
        
    }
    else if (self.order_id != nil) {
        self.order_number.text = self.order_id;
        
    }
    
    if (self.message != nil) {
        self.messageLabel.text = self.message;
    }
    
    if (self.heading != nil) {
        self.headingLabel.text = self.heading.uppercaseString;
    }
    
    if (self.additonalInfo != nil) {
        self.additionalInfoLabel.text = self.additonalInfo;
    }
    
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for(UIViewController* vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[PaymentViewController class]]) {
            [viewControllers removeObject:vc];
        }
        
        if ([vc isKindOfClass:[BookConfirmViewController class]]) {
            [viewControllers removeObject:vc];
        }
        
        if ([vc isKindOfClass:[BookingViewController class]]) {
            [viewControllers removeObject:vc];
        }
        
        if ([vc isKindOfClass:[PaymentOptionsViewController class]]) {
            [viewControllers removeObject:vc];
        }
        
        if ([vc isKindOfClass:[UploadPreviewController class]]) {
            [viewControllers removeObject:vc];
        }
        if ([vc isKindOfClass:[UploadPrescriptionViewController class]]) {
            [viewControllers removeObject:vc];
        }
    }
    self.navigationController.viewControllers = [NSArray arrayWithArray:viewControllers];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)viewOrderPressed:(id)sender {
    
    MyOrdersViewController *myOrdersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"myOrdersVC"];
    [self.navigationController pushViewController:myOrdersVC animated:YES];
}


-(void)closeVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
