//
//  NAPIManager.h
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NSessionManager.h"
#import "MainCategoriesResponseModel.h"
#import "ListingResponseModel.h"
#import "EntityDetailsResponseModel.h"
#import "TimeSlotResponseModel.h"
#import "StateCityResponseModel.h"

@interface NAPIManager : NSessionManager

-(NSURLSessionDataTask *)mainCategoriesWithSuccess:(void (^)(MainCategoriesResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getListingsWithRequestModel:(ListingRequestModel *)request success:(void (^)(ListingResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getEntityDetailsWithRequest:(NSDictionary *)parameter success:(void (^)(EntityDetailsResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getTimeSlotsWithRequest:(NSDictionary *)parameter success:(void (^)(TimeSlotResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)postBookingWithRequest:(NSString *)parameter success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getTaxonomiesWithRequest:(NSDictionary *)parameter WithSuccess:(void (^)(TaxonomyListResponseModel *responseModel))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getPaymentOptionsWithSuccess:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getNeediatorStatesCityWithSuccess:(void (^)(StateCityResponseModel *states))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getAllAddressesWithSuccess:(void (^)(NSArray *address))success failure:(void (^)(NSError *error)) failure;
-(NSURLSessionDataTask *)deleteAddress:(NSString *)addressID withSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)uploadImages:(NSArray *)images withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL))success failure:(void (^)(NSError *error))failure;

@end
