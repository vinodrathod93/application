//
//  MyOrderByStatus.m
//  Neediator
//
//  Created by adverto on 19/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MyOrderByStatus.h"

@implementation MyOrderByStatus



+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"userid"     : @"user_id",
             @"status"     : @"status"
             
             };
}



@end
