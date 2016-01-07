//
//  RequestOperationManager.h
//  Neediator
//
//  Created by adverto on 07/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface RequestOperationManager : AFHTTPRequestOperationManager

+ (id)sharedManager;

@end
