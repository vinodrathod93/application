//
//  AddShippingViewModel.h
//  Chemist Plus
//
//  Created by adverto on 29/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddShippingViewModel : NSObject

- (BOOL)validEmail:(NSString*) emailString;
- (BOOL)validatePhone:(NSString *)phoneNumber;
- (BOOL)validatePinCode:(NSString*)pincode;

-(NSString *)getAddressValue;
-(NSString *)getCityAttribute;
-(NSString *)getTownAttribute;
-(NSString *)getStateAttribute;

@end
