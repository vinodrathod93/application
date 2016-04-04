//
//  InterfaceController.m
//  Neediator-AppleWatch Extension
//
//  Created by adverto on 04/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "InterfaceController.h"
#import "ListingRow.h"
//#import "NAPIManager.h"
//#import "ListingRequestModel.h"
//#import "ListingResponseModel.h"
//#import "ListingModel.h"
//#import "Location.h"
//#import "NeediatorUtitity.h"
//#import "NeediatorConstants.h"
//#import "User.h"



@interface InterfaceController()
{
    NSArray *_listingArray;
    NSArray *_categoriesArray;
}
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    _categoriesArray = @[@"Chemist", @"General Stores", @"Doctors", @"Eateries", @"Salon", @"Utility Services"];
    [self setupTableView];
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

-(void)setupTableView {
    
//    Location *location_store = [Location savedLocation];
//    User *user          = [User savedUser];
//    
//    
//    ListingRequestModel *requestModel = [ListingRequestModel new];
//    requestModel.latitude             = location_store.latitude;
//    requestModel.longitude            = location_store.longitude;
//    requestModel.category_id          = [NeediatorUtitity savedDataForKey:kSAVE_CAT_ID];
//    requestModel.subcategory_id       = @"";
//    requestModel.page                 = @"1";
//    requestModel.sort_id              = @"1";
//    requestModel.sortOrder_id         = @"1";
//    requestModel.is24Hrs              = @"";
//    requestModel.hasOffers            = @"";
//    requestModel.minDelivery_id       = @"";
//    requestModel.ratings_id           = @"";
//    requestModel.user_id              = (user.userID != nil) ? user.userID : @"";

//    [[NAPIManager sharedManager] getListingsWithRequestModel:requestModel success:^(ListingResponseModel *response) {
//        _listingArray = response.records;
//        [self.tableview setNumberOfRows:_listingArray.count withRowType:@"listingRow"];
//        
//        for (int i=0; i< 10; i++) {
//            ListingRow *row = [self.tableview rowControllerAtIndex:i];
//            
//            ListingModel *model = _listingArray[i];
//            
//            [row.storenameLabel setText:model.name.capitalizedString];
//        }
//        
//    } failure:^(NSError *error) {
//
//        
//        NSLog(@"Error %@", [error localizedDescription]);
//    }];
    
    
    for (int i=0; i< _categoriesArray.count; i++) {
        ListingRow *row = [self.tableview rowControllerAtIndex:i];

//        ListingModel *model = _listingArray[i];

        [row.storenameLabel setText:_categoriesArray[i]];
    }
    
    [self.tableview setNumberOfRows:10 withRowType:@"listingRow"];
    
    
}





@end



