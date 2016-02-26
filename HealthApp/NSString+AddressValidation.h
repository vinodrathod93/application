//
//  NSString+AddressValidation.h
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AddressValidation)

- (BOOL)isValidAddress1;
- (BOOL)isValidatePinCode;
- (BOOL)isValidState;
- (BOOL)isValidCity;
- (BOOL)isValidFirstName;
- (BOOL)isValidLastName;
@end
