//
//  LineItemsModel.h
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface LineItemsModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *variantName;
@property (nonatomic, copy) NSString *variantPrice;
@property (nonatomic, copy) NSString *quantity;
@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *imageURL;

@end
