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
             @"name"        : @"name",
             @"typeArray"   : @"type",
             @"sortID"      : @"id"
             
             };
}


-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    
    if ([dictionaryValue[@"type"] isKindOfClass:[NSArray class]]) {
        
        self.typeArray = dictionaryValue[@"type"];
        
    }
    else
        NSLog(@"Something is nil");
    
    
    return self;
}

@end
