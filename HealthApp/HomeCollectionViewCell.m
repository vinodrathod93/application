//
//  HomeCollectionViewCell.m
//  Neediator
//
//  Created by adverto on 09/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell




- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.contentView.layer.cornerRadius = 3.f;
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        self.contentView.layer.masksToBounds = YES;
        
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 5.f);
        self.layer.shadowOpacity = 1.0f;
        self.layer.shadowRadius = 2.0f;
        self.layer.masksToBounds = NO;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
        
        
        if (self.window.frame.size.width <= 320) {
            self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 20, 40, 30)];
        }
        else
            self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(35, 25, self.frame.size.width - (2*35.f), self.frame.size.height - 10 - 70)];
    
        
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(5.f, self.imageView.frame.size.height + 20, self.frame.size.width - 10.f, 40)];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
        
        
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.label];
        
    }
    
    return self;
}
@end
