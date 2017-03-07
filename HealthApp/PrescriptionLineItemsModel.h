//
//  PrescriptionLineItemsModel.h
//  Neediator
//
//  Created by adverto on 23/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface PrescriptionLineItemsModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *imageURL;


@end
