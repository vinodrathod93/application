//
//  NeediatorConstants.h
//  Neediator
//
//  Created by adverto on 26/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#ifndef NeediatorConstants_h
#define NeediatorConstants_h


#endif /* NeediatorConstants_h */

/* Stores VC */
#define kStoresNoStoresTag 10
#define kStoresConnectionViewTag 11


/* Cart VC */
#define kCartConnectionErrorViewTag 20
#define kCartEmptyViewTag 21
#define kCartBaseURL @"http://www.elnuur.com"



#define GET_STATES_URL @"http://chemistplus.in/getStates.php"
#define GET_CITIES_URL @"http://chemistplus.in/getCities.php"
#define VERIFY_PINCODE_URL @"http://chemistplus.in/verifyPincode.php"


/* API Manager */
static NSString *const kStoresListPath = @"/api/stores";
static NSString *const kTaxonomiesListPath = @"/api/taxonomies";
static NSString *const kMyOrdersPath       = @"/api/orders/mine";
static NSString *const kStatesPathOfIndia  = @"/api/countries/105/states";

static NSString *const kDoctorsListPath = @"/api/doctors";