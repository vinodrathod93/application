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

-(NSString *)master_price {
    return [self.model valueForKey:@"masterPrice"];
}

-(NSArray *)images {
    NSArray *allImages = self.model.product_img;
    
    return allImages;
}

-(NSArray *)largeImages {
    NSArray *largeImages = self.model.large_img;
    
    return largeImages;
}

-(NSArray *)smallImages {
    NSArray *smallImages = self.model.small_img;
    
    return smallImages;
}

-(NSNumber *)productID {
    return [self.model valueForKey:@"productID"];
}

-(NSNumber *)storeID {
    return [self.model valueForKey:@"storeID"];
}

-(NSNumber *)quantity {
    return @(1);
}

-(NSNumber *)total_on_hand {
    return [self.model valueForKey:@"total_on_hand"];
}



-(BOOL)isOutOfStock {
    if ([[self.model valueForKey:@"total_on_hand"] isEqual: @(0)]) {
        return true;
    } else
        return false;
}

-(CGFloat)heightForSummaryTextInTableViewCellWithWidth:(CGFloat)width {
    NSString *string = [self summary];
    CGFloat height = [string boundingRectWithSize:CGSizeMake(width, 2000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]} context:nil].size.height;
    
    CGFloat padding = 40.0f;
    NSLog(@"%f",height);
    
    return height + padding;
}



@end
