//
//  DetailProductViewModel.h
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProductDetail.h"

@interface DetailProductViewModel : NSObject

- (id)initWithModel:(ProductDetail *)model;
-(NSInteger)numberOfRows;
-(NSString *)summary;
-(NSString *)name;
-(NSArray *)images;

-(NSNumber *)price;
-(NSString *)display_price;
-(NSString *)master_price;
-(NSNumber *)productID;
-(NSNumber *)quantity;

-(BOOL)isOutOfStock;

-(NSArray *)largeImages;
-(NSArray *)smallImages;

-(CGFloat)heightForSummaryTextInTableViewCellWithWidth:(CGFloat)width;

-(NSNumber *)total_on_hand;

-(NSNumber *)storeID;
-(NSNumber *)catID;

@end
