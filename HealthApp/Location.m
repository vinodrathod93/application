//
//  Location.m
//  Neediator
//
//  Created by adverto on 10/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "Location.h"

@implementation Location


#define kSavedLocation @"SavedLocation"
#define kCurrentLocation @"CurrentLocation"

#pragma mark - Encoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.location_name forKey:@"location_name"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeBool:self.isCurrentLocation forKey:@"isCurrentLocation"];
}

#pragma mark - Decoding
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _location_name         = [decoder decodeObjectForKey:@"location_name"];
        _latitude              = [decoder decodeObjectForKey:@"latitude"];
        _longitude             = [decoder decodeObjectForKey:@"longitude"];
        _isCurrentLocation     = [decoder decodeBoolForKey:@"isCurrentLocation"];
        
    }
    return self;
}


-(void)save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:data forKey:kSavedLocation];
    [defaults synchronize];
}

+ (id)savedLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kSavedLocation];
    if (data)
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}


+ (void)clearLocation
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kSavedLocation];
    [defaults synchronize];
}


@end
