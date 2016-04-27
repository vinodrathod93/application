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
+ (UIFont *)regularFontWithSize:(CGFloat)size;
+ (UIFont *)mediumFontWithSize:(CGFloat)size;
+ (UIFont *)boldFontWithSize:(CGFloat)size;
+ (UIFont *)demiBoldFontWithSize:(CGFloat)size;

+ (void)save:(id)data forKey:(NSString *)key;
+ (id)savedDataForKey:(NSString *)key;
+ (void)clearDataForKey:(NSString *)key;

+ (UIColor *)defaultColor;
+ (UIColor *)mainColor;
+ (UIColor *)blurredDefaultColor;
+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message onController:(UIViewController *)controller;
+ (void)showLoginOnController:(UIViewController *)controller isPlacingOrder:(BOOL)isPlacing;
+ (UIView *)showDimViewWithFrame:(CGRect)frame;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (NSString *)getFormattedDate:(NSString *)date;
+(NSString *)getFormattedTime:(NSString *)date;
@end
