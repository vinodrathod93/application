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


static NSString *const kAPP_ID = @"1073622324";

/* Home VC */

#define kHeaderViewHeight_Pad 316
#define kHeaderViewHeight_Phone 166


/* Stores VC */
#define kStoresNoStoresTag 10
#define kStoresConnectionViewTag 11


/* Taxon - Taxonomy VC */
#define kTaxonHeaderViewHeight_Pad 480
#define kTaxonHeaderViewHeight_Phone 240


/* Cart VC */
#define kCartConnectionErrorViewTag 20
#define kCartEmptyViewTag 21
#define kCartBaseURL @"http://www.elnuur.com"


/* Doctor VC */
#define kDoctorsConnectionViewTag 30
#define kDoctorsNoDoctorsTag 31

#define GET_STATES_URL @"http://chemistplus.in/getStates.php"
#define GET_CITIES_URL @"http://chemistplus.in/getCities.php"
#define VERIFY_PINCODE_URL @"http://chemistplus.in/verifyPincode.php"

/* Listing VC */
#define kListingConnectionViewTag 40
#define kListingNoListingTag 41

/* Store Taxon VC */

#define kStoreReviewsViewHeight 35
#define kStoreButtonOptionsViewHeight 65
#define kStoreUploadPrsViewHeight 90

#define kStoreImageViewCellHeight 240
#define kStoreTaxonTaxonomyCellHeight 50
#define kStoreOffersViewHeight 62


/* Spree API Manager */
static NSString *const kStoresListPath = @"/api/stores";
static NSString *const kTaxonomiesListPath = @"/api/taxonomies";
static NSString *const kMyOrdersPath       = @"/api/orders/mine";
static NSString *const kStatesPathOfIndia  = @"/api/countries/105/states";

static NSString *const kDoctorsListPath = @"/api/clinics";


/* Signin */
static NSString *const kSign_in_url             = @"http://neediator.in/NeediatorWS.asmx/checkLogin";

/* Neediator API Manager */

static NSString *const kMAIN_CATEGORIES_PATH    = @"/NeediatorWS.asmx/getCatSub";
static NSString *const kLISTING_PATH            = @"/NeediatorWS.asmx/getListing1";
static NSString *const kENTITY_DETAILS_PATH     = @"/NeediatorWS.asmx/getDetails";
static NSString *const kTIME_SLOTS_PATH         = @"/NeediatorWS.asmx/getTimeSlot";
static NSString *const kBOOKING_PATH            = @"/NeediatorWS.asmx/Book";
static NSString *const kSTORE_TAXONS_PATH       = @"/NeediatorWS.asmx/getTaxonomyTaxons";
static NSString *const kPAYMENT_OPTIONS_PATH    = @"/NeediatorWS.asmx/getPayment";
static NSString *const KSTATE_CITIES_PATH       = @"/NeediatorWS.asmx/getstatecity";
static NSString *const KALL_ADDRESSES_PATH      = @"/NeediatorWS.asmx/getaddress";
static NSString *const kDELETE_ADDRESSES_PATH   = @"/NeediatorWS.asmx/deleteaddress";
static NSString *const kUPLOAD_PRESCRIPTION_PATH   = @"/NeediatorWS.asmx/uploadPrescription";
static NSString *const kAUTOCOMPLETE_SEARCH_PRODUCT = @"/NeediatorWS.asmx/search_product";
static NSString *const kADD_TO_FAVOURTIE_PATH = @"/NeediatorWS.asmx/addToFavourites";


/* Helper Constants */

static NSString *const kSAVE_STORE_ID    = @"kSaveStoreID";
static NSString *const kSAVE_CAT_ID      = @"kSaveCatID";
static NSString *const kSAVE_DELIVERY_TYPES = @"kSaveDeliveryTypes";
static NSString *const kSAVE_ADDRESS_ID = @"kSaveAddressID";
static NSString *const kSAVE_DELIVERY_ID = @"kSaveDeliveryID";







