//
//  SortListModel.m
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SortListModel.h"

@implementation SortListModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name"    : @"name",
             @"type"    : @"type",
             @"sortID"  : @"id"
             
             };
}

@end
