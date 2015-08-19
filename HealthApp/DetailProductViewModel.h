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
-(NSString *)price;
-(NSString *)image;

-(CGFloat)heightForSummaryTextInTableViewCellWithWidth:(CGFloat)width;
-(void)pushToCart;

@end
