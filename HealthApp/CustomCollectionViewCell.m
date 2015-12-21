//
//  CustomCollectionViewCell.m
//  Neediator
//
//  Created by adverto on 19/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
        self.imageView.tag   = self.tag;
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.contentView addSubview:self.imageView];
        
    }
    return self;
}

@end
