//
//  TaxonModel.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "TaxonModel.h"

@implementation TaxonModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"taxonId": @"id",
             @"taxonName": @"name"
             };
}

@end
