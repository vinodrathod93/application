//
//  OffersPopViewController.m
//  Pods
//
//  Created by adverto on 30/03/16.
//
//

#import "OffersPopViewController.h"

@interface OffersPopViewController ()

@end

@implementation OffersPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.offerContentView.layer.cornerRadius = 5.f;
    self.offerContentView.layer.masksToBounds = YES;
    
    self.closeButton.layer.cornerRadius = self.closeButton.frame.size.width/2;
    self.closeButton.layer.masksToBounds = YES;
    
    [self.closeButton addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)closeTapped:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
