//
//  NSString+SignupValidation.h
//  Chemist Plus
//
//  Created by adverto on 12/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SignupValidation)

- (BOOL)isValidEmail;
- (BOOL)isValidPassword;
- (BOOL)isValidName;
- (BOOL)isValidDOB;

@end
