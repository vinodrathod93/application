//
//  NeediatorUtitity.h
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NeediatorUtitity : NSObject

+ (UIBarButtonItem *)locationBarButton;
+ (UIFont *)mediumFontWithSize:(CGFloat)size;
+ (UIFont *)boldFontWithSize:(CGFloat)size;
+ (UIFont *)demiBoldFontWithSize:(CGFloat)size;

+ (void)save:(id)data forKey:(NSString *)key;
+ (id)savedDataForKey:(NSString *)key;
+ (void)clearDataForKey:(NSString *)key;

+(UIColor *)defaultColor;

@end
