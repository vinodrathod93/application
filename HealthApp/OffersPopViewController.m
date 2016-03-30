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

@end
