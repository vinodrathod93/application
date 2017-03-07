//
//  Location.h
//  Neediator
//
//  Created by adverto on 10/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject


@property (nonatomic, copy) NSString *location_name;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic) BOOL isCurrentLocation;

-(void)save;
+ (id)savedLocation;
+ (void)clearLocation;

@end
