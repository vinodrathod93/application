//
//  WebViewController.h
//  Neediator
//
//  Created by adverto on 14/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;

@property (nonatomic, strong) NSString *htmlString;
@end
