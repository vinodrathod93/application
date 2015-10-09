//
//  OrderCompleteViewController.m
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "OrderCompleteViewController.h"

@interface OrderCompleteViewController ()

@end

@implementation OrderCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.order_number.text = self.order_id;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}
@end
