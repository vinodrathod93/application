//
//  SubCategoryRealm.m
//  Neediator
//
//  Created by adverto on 26/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SubCategoryRealm.h"

@implementation SubCategoryRealm

- (id)initWithMantleModel:(SubCategoryModel *)model{
    self = [super init];
    if(!self) return nil;
    
    self.subCat_id = model.sectionID;
    self.cat_id = model.categoryID;
    self.name   = model.name;
    self.image_url = model.image_url;
    
    return self;
}

@end
