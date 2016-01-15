//
//  NSessionManager.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface NSessionManager : AFHTTPSessionManager

+ (id)sharedManager;

@end
