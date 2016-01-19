//
//  ImageModalViewController.m
//  Neediator
//
//  Created by adverto on 19/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ImageModalViewController.h"

@implementation ImageModalViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.model.image_url];
    [self.bigImageView sd_setImageWithURL:url];
    
    UIGestureRecognizer *touchGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(didTouch:)];
    [self.view addGestureRecognizer:touchGR];
}

- (void)didTouch:(UIGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
