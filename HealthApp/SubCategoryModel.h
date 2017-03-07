//
//  SubCategoryModel.h
//  Neediator
//
//  Created by adverto on 26/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface SubCategoryModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *subCat_id;
@property (nonatomic, copy) NSNumber *cat_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image_url;

@property (nonatomic, assign) BOOL is_active;

@end
