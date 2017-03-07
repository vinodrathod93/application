//
//  NSString+AddressValidation.m
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NSString+AddressValidation.h"

@implementation NSString (AddressValidation)


- (BOOL)isValidAddress1
{
    return (self.length >= 3);
}

- (BOOL)isValidatePinCode    {
    NSString *pinRegex = @"^[0-9]{6}$";
    NSPredicate *pinTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinRegex];
    
    BOOL pinValidates = [pinTest evaluateWithObject:self];
    return pinValidates;
}


-(BOOL)isValidState {
    return (self.length > 1);
}

-(BOOL)isValidCity {
    return (self.length > 1);
}

-(BOOL)isValidFirstName
{
    return (self.length > 2);
}

-(BOOL)isValidLastName
{
    return (self.length > 2);
}

@end
