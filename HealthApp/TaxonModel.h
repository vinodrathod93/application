//
//  TaxonModel.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TaxonModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *taxonID;
@property (nonatomic, copy) NSString *taxonName;
@property (nonatomic, copy) NSNumber *taxonomyID;


@property(nonatomic) BOOL canBeExpanded;
@property(nonatomic) BOOL isExpanded;
@end
