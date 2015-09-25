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
-(NSNumber *)productID;
-(NSNumber *)quantity;

-(CGFloat)heightForSummaryTextInTableViewCellWithWidth:(CGFloat)width;

@end
