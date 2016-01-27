//
//  APIManager.m
//  Chemist Plus
//
//  Created by adverto on 05/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "APIManager.h"
#import "User.h"


@implementation APIManager {
    BOOL _isDone;
    BOOL _isIterating;
    
}

-(NSURLSessionDataTask *)getStoresWithRequestModel:(ListingRequestModel *)requestModel success:(void (^)(StoreListResponseModel *))success failure:(void (^)(NSError *error, BOOL loginFailure))failure {
    
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
        
        NSInteger stats_code = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
        
        if (stats_code == 401) {
            [self retryGetStoresWithRequestModel:requestModel success:^(StoreListResponseModel *retried_success) {
                // send the success list
                success(retried_success);
                
            } failure:^(NSError *retried_error, BOOL loginFailure) {
                // send the failure error;
                failure(retried_error, loginFailure);
                
            }];
        }
        else
            failure(error, NO);
        
    }];
}



-(NSURLSessionDataTask *)getDoctorListingsWithRequestModel:(ListingRequestModel *)requestModel success:(void (^) (DoctorResponseModel *))success failure:(void (^)(NSError *error, BOOL loginFailure))failure {
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:requestModel error:nil];
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    
    if (_isIterating) {
        User *user = [User savedUser];
        
        if (user.access_token == nil) {
            NSLog(@"User not logged in");
            
            failure(nil, YES);
            
        }
        else
            [parametersWithKey setObject:user.access_token forKey:@"token"];
    }
    else {
        [parametersWithKey setObject:kStoreTokenKey forKey:@"token"];
    }
    
    if (_isDone) {
        return nil;
    }
    else {
        
        return [self GET:kDoctorsListPath parameters:parametersWithKey success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSLog(@"Response = %@",responseDictionary);
            
            NSError *error;
            DoctorResponseModel *list = [MTLJSONAdapter modelOfClass:DoctorResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"Error in conversion %@",[error description]);
            }
            
            NSLog(@"%@",list);
            success(list);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSInteger stats_code = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
            
            if (stats_code == 401) {
                _isIterating = YES;
                [self getDoctorListingsWithRequestModel:requestModel success:^(DoctorResponseModel *response) {
                    
                    _isDone = YES;
                    success(response);
                    
                    
                } failure:^(NSError *error, BOOL loginFailure) {
                    
                    _isDone = YES;
                    failure(error, loginFailure);
                }];
            }
            else
                failure(error, NO);
        }];
    }
    
    
}


-(void)retryGetStoresWithRequestModel:(ListingRequestModel *)requestModel success:(void (^)(StoreListResponseModel *))success failure:(void (^)(NSError *error, BOOL loginFailure))failure {
    
    
    User *user = [User savedUser];
    
    if (user.access_token == nil) {
        NSLog(@"User not logged in");
        
        failure(nil, YES);
        
    } else {
        
        NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:requestModel error:nil];
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        [parametersWithKey setObject:user.access_token forKey:@"token"];
        
        
        [self GET:kStoresListPath parameters:parametersWithKey progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"%@",downloadProgress.localizedDescription);
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSLog(@"Response = %@",responseDictionary);
            
            NSError *error;
            StoreListResponseModel *list = [MTLJSONAdapter modelOfClass:StoreListResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"Error in conversion %@",[error description]);
            }
            
            success(list);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error, NO);
        }];
        
    }
    
    
    
}




-(NSURLSessionDataTask *)getTaxonomiesForStore:(NSString *)store WithSuccess:(void (^)(TaxonomyListResponseModel *responseModel))success failure:(void (^)(NSError *error))failure {
    
    
    NSString *kStoreURL = [NSString stringWithFormat:@"http://%@",store];
    SessionManager *manager = [[SessionManager alloc]initWithBaseURL:[NSURL URLWithString:kStoreURL]];
    
    
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc]init];
    [parametersWithKey setObject:kStoreTokenKey forKey:@"token"];
    
    return [manager GET:kTaxonomiesListPath parameters:parametersWithKey success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSError *error;
        
        TaxonomyListResponseModel *list = [MTLJSONAdapter modelOfClass:TaxonomyListResponseModel.class fromJSONDictionary:responseDictionary error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        success(list);
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
//        NSInteger status_code = [[[error userInfo] valueForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
//        
//        if (status_code == 401) {
//            [self getTaxonomiesForStore:store WithSuccess:^(TaxonomyListResponseModel *responseModel) {
//                success(responseModel);
//            } failure:^(NSError *error) {
//                failure(error);
//            }];
//        }
        
        failure(error);
    }];
    
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


-(NSURLSessionDataTask *)putEditedAddressOfStore:(NSString *)storeURL ofPath:(NSString *)path Parameters:(NSDictionary *)parameters WithSuccess:(void (^)(NSString *response))success failure:(void (^)(NSError *error))failure {
    
    NSString *kStoreURL = [NSString stringWithFormat:@"http://%@",storeURL];
    SessionManager *manager = [[SessionManager alloc]initWithBaseURL:[NSURL URLWithString:kStoreURL]];
    
    User *user = [User savedUser];
    
    if (user.access_token == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] init];
        [parametersWithKey addEntriesFromDictionary:parameters];
        [parametersWithKey setObject:user.access_token forKey:@"token"];
        
        NSLog(@"%@", path);
        NSLog(@"%@", parametersWithKey);
        
        return [manager PUT:path parameters:parametersWithKey success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSLog(@"%@", responseObject);
            
            success(@"YES");
            
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            failure(error);
        }];
        
    }
    
}



-(NSURLSessionDataTask *)getStatesWithSuccess:(void (^)(NSArray *states))success failure:(void (^)(NSError *error))failure {
    
    
    User *user = [User savedUser];
    
    if (user.access_token == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        
        NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
        [parameter setObject:user.access_token forKey:@"token"];
        [parameter setValue:@"50" forKey:@"per_page"];
        
        
        return [self GET:kStatesPathOfIndia parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            /* get all data */
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            
            NSArray *array = [responseDictionary objectForKey:@"states"];
            
            success(array);
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            failure(error);
        }];
    }
}


-(NSURLSessionDataTask *)putNewAddressForPath:(NSString *)path andParameter:(NSDictionary *)addressParameter WithSuccess:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    
    
    User *user = [User savedUser];
    
    if (user.access_token == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        
        NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
        [parameter addEntriesFromDictionary:addressParameter];
        [parameter setObject:user.access_token forKey:@"token"];
        
        NSLog(@"%@", parameter);
        
        
        return [self PUT:path parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSLog(@"%@",responseObject);
            
            success(responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            failure(error);
        }];
    }
    
}








@end
