//
//  TaxonomyListResponseModel.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TaxonModel.h"
#import "TaxonomyModel.h"

@interface TaxonomyListResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *taxonomies;
@property (nonatomic, copy) NSArray *shopInfo;
@property (nonatomic, copy) NSArray *offers;


@end
