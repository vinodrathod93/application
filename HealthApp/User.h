//
//  User.h
//  Chemist Plus
//
//  Created by adverto on 07/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *profilePic;

-(void)save;
+ (id)savedUser;
+ (void)clearUser;

@end
