//
//  SessionManager.h
//  Chemist Plus
//
//  Created by adverto on 03/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPSessionManager.h"

@interface SessionManager : AFHTTPSessionManager 

+ (id)sharedManager;

@end
