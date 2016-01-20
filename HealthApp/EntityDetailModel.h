//
//  EntityDetailModel.h
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface EntityDetailModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *body;

@property(nonatomic) BOOL canBeExpanded;
@property(nonatomic) BOOL isExpanded;

@end
