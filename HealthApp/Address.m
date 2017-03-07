//
//  Address.m
//  Chemist Plus
//
//  Created by adverto on 24/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "Address.h"

@implementation Address

#define kSavedAddress @"SavedAddress"

#pragma mark - Encoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.pincode forKey:@"pincode"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.landmark forKey:@"landmark"];
    [encoder encodeObject:self.town forKey:@"town"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.state forKey:@"state"];
    
}

#pragma mark - Decoding
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _name       = [decoder decodeObjectForKey:@"name"];
        _email   = [decoder decodeObjectForKey:@"email"];
        _pincode   = [decoder decodeObjectForKey:@"pincode"];
        _phone     = [decoder decodeObjectForKey:@"phone"];
        _address  = [decoder decodeObjectForKey:@"address"];
        _landmark  = [decoder decodeObjectForKey:@"landmark"];
        _town = [decoder decodeObjectForKey:@"town"];
        _city = [decoder decodeObjectForKey:@"city"];
        _state = [decoder decodeObjectForKey:@"state"];
        
    }
    return self;
}


-(void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:kSavedAddress];
    [defaults synchronize];
}

+ (id)savedAddress
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kSavedAddress];
    if (data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

+ (void)clearAddress
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kSavedAddress];
    [defaults synchronize];
}
@end
