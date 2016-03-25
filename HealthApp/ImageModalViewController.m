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
    
    if (self.model == nil) {
        self.bigImageView.image = self.image;
    }
    else {
        NSURL *url = [NSURL URLWithString:self.model.image_url];
        [self.bigImageView sd_setImageWithURL:url];
    }
    
    
    
    UIGestureRecognizer *touchGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(didTouch:)];
    [self.view addGestureRecognizer:touchGR];
    
    
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    
    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
    
}

- (void)didTouch:(UIGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dismiss:(UIGestureRecognizer*)gesture {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
