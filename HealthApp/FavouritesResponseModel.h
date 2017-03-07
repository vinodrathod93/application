//
//  FavouritesResponseModel.h
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FavouritesResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *favouriteCategories;

@end
