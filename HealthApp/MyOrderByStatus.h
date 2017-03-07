//
//  MyOrderByStatus.h
//  Neediator
//
//  Created by adverto on 19/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MyOrderByStatus : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *status;


@end
