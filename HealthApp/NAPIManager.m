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
        NSLog(@"Getting main Categories %@", downloadProgress.localizedDescription);
        
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



-(NSURLSessionDataTask *)getListingsWithRequestModel:(id)request success:(void (^)(ListingResponseModel *response))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters;
    
    if ([request isKindOfClass:[ListingRequestModel class]]) {
        parameters = [MTLJSONAdapter JSONDictionaryFromModel:request error:nil];
    }
    else if ([request isKindOfClass:[NSDictionary class]])
        parameters = request;
    
    NSLog(@"Parameters %@", parameters);
    
    
    return [self GET:kLISTING_PATH parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"Getting Services %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSLog(@"%@", response);
        
        NSError *responseError;
        ListingResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[ListingResponseModel class] fromJSONDictionary:response error:&responseError];
        
        if (responseError) {
            NSLog(@"Error in Listing Response: %@", responseError.localizedFailureReason);
            
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
        NSLog(@"Getting Details %@", downloadProgress.localizedDescription);
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


-(NSURLSessionDataTask *)getTimeSlotsWithRequest:(NSDictionary *)parameter success:(void (^)(TimeSlotResponseModel *response))success failure:(void (^)(NSError *error))failure {
    
    return [self GET:kTIME_SLOTS_PATH parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Getting Timeslots %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSLog(@"%@", response);
        
        NSError *responseError;
        TimeSlotResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[TimeSlotResponseModel class] fromJSONDictionary:response error:&responseError];
        
        if (responseError) {
            NSLog(@"Error in Details Response: %@", responseError.localizedDescription);
        }
        else
            success(responseModel);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)postBookingWithRequest:(NSString *)parameter success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    
    
    return [self POST:kBOOKING_PATH parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"Posting Book details %@", uploadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        NSDictionary *response = (NSDictionary *)responseObject;
        
        success(response);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)getTaxonomiesWithRequest:(NSDictionary *)parameter WithSuccess:(void (^)(TaxonomyListResponseModel *responseModel))success failure:(void (^)(NSError *error))failure {
    
    
    return [self GET:kSTORE_TAXONS_PATH parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"GETTING Taxons %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSError *error;
        
        NSLog(@"%@", responseDictionary);
        TaxonomyListResponseModel *list = [MTLJSONAdapter modelOfClass:TaxonomyListResponseModel.class fromJSONDictionary:responseDictionary error:&error];
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        success(list);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
}


-(NSURLSessionDataTask *)getPaymentOptionsWithSuccess:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    
    
    return [self GET:kPAYMENT_OPTIONS_PATH parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"GETTING Payment options %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSError *error;
        
        NSLog(@"%@", responseDictionary);
        
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
        success(responseDictionary);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
}


-(NSURLSessionDataTask *)getNeediatorStatesCityWithSuccess:(void (^)(StateCityResponseModel *states))success failure:(void (^)(NSError *error))failure {
    
    
    return [self GET:KSTATE_CITIES_PATH parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Getting States %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        NSError *error;
        StateCityResponseModel *states = [MTLJSONAdapter modelOfClass:StateCityResponseModel.class fromJSONDictionary:responseDictionary error:&error];
        
        success(states);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
        
}


-(NSURLSessionDataTask *)getAllAddressesWithSuccess:(void (^)(NSArray *address))success failure:(void (^)(NSError *error)) failure {
    User *user = [User savedUser];
    
    NSDictionary *address_parameter = [NSDictionary dictionaryWithObject:user.userID forKey:@"user_id"];
    
    return [self GET:KALL_ADDRESSES_PATH parameters:address_parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Getting Addresses = %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        if ([[responseDictionary objectForKey:@"address"] isKindOfClass:[NSArray class]]) {
            NSArray *addresses = [responseDictionary objectForKey:@"address"];
            
            success(addresses);
        }
        else {
            success(@[]);
        }
            
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

-(NSURLSessionDataTask *)deleteAddress:(NSString *)addressID withSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *error))failure {
    
//    NSString *parameter = [NSString stringWithFormat:@"id=%@",addressID];
    
    NSDictionary *parameter = @{
                                @"id" : addressID
                                };
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];

    return [self POST:kDELETE_ADDRESSES_PATH parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"Deleting address %@", uploadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        if([[responseDictionary objectForKey:@"deleteaddress"] isKindOfClass:[NSArray class]]) {
            success(YES);
        }
        else
            success(NO);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}



-(NSURLSessionDataTask *)uploadImagesWithData:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL success, NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    User *user = [User savedUser];
    
    NSLog(@"%@", user.addresses);
    
    NSDictionary *object = @{
                           @"store_id": [NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],
                           @"cat_id"    : [NeediatorUtitity savedDataForKey:kSAVE_CAT_ID],
                           @"user_id"   : user.userID,
                           @"addresss_id"   : data[@"addressID"],
                           @"delivery_type" : data[@"deliveryID"],
                           @"payment_id"    : @"1",
                           @"preffered_time": data[@"dateTime"],
                           @"order_amount"  : @"",
                           @"images"        : data[@"images"]
                           };
    
    
    NSError *error;
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *json_string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    
    
    NSDictionary *parameter = @{
                                @"json": json_string
                                };
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    return [self POST:kUPLOAD_PRESCRIPTION_PATH parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"Images Uploading progess %@", uploadProgress.localizedDescription);
        
        hud.progress = uploadProgress.fractionCompleted;
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response = %@", responseObject);
        
        success(YES, responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}



-(NSURLSessionDataTask *)getSearchedProductsWithData:(NSDictionary *)data success:(void (^)(NSArray *products))success failure:(void (^)(NSError *error))failure {
    
    return [self GET:kAUTOCOMPLETE_SEARCH_PRODUCT parameters:data progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Searching product %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response %@", responseObject);
        
        NSArray *products = [responseObject objectForKey:@"ProductStores"];
        
        success(products);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)postFavouritesWithData:(NSDictionary *)data success:(void (^)(BOOL))success failure:(void (^)(NSError *error))failure {
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    
    return [self POST:kADD_TO_FAVOURTIE_PATH parameters:data progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"Adding to Favourites %@", uploadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response %@", responseObject);
        
        NSString *status = responseObject[@"status"];
        
        if ([status isEqualToString:@"succes"]) {
            success(YES);
        }
        else
            success(NO);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}



@end
