//
//  HomeCollectionViewCell.m
//  Neediator
//
//  Created by adverto on 09/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell


-(void)awakeFromNib {
    [super awakeFromNib];
    
    
    
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.cornerRadius = 3.f;
        //    self.layer.masksToBounds = YES;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 5;
        self.layer.shadowOffset = CGSizeMake(10.f, 10.f);
        
        
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(35, 25, self.frame.size.width - (2*35.f), self.frame.size.height - 10 - 70)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(5.f, self.imageView.frame.size.height + 10 + 20, self.frame.size.width - 10.f, 40)];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        
        [backgroundView addSubview:self.imageView];
        [backgroundView addSubview:self.label];
        
        self.backgroundView = backgroundView;
        
    }
    
    return self;
}
@end
