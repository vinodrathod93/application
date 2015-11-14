//
//  TaxonomyModel.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TaxonModel.h"

@interface TaxonomyModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *taxonomyName;
@property (nonatomic, copy) NSArray *taxons;
@end
