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
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        
        backgroundView.layer.cornerRadius = 3.f;
        backgroundView.layer.borderWidth = 1.0f;
        backgroundView.layer.borderColor = [UIColor clearColor].CGColor;
        backgroundView.layer.masksToBounds = YES;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 5.f);
        self.layer.shadowOpacity = 1.0f;
        self.layer.shadowRadius = 2.0f;
        self.layer.masksToBounds = NO;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:backgroundView.layer.cornerRadius].CGPath;
        
        
        
        
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(35, 25, self.frame.size.width - (2*35.f), self.frame.size.height - 10 - 70)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(5.f, self.imageView.frame.size.height + 10 + 20, self.frame.size.width - 10.f, 40)];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
        
        
        
        [backgroundView addSubview:self.imageView];
        [backgroundView addSubview:self.label];
        
        self.backgroundView = backgroundView;
        
    }
    
    return self;
}
@end
