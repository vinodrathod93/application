//
//  CategoryModel.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CategoryModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *cat_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *group;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, assign) BOOL is_active;
@property (nonatomic, copy) NSString *color_code;


@end
