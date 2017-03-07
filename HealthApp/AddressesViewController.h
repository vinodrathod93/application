//
//  AddressesViewController.h
//  Chemist Plus
//
//  Created by adverto on 20/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditAddressViewController.h"


@protocol AddressDelegate <NSObject>

-(void)deliverableAddressDidSelect:(NSDictionary *)address;

@end

@interface AddressesViewController : UITableViewController<EditedAddressDelegate>


@property (nonatomic, strong) NSString      *order_id;
@property (nonatomic, assign) BOOL          isGettingOrder;
@property (nonatomic, strong) NSArray       *addressesArray;
@property (nonatomic, strong) NSDictionary  *user_data;

@property (nonatomic, weak) id <AddressDelegate> delegate;
@end
