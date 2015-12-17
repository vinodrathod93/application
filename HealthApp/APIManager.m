//
//  APIManager.m
//  Chemist Plus
//
//  Created by adverto on 05/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "APIManager.h"
#import "User.h"


static NSString *const kStoresListPath = @"/api/stores";
static NSString *const kTaxonomiesListPath = @"/api/taxonomies";
static NSString *const kMyOrdersPath       = @"/api/orders/mine";
static NSString *const kStoreTokenKey = @"3b362afd771255dcc06c12295c90eb8fa5ef815605374dbc";

@implementation APIManager

-(NSURLSessionDataTask *)getStoresWithRequestModel:(StoreListRequestModel *)requestModel success:(void (^)(StoreListResponseModel *))success failure:(void (^)(NSError *))failure {
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:requestModel error:nil];
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [parametersWithKey setObject:kStoreTokenKey forKey:@"token"];
    
    
    return [self GET:kStoresListPath parameters:parametersWithKey success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSLog(@"Response = %@",responseDictionary);
        
        NSError *error;
        StoreListResponseModel *list = [MTLJSONAdapter modelOfClass:StoreListResponseModel.class fromJSONDictionary:responseDictionary error:&error];
        if (error) {
            NSLog(@"Error in conversion %@",[error description]);
        }
        
        NSLog(@"%@",list);
        success(list);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        failure(error);
    }];
}

-(NSURLSessionDataTask *)getTaxonomiesForStore:(NSString *)store WithSuccess:(void (^)(TaxonomyListResponseModel *responseModel))success failure:(void (^)(NSError *error))failure {
    
    User *user = [User savedUser];
    
    NSString *kStoreURL = [NSString stringWithFormat:@"http://%@",store];
    SessionManager *manager = [[SessionManager alloc]initWithBaseURL:[NSURL URLWithString:kStoreURL]];
    
    if (user.access_token == nil) {
        
        NSLog(@"User not Logged in, Returned nil");
        return nil;
    } else {
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc]init];
        [parametersWithKey setObject:user.access_token forKey:@"token"];
        
        return [manager GET:kTaxonomiesListPath parameters:parametersWithKey success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSError *error;
            
            TaxonomyListResponseModel *list = [MTLJSONAdapter modelOfClass:TaxonomyListResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"%@",[error localizedDescription]);
            }
            success(list);
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            failure(error);
        }];
    }
}


-(NSURLSessionDataTask *)getMyOrdersWithSuccess:(void (^)(MyOrdersResponseModel *))success failure:(void (^)(NSError *))failure {
    User *user = [User savedUser];
    
    if (user.access_token == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] init];
        [parametersWithKey setObject:user.access_token forKey:@"token"];
        
        return [self GET:kMyOrdersPath parameters:parametersWithKey success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSError *error;
            
            MyOrdersResponseModel *myOrders = [MTLJSONAdapter modelOfClass:[MyOrdersResponseModel class] fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            success(myOrders);
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            failure(error);
        }];
    }
}



@end
