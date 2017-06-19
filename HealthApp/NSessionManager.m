//
//  NSessionManager.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NSessionManager.h"

//static NSString *const kBaseURL = @"http://neediator.in";

//static NSString *const kBaseURL = @"http://192.168.0.90/NeediatorWebservice";

static NSString *const kBaseURL = @"http://neediator.net"; //@"http://192.168.1.199";





@implementation NSessionManager

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    if(!self) return nil;
    
    self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
}

+ (id)sharedManager {
    static NSessionManager *_sessionManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc] init];
    });
    
    
    return _sessionManager;
}

@end
