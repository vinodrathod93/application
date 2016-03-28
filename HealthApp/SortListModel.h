//
//  SortListModel.h
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface SortListModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *sortID;

@end