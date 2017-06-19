//
//  MainCategoryRealm.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MainCategoryRealm.h"

@implementation MainCategoryRealm

- (id)initWithMantleModel:(CategoryModel *)model
{
    self = [super init];
    if(!self) return nil;
    
    self.SectionID = model.SectionID;
    self.SectionName   = model.SectionName;
    self.ImageUrl = model.ImageUrl;
    self.ColorCode = model.ColorCode;
    self.has_subCat =   model.has_subCat;
    
//    self.sorting_list = model.sorting_list;
//    self.filter_list = model.filter_list;
    
    return self;
}


@end
