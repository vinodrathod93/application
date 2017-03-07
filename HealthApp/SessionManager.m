//
//  SessionManager.m
//  Chemist Plus
//
//  Created by adverto on 03/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "SessionManager.h"

//static NSString *const kBaseURL = @"http://www.elnuur.com";





@implementation SessionManager

- (id)init {
 //   self = [super initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    if(!self) return nil;
    
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return self;
}

+ (id)sharedManager
{
    static SessionManager *_sessionManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc] init];
    });
    
    
    return _sessionManager;
}

@end
