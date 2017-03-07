//
//  MyOrdersResponseModel.h
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "MyOrdersModel.h"

@interface MyOrdersResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *orders;
@property(nonatomic,copy)   NSArray *statusArray;
@property(nonatomic,copy)   NSArray *Prescriptions;
@property(nonatomic,copy)   NSArray *pendingorderreason;
@property(nonatomic,copy)   NSArray *processingorderreason;




@end
