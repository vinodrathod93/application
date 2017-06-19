//
//  CategoryModel.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CategoryModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *SectionID; //cat_id;
@property (nonatomic, copy) NSString *SectionName; //name;
@property (nonatomic, copy) NSString *ImageUrl; //image_url;
@property (nonatomic, copy) NSString *ColorCode; //color_code;





@property (nonatomic, assign) BOOL is_active;
@property (nonatomic, assign) BOOL is_product;
@property (nonatomic, assign) BOOL has_subCat;

//@property (nonatomic, copy) NSArray *subCat_array;


@end
