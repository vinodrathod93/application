//
//  NSString+SignupValidation.m
//  Chemist Plus
//
//  Created by adverto on 12/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "NSString+SignupValidation.h"

@implementation NSString (SignupValidation)


- (BOOL)isValidEmail {
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailPredicate evaluateWithObject:self];
}

- (BOOL)isValidPassword {
    return (self.length >= 5);
}

- (BOOL)isValidName {
    return (self.length >= 1);
}

- (BOOL)isValidDOB {
    return (self.length >= 1);
}


@end
