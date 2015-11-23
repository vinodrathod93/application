//
//  LineItems+CoreDataProperties.h
//  
//
//  Created by adverto on 23/11/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LineItems.h"

NS_ASSUME_NONNULL_BEGIN

@interface LineItems (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *lineItemID;
@property (nullable, nonatomic, retain) NSNumber *quantity;
@property (nullable, nonatomic, retain) NSNumber *price;
@property (nullable, nonatomic, retain) NSNumber *variantID;
@property (nullable, nonatomic, retain) NSNumber *totalOnHand;
@property (nullable, nonatomic, retain) Order *order;

@end

NS_ASSUME_NONNULL_END
