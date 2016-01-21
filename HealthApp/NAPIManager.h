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

@interface NAPIManager : NSessionManager

-(NSURLSessionDataTask *)mainCategoriesWithSuccess:(void (^)(MainCategoriesResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getListingsWithRequestModel:(ListingRequestModel *)request success:(void (^)(ListingResponseModel *response))success failure:(void (^)(NSError *error))failure;
-(NSURLSessionDataTask *)getEntityDetailsWithRequest:(NSDictionary *)parameter success:(void (^)(EntityDetailsResponseModel *response))success failure:(void (^)(NSError *error))failure;

@end
