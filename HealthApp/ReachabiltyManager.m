//
//  ReachabiltyManager.m
//  Chemist Plus
//
//  Created by adverto on 07/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "ReachabiltyManager.h"
#import "Reachability.h"

@implementation ReachabiltyManager

#pragma mark -
#pragma mark Default Manager
+ (ReachabiltyManager *)sharedManager {
    static ReachabiltyManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable {
    return [[[ReachabiltyManager sharedManager] reachability ] isReachable];
}

+ (BOOL)isUnreachable {
    return ![[[ReachabiltyManager sharedManager] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN {
    return [[[ReachabiltyManager sharedManager] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi {
    return [[[ReachabiltyManager sharedManager] reachability] isReachableViaWiFi];
}

#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize Reachability
        self.reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
        
        // Start Monitoring
        [self.reachability startNotifier];
    }
    
    return self;
}

@end
