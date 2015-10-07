//
//  ReachabiltyManager.h
//  Chemist Plus
//
//  Created by adverto on 07/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface ReachabiltyManager : NSObject

@property (strong, nonatomic) Reachability *reachability;

#pragma mark -
#pragma mark Shared Manager
+ (ReachabiltyManager *)sharedManager;

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
