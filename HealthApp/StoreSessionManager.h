//
//  StoreSessionManager.h
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface StoreSessionManager : AFHTTPSessionManager

+ (id)sharedManager;

@end
