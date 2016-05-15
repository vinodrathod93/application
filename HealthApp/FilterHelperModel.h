//
//  FilterHelperModel.h
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "FilterListModel.h"

@interface FilterHelperModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *filterID;
@property (nonatomic, copy) NSString *name;

@property(nonatomic) BOOL canBeExpanded;
@property(nonatomic) BOOL isExpanded;
@property (nonatomic, strong) FilterListModel *filterModel;

@end
