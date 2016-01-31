//
//  LineItems+CoreDataProperties.h
//  
//
//  Created by adverto on 31/01/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LineItems.h"

NS_ASSUME_NONNULL_BEGIN

@interface LineItems (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSNumber *lineItemID;
@property (nullable, nonatomic, retain) NSString *meta;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *option;
@property (nullable, nonatomic, retain) NSNumber *price;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSString *singleDisplayPrice;
@property (nullable, nonatomic, retain) NSNumber *total;
@property (nullable, nonatomic, retain) NSString *totalDisplayPrice;
@property (nullable, nonatomic, retain) NSNumber *totalOnHand;
@property (nullable, nonatomic, retain) NSNumber *variantID;
@property (nullable, nonatomic, retain) Order *order;

@end

NS_ASSUME_NONNULL_END
