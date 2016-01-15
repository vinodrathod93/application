//
//  NAPIManager.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NAPIManager.h"


@implementation NAPIManager

-(NSURLSessionDataTask *)mainCategoriesWithSuccess:(void (^)(MainCategoriesResponseModel *response))success failure:(void (^)(NSError *error))failure {
    
    return [self GET:kMAIN_CATEGORIES_PATH parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Get main Categories %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // Success Get promotions array & categories array
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSError *responseError;
        MainCategoriesResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[MainCategoriesResponseModel class] fromJSONDictionary:response error:&responseError];
        
        if (responseError) {
            NSLog(@"Error in MainCategoriesResponseModel %@", responseError.localizedDescription);
        }
        else
            success(responseModel);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // Failure send error to main view
        
        failure(error);
    }];
}


@end
