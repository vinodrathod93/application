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



-(NSURLSessionDataTask *)getListingsWithRequestModel:(ListingRequestModel *)request success:(void (^)(ListingResponseModel *response))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:request error:nil];
    
    return [self GET:kLISTING_PATH parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"Get Services %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSLog(@"%@", response);
        
        NSError *responseError;
        ListingResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[ListingResponseModel class] fromJSONDictionary:response error:&responseError];
        
        if (responseError) {
            NSLog(@"Error in Listing Response: %@", responseError.localizedDescription);
            
            failure(responseError);
        }
        else
            success(responseModel);
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}


-(NSURLSessionDataTask *)getEntityDetailsWithRequest:(NSDictionary *)parameter success:(void (^)(EntityDetailsResponseModel *response))success failure:(void (^)(NSError *error))failure {
    
    return [self GET:kENTITY_DETAILS_PATH parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Get Details %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSLog(@"%@", response);
        
        NSError *responseError;
        EntityDetailsResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[EntityDetailsResponseModel class] fromJSONDictionary:response error:&responseError];
        
        if (responseError) {
            NSLog(@"Error in Details Response: %@", responseError.localizedDescription);
        }
        else
            success(responseModel);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


@end
