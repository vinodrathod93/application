//
//  MainPromotionRealm.m
//  Neediator
//
//  Created by adverto on 03/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MainPromotionRealm.h"

@implementation MainPromotionRealm

- (id)initWithMantleModel:(PromotionModel *)model
{
    self = [super init];
    if(!self) return nil;
    
    self.code = model.code;
    self.name   = model.name;
    self.image_url = model.image_url;
    
    self.prom_id = model.prom_id;
    self.cat_id  = model.cat_id;
    self.store_id= model.store_id;
    
    return self;
}


@end
