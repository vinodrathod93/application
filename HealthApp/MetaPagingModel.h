//
//  MetaPagingModel.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MetaPagingModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *count;
@property (nonatomic, copy) NSNumber *total_count;
@property (nonatomic, copy) NSNumber *current_page;
@property (nonatomic, copy) NSNumber *per_page;
@property (nonatomic, copy) NSNumber *pages;


@end
