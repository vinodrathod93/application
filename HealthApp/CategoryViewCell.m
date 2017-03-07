//
//  CategoryViewCell.m
//  Chemist Plus
//
//  Created by adverto on 13/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "CategoryViewCell.h"

@interface CategoryViewCell()

@property (nonatomic, strong)UIImage* dImage;

@end

@implementation CategoryViewCell


- (void)downloadImageFromURL:(NSURL *)imageUrl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _dImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.imageView = (UIImageView *)[self viewWithTag:100];
            self.imageView.image = _dImage;
        });
    });
}

@end
