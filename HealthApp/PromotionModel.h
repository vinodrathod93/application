//
//  PromotionModel.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface PromotionModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *prom_id;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSNumber *cat_id;
@property (nonatomic, copy) NSNumber *store_id;
@property (nonatomic, assign) BOOL is_star_promoter;


@end
