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
    
    
    return [self GET:kMAIN_SECTIONS_PATH parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Getting main Categories %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            
    {
        // Success Get promotions array & categories array
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSDictionary *tempResponse  =   @{
                                          @"Section" : response,
                                          @"promotions" :   @[]
                                          };
        
        NSError *responseError;
        MainCategoriesResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[MainCategoriesResponseModel class] fromJSONDictionary:tempResponse error:&responseError];
        
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


-(NSURLSessionDataTask *)getCategoriesForSection:(NSString *)sectionID WithSuccess:(void (^)(NSArray *categories))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameter =   @{
                                  @"sectionId"  :   sectionID
                                  };
    
    return [self GET:kSECTION_CATEGORIES_PATH parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Getting main Categories %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            
            {
                // Success Get promotions array & categories array
                
                NSArray *categories = (NSArray *)responseObject;
                
                success(categories);
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                // Failure send error to main view
                
                failure(error);
            }];
    
}



-(NSURLSessionDataTask *)getListingsWithRequestModel:(id)request success:(void (^)(NSArray *listings, NSArray *banners))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameters;
    
    if ([request isKindOfClass:[ListingRequestModel class]])
    {
        parameters = [MTLJSONAdapter JSONDictionaryFromModel:request error:nil];
    }
    else if ([request isKindOfClass:[NSDictionary class]])
        parameters = request;
    
    NSLog(@"Parameters %@", parameters);
    
    
    NSDictionary *tempParameter     =   @{
                                          @"sectionId"      : setValidValue(parameters[@"Sectionid"]),
                                          @"categoryId"     : setValidValue(parameters[@"Categoryid"]),
                                          @"subCategoryId"  : setValidValue(parameters[@""])
                                          };
    
    
    return [self GET:kLISTING_PATH parameters:tempParameter progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSLog(@"Getting Services %@", downloadProgress.localizedDescription);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
        
        NSDictionary *response = (NSDictionary *)responseObject;
        
        NSLog(@"%@", response);
        /*
        NSError *responseError;
        ListingResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[ListingResponseModel class] fromJSONDictionary:response error:&responseError];
        
        if (responseError)
        {
            NSLog(@"Error in Listing Response: %@", responseError.localizedFailureReason);
            
            failure(responseError);
        }
        else
            success(responseModel);
        */
                
        
                NSArray *listings   =   isValid(response[@"storelist"]) ? response[@"storelist"] : @[];
                NSArray *banners    =   isValid(response[@"advBannerImage"]) ? response[@"advBannerImage"] : @[];
                
                success(listings, banners);
                
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"Error : %@ & %@", error.localizedFailureReason, error.localizedDescription);
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


-(NSURLSessionDataTask *)getStoreDetails:(NSDictionary *)parameter WithSuccess:(void (^)(NSArray *storeData, NSArray *storeImages, NSArray *offers, NSArray *storeAddress))success failure:(void (^)(NSError *error))failure {
    
    
    return [self GET:kSTORE_DETAILS_PATH parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"GETTING store details %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        
        
        NSArray *storeData =    responseDictionary[@"storedata"];
        NSArray *storeImages    =   responseDictionary[@"storeimages"];
        NSArray *offers         =   responseDictionary[@"offers"];
        NSDictionary *address   =   (responseDictionary[@"addressdetails"][0]);
        
        
        success(storeData, storeImages, offers, address);
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


-(NSURLSessionDataTask *)getNeediatorStatesCityWithSuccess:(void (^)(StateCityResponseModel *states))success failure:(void (^)(NSError *error))failure
{
    
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
    
    NSLog(@"%@",address_parameter);
    
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



-(NSURLSessionDataTask *)uploadImagesWithData:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL success, NSDictionary *response))success failure:(void (^)(NSError *error))failure
{
   
    User *user = [User savedUser];
    
    NSLog(@"%@", user.addresses);
    
    NSDictionary *object = @{
                           @"store_id"          : [NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],
                           @"Section_id"        : [NeediatorUtitity savedDataForKey:kSAVE_SEC_ID],
                           @"user_id"           : user.userID,
                           @"address_id"        : data[@"addressID"],
                           @"delivery_type"     : data[@"deliveryID"],
                           @"payment_id"        : @"1",
                           @"preffered_time"    : data[@"dateTime"],
                           @"order_amount"      : @"1",
                           @"timeslotfrom"      : data[@"timeslotfrom"],
                           @"timeslotto"        : data[@"timeslotto"],
                           @"accountcode"       : data[@"accountcode"],
                           @"comments"          : data[@"comments"],
                           @"addresstype"       : data[@"addresstype"],
                           @"images"            : data[@"images"]
                           };
    
    
    NSLog(@"%@",object);
    
    NSError *error;
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *json_string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    
    NSLog(@"JSON String------>%@",json_string);
    
    
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


-(NSURLSessionDataTask *)uploadReportsWithData:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL, NSDictionary *))success failure:(void (^)(NSError *))failure
{
    
    User *user = [User savedUser];
    
    NSLog(@"%@", user.addresses);
    
    NSDictionary *object = @{
                             @"store_id"                : [NeediatorUtitity savedDataForKey:kSAVE_STORE_ID],
                             @"Section_id"              : [NeediatorUtitity savedDataForKey:kSAVE_SEC_ID],
                             @"user_id"                 : user.userID,
                             @"lastcommunicationdate"   : data[@"lastcommunicationdate"],
                             @"images"                  : data[@"images"]
                             };
    
    
    NSLog(@"%@",object);
    
    NSError *error;
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *json_string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    
    NSLog(@"JSON String------>%@",json_string);
    
    
    NSDictionary *parameter = @{
                                @"json": json_string
                                };
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    return [self POST:kUPLOAD_REPORTS_PATH parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
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
    }
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response %@", responseObject);
        
        NSString *status = responseObject[@"status"];
        
        if ([status isEqualToString:@"Add"]) {
            success(YES);
        }
        else
            success(NO);
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

-(NSURLSessionDataTask *)postlikeDislikeWithData:(NSDictionary *)data success:(void (^)(NSDictionary *likeDislikes))success failure:(void (^)(NSError *error))failure {
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    
    return [self POST:kADD_TO_LIKEDISLIKE_PATH parameters:data progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"Adding to LikeUnlike %@", uploadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response %@", responseObject);
        
        
        NSString *status = responseObject[@"test"];
        
        
        if ([status isEqualToString:@"success"]) {
            
            NSArray *responseArray = responseObject[@"LikeUnlike"];
            
            if(!(responseArray.count==0))
            {
                        success(responseArray[0]);
                
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Message" message:@"Already Liked" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                
                [alert show];
                
            }
        }
        else
        {
           success(@{});
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)getMyOrdersListingWithSuccess:(void(^)(MyOrdersResponseModel *))success failure:(void (^)(NSError *))failure
{
    
    User *user = [User savedUser];
    
    if (user.userID == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        
        
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] init];
        [parametersWithKey setObject:user.userID forKey:@"user_id"];
        
        return [self GET:kMY_ORDERS_PATH parameters:parametersWithKey progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"Getting myorder %@", downloadProgress.localizedDescription);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSMutableDictionary *responseDictionary = (NSMutableDictionary *)responseObject;
            NSError *error;
            
            MyOrdersResponseModel *myOrders = [MTLJSONAdapter modelOfClass:[MyOrdersResponseModel class] fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            success(myOrders);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
        
    }
}


-(NSURLSessionDataTask *)getMyOrdersListingByStatus:(MyOrderByStatus *)request success:(void (^)(MyOrdersResponseModel *))success failure:(void (^)(NSError *))failure
{
    User *user = [User savedUser];
    
    if (user.userID == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else
    {
        NSDictionary *parameters;
        if ([request isKindOfClass:[MyOrderByStatus class]])
        {
            parameters = [MTLJSONAdapter JSONDictionaryFromModel:request error:nil];
        }
        else if ([request isKindOfClass:[NSDictionary class]])
            parameters = request;
        
        NSLog(@"Parameters %@", parameters);
        
        return [self GET:kMY_ORDERS_PATH_BY_STATUS parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
            NSLog(@"Getting Services %@", downloadProgress.localizedDescription);
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                {
                    NSDictionary *response = (NSDictionary *)responseObject;
                    NSLog(@"%@", response);
                    NSError *responseError;
                    MyOrdersResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[MyOrdersResponseModel class] fromJSONDictionary:response error:&responseError];
                    
                    if (responseError)
                    {
                        NSLog(@"Error in Listing Response: %@", responseError.localizedFailureReason);
                        failure(responseError);
                    }
                    else
                        success(responseModel);
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    NSLog(@"Error : %@ & %@", error.localizedFailureReason, error.localizedDescription);
                    failure(error);
                }];
}
   }






-(NSURLSessionDataTask *)getMyBookingListingWithSuccess:(void(^)(MyBookingResponseModel *))success failure:(void (^)(NSError *))failure {
    
    
    User *user = [User savedUser];
    
    if (user.userID == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        
        
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] init];
        [parametersWithKey setObject:user.userID forKey:@"userid"];
        
        return [self GET:kMY_BOOKING_PATH parameters:parametersWithKey progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"Getting myorder %@", downloadProgress.localizedDescription);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSError *error;
            
            MyBookingResponseModel *myOrders = [MTLJSONAdapter modelOfClass:[MyBookingResponseModel class] fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            success(myOrders);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
        
    }
}







-(NSURLSessionDataTask *)getMyBookingListingByStatus:(MyBookingByStatus *)request success:(void (^)(MyBookingResponseModel *))success failure:(void (^)(NSError *))failure
{
    
    
    User *user = [User savedUser];
    
    if (user.userID == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else
    {
        NSDictionary *parameters;
        if ([request isKindOfClass:[MyBookingByStatus class]])
        {
            parameters = [MTLJSONAdapter JSONDictionaryFromModel:request error:nil];
        }
        else if ([request isKindOfClass:[NSDictionary class]])
            parameters = request;
        
        NSLog(@"Parameters %@", parameters);
        
        return [self GET:kMY_BOOKING_BY_STATUS parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
            NSLog(@"Getting Services %@", downloadProgress.localizedDescription);
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
                {
                    NSDictionary *response = (NSDictionary *)responseObject;
                    NSLog(@"%@", response);
                    NSError *responseError;
                MyBookingResponseModel *responseModel = [MTLJSONAdapter modelOfClass:[MyBookingResponseModel class] fromJSONDictionary:response error:&responseError];
                    
                    if (responseError)
                    {
                        NSLog(@"Error in Listing Response: %@", responseError.localizedFailureReason);
                        failure(responseError);
                    }
                    else
                        success(responseModel);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    NSLog(@"Error : %@ & %@", error.localizedFailureReason, error.localizedDescription);
                    failure(error);
                }];
    }
}











-(NSURLSessionDataTask *)getMyFavouritesListingWithSuccess:(void(^)(FavouritesResponseModel *))success failure:(void (^)(NSError *))failure {
    
    User *user = [User savedUser];
    
    if (user.userID == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] init];
        [parametersWithKey setObject:user.userID forKey:@"userid"];
        
        
        return [self GET:kMY_FAVOURITES_PATH parameters:parametersWithKey progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"Getting Favourites %@", downloadProgress.localizedDescription);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            NSDictionary *responseDictionary = (NSDictionary *)responseObject;
            NSError *error;
            
            FavouritesResponseModel *myfavourites = [MTLJSONAdapter modelOfClass:[FavouritesResponseModel class] fromJSONDictionary:responseDictionary error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            success(myfavourites);
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
        
    }
}


-(NSURLSessionDataTask *)deleteFavouriteStore:(NSString *)favouriteID WithSuccess:(void(^)(BOOL))success failure:(void (^)(NSError *))failure {
    
    User *user = [User savedUser];
    
    if (user.userID == nil) {
        NSLog(@"User not logged in");
        
        return nil;
    } else {
        NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] init];
        [parametersWithKey setObject:favouriteID forKey:@"id"];
        
        
        return [self GET:kDELETE_FAVOURITE_PATH parameters:parametersWithKey progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"Getting Favourites %@", downloadProgress.localizedDescription);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                success(YES);
            }
            else
                success(NO);
            
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
        }];
        
    }
}


-(NSURLSessionDataTask *)updateUserProfile:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL success, NSDictionary *response))success failure:(void (^)(NSError *error))failure {
    User *user = [User savedUser];
    
    
    NSDictionary *object = @{
                             @"first_name"      : data[@"firstname"],
                             @"last_name"       : data[@"lastname"],
                             @"userid"          : user.userID,
                             @"imageprofile"    : data[@"imageprofile"],
                             @"gender"          : data[@"gender"],
                             @"dob"             : data[@"dob"],
                             @"emailid"         : data[@"emailid"],
                             @"mobno"           : data[@"mobno"]
                             };
    
    
    NSError *error;
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *json_string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    
    
    NSDictionary *parameter = @{
                                @"json": json_string
                                };
    
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    return [self POST:kUPDATE_PROFILE_PATH parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress)
            {
        NSLog(@"Profile Image Uploading progess %@", uploadProgress.localizedDescription);
        
        hud.progress = uploadProgress.fractionCompleted;
        
    }
        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        NSLog(@"Response = %@",responseObject);
        
        success(YES,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}



-(NSURLSessionDataTask *)searchLocations:(NSString *)keyword withSuccess:(void (^)(BOOL success, NSArray *predictions))success failure:(void (^)(NSError *error))failure
{
    
    NSString *urlstring = [NSString stringWithFormat:@"%@&key=%@&input=%@", kAUTOCOMPLETE_LOCATION, kGoogleAPIServerKey,keyword];
    
    NSString *encodedString = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [self GET:encodedString  parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Location autocomplete progess %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // send locations
        
        NSArray *predictionArray = responseObject[@"predictions"];
        
        success(YES, predictionArray);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)getCoordinatesOf:(NSString *)address withSuccess:(void (^)(BOOL success, NSDictionary *location))success failure:(void (^)(NSError *error))failure {
    NSString *urlstring = [NSString stringWithFormat:@"%@&address=%@", kGOOGLE_GEOCODE_URL, address];
    
    NSString *encodedURLString = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [self GET:encodedURLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Coordinate progess %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *results = responseObject[@"results"];
        if (results.count > 0) {
            NSDictionary *firstResult = results[0];
            
            NSDictionary *geometry = firstResult[@"geometry"];
            
            success(YES, geometry[@"location"]);
        }
        else {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Results Found in Google API Geocode" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"NORESULTS" code:123 userInfo:userInfo];
            failure(error);
        }
            
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)searchCategoriesFor:(NSString *)keyword withSuccess:(void (^)(BOOL success, NSArray *predictions))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameter = @{
                                @"search" : keyword
                                };
    
    return [self GET:kAUTOCOMPLETE_SEARCH_CATEGORIES  parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Categories autocomplete progess %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // send locations
        
//        NSArray *predictionArray = responseObject[@"Categories"];
        NSArray *predictionArray = responseObject[@"Section"];

        NSLog(@"Prediction Array Is %@",predictionArray);
        
        success(YES, predictionArray);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

-(NSURLSessionDataTask *)searchStoresFor:(NSString *)keyword withSuccess:(void (^)(BOOL success, NSArray *predictions))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameter = @{
                                @"store_name" : keyword
                                };
    
    return [self GET:kAUTOCOMPLETE_SEARCH_STORES  parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Categories autocomplete progess %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // send locations
        
        NSArray *predictionArray = responseObject[@"stores"];
        
        success(YES, predictionArray);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)searchUniveralProductsWithData:(NSString *)keyword success:(void (^)(NSArray *products))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameter = @{
                                @"productname" : keyword
                                };
    
    return [self GET:kAUTOCOMPLETE_SEARCH_UNIVERSAL_PRODUCT parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Searching Universal product %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response %@", responseObject);
        
        NSArray *products = [responseObject objectForKey:@"Products"];
        
        success(products);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}


-(NSURLSessionDataTask *)requestStoreByCode:(NSString *)keyword success:(void (^)(NSDictionary *storeDetails))success failure:(void (^)(NSError *error))failure {
    
    NSDictionary *parameter = @{
                                @"code" : keyword,
                                @"sectionid" :@"1"
                                };
    
    return [self GET:kSTORE_DETAILS_BY_CODE_PATH parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Getting Store Details by Code %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"Response %@", responseObject);
        
        
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}



@end
