//
//  DetailProductViewModel.m
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DetailProductViewModel.h"

@interface DetailProductViewModel()

@property (nonatomic, strong) ProductDetail *model;

@end

@implementation DetailProductViewModel

- (id)initWithModel:(ProductDetail *)model
{
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

-(NSInteger)numberOfRows {
    return 1;
}

-(NSString *)summary {
    return [self.model valueForKey:@"summary"];
}

-(NSString *)name {
    return [self.model valueForKey:@"name"];
}

-(NSString *)price {
    return [self.model valueForKey:@"price"];
}

-(NSString *)image {
    return [self.model valueForKey:@"image"];
}

-(NSString *)productID {
    return [self.model valueForKey:@"productID"];
}

-(NSString *)quantity {
    return @(1).stringValue;
}


-(CGFloat)heightForSummaryTextInTableViewCellWithWidth:(CGFloat)width {
    NSString *string = [self summary];
    CGFloat height = [string boundingRectWithSize:CGSizeMake(width, 2000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]} context:nil].size.height;
    
    CGFloat padding = 40.0f;
    NSLog(@"%f",height);
    
    return height + padding;
}





@end
