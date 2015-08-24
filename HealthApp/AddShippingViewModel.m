//
//  AddShippingViewModel.m
//  Chemist Plus
//
//  Created by adverto on 29/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "AddShippingViewModel.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"


@interface AddShippingViewModel()

@property (nonatomic, strong) NSArray *states;
@end

@implementation AddShippingViewModel


- (BOOL)validateName:(NSString *)name {
    if (name.length >= 1) {
        return YES;
    }
    
    return NO;
}

- (BOOL) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%lu", (unsigned long)regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *error = nil;
    NBPhoneNumber *number = [phoneUtil parse:phoneNumber defaultRegion:@"IN" error:&error];
    return [phoneUtil isValidNumber:number];
    
}

- (BOOL)validatePinCode:(NSString*)pincode    {
    NSString *pinRegex = @"^[0-9]{6}$";
    NSPredicate *pinTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinRegex];
    
    BOOL pinValidates = [pinTest evaluateWithObject:pincode];
    return pinValidates;
}

-(NSString *)getAddressValue {
    return @"long_name";
}

-(NSString *)getCityAttribute {
    return @"administrative_area_level_2";
}

-(NSString *)getTownAttribute {
    return @"sublocality_level_1";
}

-(NSString *)getStateAttribute {
    return @"administrative_area_level_1";
}




@end
