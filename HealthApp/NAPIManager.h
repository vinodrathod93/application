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
#import "FavouritesResponseModel.h"
#import "MyOrderByStatus.h"
#import "MyBookingByStatus.h"
#import "MyBookingResponseModel.h"

@interface NAPIManager : NSessionManager

-(NSURLSessionDataTask *)mainCategoriesWithSuccess:(void (^)(MainCategoriesResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getCategoriesForSection:(NSString *)sectionID WithSuccess:(void (^)(NSArray *categories))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getListingsWithRequestModel:(id)request success:(void (^)(NSArray *listings, NSArray *banners))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getStoreDetails:(NSDictionary *)parameter WithSuccess:(void (^)(NSArray *storeData, NSArray *storeImages, NSArray *offers, NSArray *storeAddress))success failure:(void (^)(NSError *error))failure;


-(NSURLSessionDataTask *)getEntityDetailsWithRequest:(NSDictionary *)parameter success:(void (^)(EntityDetailsResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getTimeSlotsWithRequest:(NSDictionary *)parameter success:(void (^)(TimeSlotResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)postBookingWithRequest:(NSString *)parameter success:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;

-(NSURLSessionDataTask *)getPaymentOptionsWithSuccess:(void (^)(NSDictionary *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getNeediatorStatesCityWithSuccess:(void (^)(StateCityResponseModel *states))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getAllAddressesWithSuccess:(void (^)(NSArray *address))success failure:(void (^)(NSError *error)) failure;
-(NSURLSessionDataTask *)deleteAddress:(NSString *)addressID withSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *error))failure;

-(NSURLSessionDataTask *)uploadImagesWithData:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL success, NSDictionary *response))success failure:(void (^)(NSError *error))failure;

-(NSURLSessionDataTask *)getSearchedProductsWithData:(NSDictionary *)data success:(void (^)(NSArray *products))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)postFavouritesWithData:(NSDictionary *)data success:(void (^)(BOOL))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)postlikeDislikeWithData:(NSDictionary *)data success:(void (^)(NSDictionary *likeDislikes))success failure:(void (^)(NSError *error))failure;

-(NSURLSessionDataTask *)getMyFavouritesListingWithSuccess:(void(^)(FavouritesResponseModel *))success failure:(void (^)(NSError *))failure;
-(NSURLSessionDataTask *)deleteFavouriteStore:(NSString *)favouriteID WithSuccess:(void(^)(BOOL))success failure:(void (^)(NSError *))failure;
-(NSURLSessionDataTask *)updateUserProfile:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL success, NSDictionary *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)searchLocations:(NSString *)keyword withSuccess:(void (^)(BOOL success, NSArray *predictions))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getCoordinatesOf:(NSString *)address withSuccess:(void (^)(BOOL success, NSDictionary *location))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)searchCategoriesFor:(NSString *)keyword withSuccess:(void (^)(BOOL success, NSArray *predictions))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)searchStoresFor:(NSString *)keyword withSuccess:(void (^)(BOOL success, NSArray *predictions))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)searchUniveralProductsWithData:(NSString *)keyword success:(void (^)(NSArray *products))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)requestStoreByCode:(NSString *)keyword success:(void (^)(NSDictionary *storeDetails))success failure:(void (^)(NSError *error))failure;

-(NSURLSessionDataTask *)getMyOrdersListingWithSuccess:(void(^)(MyOrdersResponseModel *))success failure:(void (^)(NSError *))failure;

-(NSURLSessionDataTask *)getMyBookingListingWithSuccess:(void(^)(MyBookingResponseModel *))success failure:(void (^)(NSError *))failure;









-(NSURLSessionDataTask *)getMyOrdersListingByStatus:(MyOrderByStatus *)request success:(void (^)(MyOrdersResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getMyBookingListingByStatus:(MyBookingByStatus *)request success:(void (^)(MyBookingResponseModel *response))success failure:(void (^)(NSError *error))failure;


-(NSURLSessionDataTask *)uploadReportsWithData:(NSDictionary *)data withHUD:(MBProgressHUD *)hud success:(void (^)(BOOL success, NSDictionary *response))success failure:(void (^)(NSError *error))failure;











@end
