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

-(NSNumber *)price {
    return [self.model valueForKey:@"price"];
}

-(NSString *)display_price {
    return [self.model valueForKey:@"displayPrice"];
}

-(NSArray *)images {
    NSArray *allImages = self.model.product_img;
    
    return allImages;
}

-(NSNumber *)productID {
    return [self.model valueForKey:@"productID"];
}

-(NSNumber *)quantity {
    return @(1);
}


-(CGFloat)heightForSummaryTextInTableViewCellWithWidth:(CGFloat)width {
    NSString *string = [self summary];
    CGFloat height = [string boundingRectWithSize:CGSizeMake(width, 2000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]} context:nil].size.height;
    
    CGFloat padding = 40.0f;
    NSLog(@"%f",height);
    
    return height + padding;
}





@end
