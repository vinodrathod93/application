//
//  OptionsViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "OptionsViewController.h"

@interface OptionsViewController ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *optionButtons;
@end

@implementation OptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    for (UIButton *button in self.optionButtons) {
        button.layer.cornerRadius   =   3.f;
        button.layer.borderColor    =   [UIColor darkGrayColor].CGColor;
        button.layer.borderWidth    =   1.f;
    }
    
    NSArray *array;
    
    if (self.isRating) {
        array    =   @[
                                      @"5",
                                      @"4+",
                                      @"3+",
                                      @"2+",
                                      @"1+"
                                      ];
        
        
        
    }
    else {
        array    =   @[
                                      @"₹500 +",
                                      @"₹251 - ₹500",
                                      @"₹101 - ₹250",
                                      @"₹0 - ₹100",
                                      @"₹0"
                                      ];
    }
    
    
    [self.optionButtons enumerateObjectsUsingBlock:^(UIButton  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setTitle:array[idx] forState:UIControlStateNormal];
        [obj setTag:idx];
        [obj addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    
    
}


-(void)buttonTapped:(UIButton *)sender {
    
    
    for (UIButton *button in self.optionButtons) {
        if ([button isEqual:sender]) {
            [button setBackgroundColor:mainColor()];
        }
        else
            [button setBackgroundColor:defaultColor()];
    }
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
