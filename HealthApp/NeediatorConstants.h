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




/* Spree API Manager */
static NSString *const kStoresListPath = @"/api/stores";
static NSString *const kTaxonomiesListPath = @"/api/taxonomies";
static NSString *const kMyOrdersPath       = @"/api/orders/mine";
static NSString *const kStatesPathOfIndia  = @"/api/countries/105/states";
static NSString *const kDoctorsListPath = @"/api/clinics";


/* Signin */
static NSString *const kSign_in_url = @"http://neediator.net/NeediatorWebservice/neediatorWs.asmx/checkLogin";


/* Neediator API Manager */

static NSString *const kUPDATE_PROFILE_PATH             = @"/NeediatorWebservice/NeediatorWS.asmx/update_profile";
static NSString *const kMAIN_SECTIONS_PATH              = @"/NeediatorWS/Users.asmx/getSection";
static NSString *const kSECTION_CATEGORIES_PATH         = @"/NeediatorWS/Users.asmx/getSectionCategories";
static NSString *const kLISTING_PATH                    = @"/NeediatorWS/Users.asmx/getSectionStores"; //@"/NeediatorWebservice/NeediatorWS.asmx/getListing1";


static NSString *const kENTITY_DETAILS_PATH     = @"/NeediatorWebservice/NeediatorWS.asmx/getDetails";
static NSString *const kTIME_SLOTS_PATH         = @"/NeediatorWebservice/NeediatorWS.asmx/getTimeSlot";
static NSString *const kBOOKING_PATH            = @"/NeediatorWebservice/NeediatorWS.asmx/Book";
//static NSString *const kSTORE_TAXONS_PATH       = @"/NeediatorWebservice/NeediatorWS.asmx/getTaxonomyTaxons";
static NSString *const kSTORE_DETAILS_PATH       = @"/NeediatorWS/Users.asmx/GetStoreDetails";

static NSString *const kPAYMENT_OPTIONS_PATH    = @"/NeediatorWebservice/NeediatorWS.asmx/getPayment";
static NSString *const KSTATE_CITIES_PATH       = @"/NeediatorWebservice/NeediatorWS.asmx/getStateCity";
static NSString *const KALL_ADDRESSES_PATH      = @"/NeediatorWebservice/NeediatorWS.asmx/getAddress";
static NSString *const kDELETE_ADDRESSES_PATH   = @"/NeediatorWebservice/NeediatorWS.asmx/deleteAddress";
static NSString *const kUPLOAD_PRESCRIPTION_PATH    = @"/NeediatorWebservice/NeediatorWS.asmx/uploadPrescription";
static NSString *const kUPLOAD_REPORTS_PATH         = @"/NeediatorWebservice/NeediatorWS.asmx/ShareReport";

static NSString *const kAUTOCOMPLETE_SEARCH_PRODUCT = @"/NeediatorWebservice/NeediatorWS.asmx/search_product1";
static NSString *const kADD_TO_FAVOURTIE_PATH       = @"/NeediatorWebservice/NeediatorWS.asmx/addToFavourites";
//static NSString *const kADD_TO_LIKEDISLIKE_PATH     = @"/NeediatorWebservice/NeediatorWS.asmx/addToLikedislike";

static NSString *const kADD_TO_LIKEDISLIKE_PATH     = @"/NeediatorWebservice/NeediatorWS.asmx/addToLike";
static NSString *const kMY_ORDERS_PATH              = @"/NeediatorWebservice/NeediatorWS.asmx/myOrder";
static NSString *const kMY_ORDERS_PATH_BY_STATUS    = @"/NeediatorWebservice/NeediatorWS.asmx/myOrderByStatus";

static NSString *const kMY_BOOKING_PATH              = @"/NeediatorWebservice/NeediatorWS.asmx/mybooking1";
static NSString *const kMY_BOOKING_BY_STATUS    = @"/NeediatorWebservice/NeediatorWS.asmx/mybooking1bystatus";




static NSString *const kMY_FAVOURITES_PATH          = @"/NeediatorWebservice/NeediatorWS.asmx/viewFavourites";
static NSString *const kDELETE_FAVOURITE_PATH       = @"/NeediatorWebservice/NeediatorWS.asmx/deleteFavourites";
static NSString *const kAUTOCOMPLETE_LOCATION       = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:IN";
static NSString *const kGOOGLE_GEOCODE_URL          = @"https://maps.googleapis.com/maps/api/geocode/json?sensor=false";
static NSString *const kAUTOCOMPLETE_SEARCH_CATEGORIES          = @"/NeediatorWebservice/NeediatorWS.asmx/search_Section";
static NSString *const kAUTOCOMPLETE_SEARCH_STORES              = @"/NeediatorWebservice/NeediatorWS.asmx/universal_storesname";
static NSString *const kAUTOCOMPLETE_SEARCH_UNIVERSAL_PRODUCT   = @"/NeediatorWebservice/NeediatorWS.asmx/universal_searchproduct";
static NSString *const kSTORE_DETAILS_BY_CODE_PATH              = @"/NeediatorWebservice/NeediatorWS.asmx/detailsbycode";


typedef NS_ENUM(NSUInteger, NeediatorSearchScope)
{
    
    searchScopeCategory,
    searchScopeStore,
    searchScopeLocation
//    searchScopeProduct,
//    searchScopeService
};





/* Helper Constants */

static NSString *const kSAVE_STORE_ID    = @"kSaveStoreID";
static NSString *const kSAVE_SEC_ID      = @"kSaveSectionID";
static NSString *const kSAVE_SEC_CAT_ID      = @"kSaveCatID";
static NSString *const kSAVE_DELIVERY_TYPES = @"kSaveDeliveryTypes";
static NSString *const kSAVE_Address_Types  = @"kSaveAddressTypes";
static NSString *const kSAVE_Purpose_Types  = @"kSavePurposeTypes";

static NSString *const kSAVE_Pending_Reason_Types  = @"kSavePendingReasonTypes";
static NSString *const kSAVE_Processing_Reason_Types  = @"kSaveProcessingReasonTypes";






static NSString *const kSAVE_ADDRESS_ID         = @"kSaveAddressID";
static NSString *const kSAVE_ADDRESS_TYPE_ID    =@"kSaveAddressTypeID";
static NSString *const kSAVE_PURPOSE_TYPE_ID    =@"kSavePurposeTypeID";

static NSString *const kSAVE_DELIVERY_ID        = @"kSaveDeliveryID";

static NSString *const kSAVE_RECENT_STORES  = @"kSaveRecentStoreData";

static NSString *const kLAST_COMMUNICATION_DATE  = @"kLastCommunicationDate";

static NSString *const kPROMOCODE  = @"kPromoCode";

static NSString *const CheckOutStoreId= @"kCheckOutStoreID";




/* Home VC */
#define kHeaderViewHeight_Pad 327.5 //316
#define kHeaderViewHeight_Phone 187.5 //166


/* Stores VC */
#define kStoresNoStoresTag 10
#define kStoresConnectionViewTag 11


/* Taxon - Taxonomy VC */
#define kTaxonHeaderViewHeight_Pad 512
#define kTaxonHeaderViewHeight_Phone 256

/* Listing VC */
#define kListingConnectionViewTag 40
#define kListingNoListingTag 41
#define kListingHUDViewTag 42

/* Store Taxon VC */

#define kStoreReviewsViewHeight 35
#define kStoreButtonOptionsViewHeight 65
#define kStoreUploadPrsViewHeight 90

#define kStoreImageViewCellHeight 240
#define kStoreTaxonTaxonomyCellHeight 50
#define kStoreOffersViewHeight 62

