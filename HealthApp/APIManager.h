//
//  APIManager.h
//  Chemist Plus
//
//  Created by adverto on 05/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "SessionManager.h"
#import "StoreListRequestModel.h"
#import "StoreListResponseModel.h"
#import "TaxonomyListResponseModel.h"
#import "MyOrdersResponseModel.h"

@interface APIManager : SessionManager

-(NSURLSessionDataTask *)getStoresWithRequestModel:(StoreListRequestModel *)requestModel success:(void (^)(StoreListResponseModel *))success failure:(void (^)(NSError *error, BOOL loginFailure))failure;
-(NSURLSessionDataTask *)getTaxonomiesForStore:(NSString *)store WithSuccess:(void (^)(TaxonomyListResponseModel *responseModel))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getMyOrdersWithSuccess:(void (^)(MyOrdersResponseModel *))success failure:(void (^)(NSError *))failure;
-(NSURLSessionDataTask *)putEditedAddressOfStore:(NSString *)storeURL ofPath:(NSString *)path Parameters:(NSDictionary *)parameters WithSuccess:(void (^)(NSString *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getStatesWithSuccess:(void (^)(NSArray *states))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)putNewAddressForPath:(NSString *)path andParameter:(NSDictionary *)addressParameter WithSuccess:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
@end
