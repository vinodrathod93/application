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
@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, copy) NSString *default_country_id;
@property (nonatomic, copy) NSDictionary *bill_address;
@property (nonatomic, copy) NSDictionary *ship_address;

-(void)save;
+ (id)savedUser;
+ (void)clearUser;

@end
