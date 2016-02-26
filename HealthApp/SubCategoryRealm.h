//
//  SubCategoryRealm.h
//  Neediator
//
//  Created by adverto on 26/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Realm/Realm.h>
#import "SubCategoryModel.h"

@interface SubCategoryRealm : RLMObject

@property  NSNumber<RLMInt> *subCat_id;
@property  NSNumber<RLMInt> *cat_id;
@property  NSString *name;
@property  NSString *image_url;

- (id)initWithMantleModel:(SubCategoryModel *)model;

@end
