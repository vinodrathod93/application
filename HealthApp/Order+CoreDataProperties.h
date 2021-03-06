//
//  Order+CoreDataProperties.h
//  
//
//  Created by adverto on 27/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Order.h"

NS_ASSUME_NONNULL_BEGIN

@interface Order (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *cat_id;
@property (nullable, nonatomic, retain) NSString *delivery_time;
@property (nullable, nonatomic, retain) NSNumber *min_delivery_charge;
@property (nullable, nonatomic, retain) NSString *number;
@property (nullable, nonatomic, retain) NSNumber *shipping_charge;
@property (nullable, nonatomic, retain) NSString *store;
@property (nullable, nonatomic, retain) NSString *store_id;
@property (nullable, nonatomic, retain) NSString *total;
@property (nullable, nonatomic, retain) NSSet<LineItems *> *cartLineItems;
@property (nullable, nonatomic, retain) NSSet<AddToCart *> *items;

@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addCartLineItemsObject:(LineItems *)value;
- (void)removeCartLineItemsObject:(LineItems *)value;
- (void)addCartLineItems:(NSSet<LineItems *> *)values;
- (void)removeCartLineItems:(NSSet<LineItems *> *)values;

- (void)addItemsObject:(AddToCart *)value;
- (void)removeItemsObject:(AddToCart *)value;
- (void)addItems:(NSSet<AddToCart *> *)values;
- (void)removeItems:(NSSet<AddToCart *> *)values;

@end

NS_ASSUME_NONNULL_END
