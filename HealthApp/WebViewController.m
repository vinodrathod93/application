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

@implementation WebViewController {
    MBProgressHUD *_hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.center = self.view.center;
    _hud.labelText = @"Loading...";
    
    if (self.htmlString) {
        
        [self.webView loadHTMLString:self.htmlString  baseURL:nil];
    }
    else {
        
        NSURL *url = [NSURL URLWithString:self.urlString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        self.webView.scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.webView loadRequest:req];
        
        
    //    @"http://maps.google.com/?q=New+York"
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_hud hide:YES];
}


@end
