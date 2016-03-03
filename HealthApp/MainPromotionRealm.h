//
//  MainPromotionRealm.h
//  Neediator
//
//  Created by adverto on 03/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Realm/Realm.h>
#import "PromotionModel.h"

@interface MainPromotionRealm : RLMObject

@property  NSData *image_data;

@property  NSString *code;
@property  NSString *name;
@property  NSString *image_url;

@property  NSNumber<RLMInt> *prom_id;
@property  NSNumber<RLMInt> *cat_id;
@property  NSNumber<RLMInt> *store_id;

- (id)initWithMantleModel:(PromotionModel *)model;

@end
