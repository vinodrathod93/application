//
//  MyOrdersModel.h
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MyOrdersModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *orderNumber;
@property (nonatomic, copy) NSString *orderTotal;
@property (nonatomic, copy) NSString *orderState;
@property (nonatomic, copy) NSString *shipmentState;
@property (nonatomic, copy) NSString *paymentState;
@property (nonatomic, copy) NSString *completed_date;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSArray *line_items;

@property (nonatomic) BOOL isExpanded;
@end
