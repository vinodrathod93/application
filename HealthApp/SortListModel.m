//
//  SortListModel.m
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SortListModel.h"
#import "SortOrderModel.h"

@implementation SortListModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name"        : @"name",
             @"typeArray"   : @"type",
             @"sortID"      : @"id"
             
             };
}

+(NSValueTransformer *)typeArrayJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[SortOrderModel class]];
}



-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    _currentSortOrderIndex = @-1;
    
    return self;
}

@end
