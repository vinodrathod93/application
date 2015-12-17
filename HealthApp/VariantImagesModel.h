//
//  VariantImagesModel.h
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface VariantImagesModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *mini_url;
@property (nonatomic, copy) NSString *small_url;
@property (nonatomic, copy) NSString *product_url;

@end
