//
//  CallBackViewController.m
//  Neediator
//
//  Created by adverto on 18/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "CallBackViewController.h"

@interface CallBackViewController ()

@end

@implementation CallBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Call Me Back";
    self.callmeButton.layer.cornerRadius = 8.0;
    
    
    
    self.problemTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.problemTextView.layer.borderWidth = 0.5f;
    self.problemTextView.layer.cornerRadius = 6.f;
    self.problemTextView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
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
