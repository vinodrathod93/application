//
//  User.m
//  Chemist Plus
//
//  Created by adverto on 07/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "User.h"

@implementation User

#define kSavedUser @"SavedUser"

#pragma mark - Encoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.firstName forKey:@"FirstName"];
    [encoder encodeObject:self.lastName forKey:@"LastName"];
    [encoder encodeObject:self.email forKey:@"Email"];
    [encoder encodeObject:self.fullName forKey:@"FullName"];
    [encoder encodeObject:self.profilePic forKey:@"ProfilePicture"];
    
}

#pragma mark - Decoding
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _userID       = [decoder decodeObjectForKey:@"userID"];
        _firstName   = [decoder decodeObjectForKey:@"FirstName"];
        _lastName   = [decoder decodeObjectForKey:@"LastName"];
        _email     = [decoder decodeObjectForKey:@"Email"];
        _fullName  = [decoder decodeObjectForKey:@"FullName"];
        _profilePic  = [decoder decodeObjectForKey:@"ProfilePicture"];
        
    }
    return self;
}


-(void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:kSavedUser];
    [defaults synchronize];
}

+ (id)savedUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kSavedUser];
    if (data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

+ (void)clearUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kSavedUser];
    [defaults synchronize];
}

@end
