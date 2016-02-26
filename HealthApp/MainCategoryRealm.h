//
//  MainCategoryRealm.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Realm/Realm.h>
#import "CategoryModel.h"



RLM_ARRAY_TYPE(SubCategoryModel)

@interface MainCategoryRealm : RLMObject

@property  NSNumber<RLMInt> *cat_id;
@property  NSString *name;
@property  NSString *image_url;
@property  NSString *color_code;

@property  RLMArray<SubCategoryModel> *subCatArray;

- (id)initWithMantleModel:(CategoryModel *)model;

@end
