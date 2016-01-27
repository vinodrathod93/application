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

@property (nonatomic, copy) NSNumber *taxonomyId;
@property (nonatomic, copy) NSString *taxonomyName;
@property (nonatomic, copy) NSNumber *hasTaxons;
@property (nonatomic, copy) NSNumber *catId;
@property (nonatomic, copy) NSArray *taxons;


@property(nonatomic) BOOL canBeExpanded;
@property(nonatomic) BOOL isExpanded;

@end
