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
    [encoder encodeObject:self.userID forKey:@"id"];
    [encoder encodeObject:self.mobno forKey:@"phoneno"];
    [encoder encodeObject:self.firstName forKey:@"firstname"];
    [encoder encodeObject:self.lastName forKey:@"lastname"];
    [encoder encodeObject:self.email forKey:@"emailid"];
    [encoder encodeObject:self.fullName forKey:@"FullName"];
    [encoder encodeObject:self.profilePic forKey:@"imageurl"];
    [encoder encodeObject:self.access_token forKey:@"AccessToken"];
    [encoder encodeObject:self.default_country_id forKey:@"defaultCountry"];
    [encoder encodeObject:self.bill_address forKey:@"billAddress"];
    [encoder encodeObject:self.ship_address forKey:@"shipAddress"];
    [encoder encodeObject:self.addresses forKey:@"addresses"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.DateOfBirth forKey:@"DOB"];
}

#pragma mark - Decoding
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _userID                 = [decoder decodeObjectForKey:@"id"];
        _gender                 = [decoder decodeObjectForKey:@"gender"];
        _mobno                  = [decoder decodeObjectForKey:@"phoneno"];
        _firstName              = [decoder decodeObjectForKey:@"firstname"];
        _lastName               = [decoder decodeObjectForKey:@"lastname"];
        _email                  = [decoder decodeObjectForKey:@"emailid"];
        _DateOfBirth            = [decoder decodeObjectForKey:@"DOB"];
        _fullName               = [decoder decodeObjectForKey:@"FullName"];
        _profilePic             = [decoder decodeObjectForKey:@"imageurl"];
        _access_token           = [decoder decodeObjectForKey:@"AccessToken"];
        _default_country_id     = [decoder decodeObjectForKey:@"defaultCountry"];
        _bill_address           = [decoder decodeObjectForKey:@"billAddress"];
        _ship_address           = [decoder decodeObjectForKey:@"shipAddress"];
        _addresses              = [decoder decodeObjectForKey:@"addresses"];
    }
    return self;
}



//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeObject:self.userID forKey:@"userID"];
//    [encoder encodeObject:self.mobno forKey:@"MobNo"];
//    [encoder encodeObject:self.firstName forKey:@"FirstName"];
//    [encoder encodeObject:self.lastName forKey:@"LastName"];
//    [encoder encodeObject:self.email forKey:@"Email"];
//    [encoder encodeObject:self.fullName forKey:@"FullName"];
//    [encoder encodeObject:self.profilePic forKey:@"imageurl"];
//    [encoder encodeObject:self.access_token forKey:@"AccessToken"];
//    [encoder encodeObject:self.default_country_id forKey:@"defaultCountry"];
//    [encoder encodeObject:self.bill_address forKey:@"billAddress"];
//    [encoder encodeObject:self.ship_address forKey:@"shipAddress"];
//    [encoder encodeObject:self.addresses forKey:@"addresses"];
//    [encoder encodeObject:self.gender forKey:@"gender"];
//}
//
//#pragma mark - Decoding
//- (id)initWithCoder:(NSCoder *)decoder
//{
//    self = [super init];
//    if (self)
//    {
//        _userID                 = [decoder decodeObjectForKey:@"userID"];
//        _gender                 = [decoder decodeObjectForKey:@"gender"];
//        _mobno                  = [decoder decodeObjectForKey:@"MobNo"];
//        _firstName              = [decoder decodeObjectForKey:@"FirstName"];
//        _lastName               = [decoder decodeObjectForKey:@"LastName"];
//        _email                  = [decoder decodeObjectForKey:@"Email"];
//        _fullName               = [decoder decodeObjectForKey:@"FullName"];
//        _profilePic             = [decoder decodeObjectForKey:@"imageurl"];
//        _access_token           = [decoder decodeObjectForKey:@"AccessToken"];
//        _default_country_id     = [decoder decodeObjectForKey:@"defaultCountry"];
//        _bill_address           = [decoder decodeObjectForKey:@"billAddress"];
//        _ship_address           = [decoder decodeObjectForKey:@"shipAddress"];
//        _addresses              = [decoder decodeObjectForKey:@"addresses"];
//    }
//    return self;
//}


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
