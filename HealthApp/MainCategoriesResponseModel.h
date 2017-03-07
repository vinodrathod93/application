//
//  MainCategoriesResponseModel.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MainCategoriesResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, copy) NSArray *promotions;

@end
