//
//  EntityDetailsResponseModel.h
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface EntityDetailsResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *details;
@property (nonatomic, copy) NSArray *offers;

@end
