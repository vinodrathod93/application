//
//  FilterListModel.h
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FilterListModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *minimum_delivery;
@property (nonatomic, copy) NSArray *ratings;

@end
