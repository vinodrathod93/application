//
//  FilterListModel.h
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FilterListModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *filterName;
@property (nonatomic, copy) NSArray *filterValues;
@property (nonatomic, copy) NSString *filterParameter;


@property(nonatomic) BOOL canBeExpanded;
@property(nonatomic) BOOL isExpanded;

@end
