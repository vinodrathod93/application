//
//  RequestOperationManager.m
//  Neediator
//
//  Created by adverto on 07/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "RequestOperationManager.h"

static NSString *const kBaseURL = @"http://www.elnuur.com";

@implementation RequestOperationManager

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    if(!self) return nil;
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
}

+ (id)sharedManager {
    static RequestOperationManager *_sessionManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc] init];
    });
    
    
    return _sessionManager;
}

@end
