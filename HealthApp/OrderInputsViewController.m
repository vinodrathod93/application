//
//  OrderInputsViewController.m
//  Chemist Plus
//
//  Created by adverto on 27/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "OrderInputsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define PLACE_ORDER_URL @"http://chemistplus.in/products_orders.php"

@interface OrderInputsViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation OrderInputsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancelPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)proceedPressed:(id)sender {
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *postString = [NSString stringWithFormat:@"name=%@&mobileno=%@&address=%@",self.nameTextField.text, self.mobileTextField.text, self.addressTextField.text];
    NSData *data = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:PLACE_ORDER_URL]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseID = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseID);
        
        [self.hud hide:YES];
    }];
    
    [task resume];
    [self showHUD];
}

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}


@end
