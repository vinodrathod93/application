//
//  AddToCart+CoreDataProperties.h
//  
//
//  Created by adverto on 24/09/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AddToCart.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddToCart (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *addedDate;
@property (nullable, nonatomic, retain) NSNumber *productID;
@property (nullable, nonatomic, retain) NSString *productImage;
@property (nullable, nonatomic, retain) NSString *productName;
@property (nullable, nonatomic, retain) NSNumber *productPrice;
@property (nullable, nonatomic, retain) NSString *quantity;
@property (nullable, nonatomic, retain) NSNumber *totalPrice;

@end

NS_ASSUME_NONNULL_END
