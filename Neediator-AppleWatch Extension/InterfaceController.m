//
//  InterfaceController.m
//  Neediator-AppleWatch Extension
//
//  Created by adverto on 04/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "InterfaceController.h"
#import "CategoryRow.h"
//#import "NAPIManager.h"
//#import "ListingResponseModel.h"
//#import "ListingModel.h"
//#import "Location.h"
//#import "NeediatorUtitity.h"
//#import "NeediatorConstants.h"
//#import "User.h"

@class NAPIManager;
@class NeediatorUtitity;

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
    
    /*
    
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
    
    [parameter setObject:location_store.latitude forKey:@"latitude"];
    [parameter setObject:location_store.longitude forKey:@"longitude"];
    [parameter setObject:[NeediatorUtitity savedDataForKey:kSAVE_SEC_ID] forKey:@"catid"];
    [parameter setObject:@"" forKey:@"subcatid"];
    [parameter setObject:@"1" forKey:@"page"];
    [parameter setObject:@"" forKey:@"type_id"];
    [parameter setObject:@"" forKey:@"sort_type"];
    [parameter setObject:@"" forKey:@"twenty_four_hr"];
    [parameter setObject:@"" forKey:@"offer"];
    [parameter setObject:@"" forKey:@"minimum_delivery_id"];
    [parameter setObject:@"" forKey:@"ratings_id"];
    
    
    if (user.userID != nil) {
        [parameter setObject:user.userID forKey:@"userid"];
    }
    else
        [parameter setObject:@"" forKey:@"userid"];
    
    NSDictionary *dicParameter = (NSDictionary *)parameter;
    
    
    
    
    
    */
    
    
    
    
    

//    [[NAPIManager sharedManager] getListingsWithRequestModel:dicParameter success:^(ListingResponseModel *response) {
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
    
    [self.tableview setNumberOfRows:_categoriesArray.count withRowType:@"categoryRow"];
    
    for (int i=0; i< _categoriesArray.count; i++) {
        CategoryRow *row = [self.tableview rowControllerAtIndex:i];

//        ListingModel *model = _listingArray[i];

        [row.categorynameLabel setText:_categoriesArray[i]];
    }
    
    
    
    
}





@end



