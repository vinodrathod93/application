//
//  FavouriteCategoryModel.h
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FavouriteCategoryModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *category_image_url;
@property (nonatomic, copy) NSNumber *cat_id;
@property (nonatomic, copy) NSArray *stores;

@end
