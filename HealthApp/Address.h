//
//  Address.h
//  Chemist Plus
//
//  Created by adverto on 24/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *pincode;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *landmark;
@property (nonatomic, copy) NSString *town;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;

-(void)save;
+ (id)savedAddress;
+ (void)clearAddress;

@end
