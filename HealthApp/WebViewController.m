//
//  WebViewController.m
//  Neediator
//
//  Created by adverto on 14/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
    if (self.htmlString) {
        
        [self.webView loadHTMLString:self.htmlString  baseURL:nil];
    }
    else {
        
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        self.webView.scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.webView loadRequest:req];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    self.webView.frame = CGRectMake(0, self.topLayoutGuide.length, CGRectGetWidth(self.view.frame), self.view.frame.size.height - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
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
