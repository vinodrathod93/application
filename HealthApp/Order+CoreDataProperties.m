//
//  Order+CoreDataProperties.m
//  
//
//  Created by adverto on 01/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Order+CoreDataProperties.h"

@implementation Order (CoreDataProperties)

@dynamic cat_id;
@dynamic number;
@dynamic store;
@dynamic store_id;
@dynamic total;
@dynamic delivery_time;
@dynamic shipping_charge;
@dynamic min_delivery_charge;
@dynamic cartLineItems;
@dynamic items;

@end
