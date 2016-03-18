//
//  MainCategoryRealm.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MainCategoryRealm.h"

@implementation MainCategoryRealm

- (id)initWithMantleModel:(CategoryModel *)model{
    self = [super init];
    if(!self) return nil;
    
    self.cat_id = model.cat_id;
    self.name   = model.name;
    self.image_url = model.image_url;
    self.color_code = model.color_code;
//    self.sorting_list = model.sorting_list;
//    self.filter_list = model.filter_list;
    
    return self;
}


@end
