//
//  AddToCart.h
//  
//
//  Created by adverto on 24/07/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AddToCart : NSManagedObject

@property (nonatomic, retain) NSDate * addedDate;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSString * productImage;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * productPrice;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) NSString * totalPrice;

@end
