//
//  DetailViewModel.m
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DetailViewModel.h"
#import "ProductDetail.h"

/*
static NSString *name = @"im:name";
static NSString *image = @"im:image";
static NSString *price = @"im:price";
static NSString *summary = @"summary"; */

@interface DetailViewModel()

@property (nonatomic, assign) int items_count;

@end

@implementation DetailViewModel

-(id)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        self.viewModelProducts = [NSMutableArray arrayWithArray:array];
    }
    return self;
}


-(NSString *)nameAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    return details.name;
}

-(NSInteger)numberOfProducts {
    return self.viewModelProducts.count;
}

-(NSString *)priceAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    return details.displayPrice;
}

-(NSString *)summaryAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    return details.summary;
}

-(NSString *)productIDAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    return details.productID;
}

-(void)addProducts:(NSArray *)array {
    [self.viewModelProducts addObjectsFromArray:array];
}

-(BOOL)isProductOutOfStock:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    
    if (details.total_on_hand.intValue != 0) {
        return false;
    } else
        return true;
}



/************ Infinite series **************/

/*
+(NSArray *)filterProductsFromJSON:(NSDictionary *)dictionary {
    NSMutableArray *filterProducts = [[NSMutableArray alloc]init];
    
    NSArray *array = [dictionary valueForKey:@"ProductStores"];
    
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        
        
        
        ProductDetail *detail = [[ProductDetail alloc]init];
        
        detail.productID =  [obj valueForKeyPath:@"productid"];
        detail.name =       [obj valueForKeyPath:@"productname"];
        detail.hasVariant = [[obj objectForKey:@"has_variants"] boolValue];
        detail.total_on_hand = [obj valueForKey:@"total_on_hand"];
        
        // Master Images
        NSMutableArray *smallImages = [NSMutableArray array];
        NSMutableArray *productImages = [NSMutableArray array];
        NSMutableArray *largeImages = [NSMutableArray array];
        
        NSArray *imagesArray = [obj valueForKeyPath:@"master.images"];
        [imagesArray enumerateObjectsUsingBlock:^(NSDictionary *images, NSUInteger idx, BOOL *stop) {
            
            [smallImages addObject:[images valueForKey:@"small_url"]];
            [productImages addObject:[images valueForKey:@"product_url"]];
            [largeImages addObject:[images valueForKey:@"large_url"]];
        }];
        
        detail.small_img = smallImages;
        detail.product_img = productImages;
        detail.large_img = largeImages;
        
        if (detail.hasVariant) {
            detail.variants = [obj objectForKey:@"variants"];
        }
        
        NSString *price = [obj valueForKeyPath:@"master.price"];
        [detail setValue:[obj valueForKeyPath:@"master.display_price"] forKey:@"displayPrice"];
        [detail setValue:[NSNumber numberWithInt:price.intValue] forKey:@"price"];
        [detail setValue:[obj valueForKeyPath:@"master.description"] forKey:@"summary"];
        
        [filterProducts addObject:detail];
        
        
 
        
        
        ProductDetail *detail = [[ProductDetail alloc]init];
        NSString *price = [obj valueForKey:@"price"];
        
        [detail setValue:[obj valueForKey:@"id"] forKey:@"product_id"];
        [detail setValue:[obj valueForKey:@"name"] forKey:@"product_name"];
        [detail setValue:[NSNumber numberWithInt:price.intValue] forKey:@"product_price"];
        [detail setValue:[obj valueForKey:@"in_stock"] forKey:@"product_inventory"];
        [detail setValue:[obj valueForKey:@"display_price"] forKey:@"product_display_price"];
        
        NSMutableArray *product_img_urls = [NSMutableArray array];
        NSArray *imagesArray = [obj valueForKeyPath:@"master.images"];
        [imagesArray enumerateObjectsUsingBlock:^(NSDictionary *images, NSUInteger idx, BOOL *stop) {
            [product_img_urls addObject:[images valueForKey:@"product_url"]];
        }];
        
        detail.product_img = product_img_urls;
        
        [filterProducts addObject:detail];
         
         
 
    }];
    
    return filterProducts;
}
*/


+(NSArray *)infiniteProductsFromJSON:(NSDictionary *)dictionary {
    NSMutableArray *products = [[NSMutableArray alloc]init];
    
    
    NSArray *array = [dictionary valueForKey:@"ProductStores"];
    [array enumerateObjectsUsingBlock:^(NSDictionary *product, NSUInteger idx, BOOL *stop) {
        ProductDetail *detail = [[ProductDetail alloc]init];
        
        detail.productID =  [product valueForKey:@"productid"];
        detail.name =       [product valueForKey:@"productname"];
        detail.storeID   =  [product valueForKey:@"storeid"];
        detail.catID     =  [product valueForKey:@"catid"];
        detail.default_image = [product valueForKey:@"imageurl"];
        detail.total_on_hand = [product valueForKey:@"qty"];
        
        // Master Images
        NSMutableArray *smallImages = [NSMutableArray array];
        NSMutableArray *productImages = [NSMutableArray array];
        NSMutableArray *largeImages = [NSMutableArray array];
        
        NSArray *imagesArray = [product valueForKeyPath:@"Productimages"];
        [imagesArray enumerateObjectsUsingBlock:^(NSDictionary *images, NSUInteger idx, BOOL *stop) {
            
            [smallImages addObject:[images valueForKey:@"imageurl"]];
            [productImages addObject:[images valueForKey:@"imageurl"]];
            [largeImages addObject:[images valueForKey:@"imageurl"]];
        }];
        
//        NSString *imageURL = [product valueForKey:@"imageurl"];
//        [productImages addObject:imageURL];
//        [largeImages addObject:imageURL];
//        [smallImages addObject:imageURL];
        
        detail.small_img = smallImages;
        detail.product_img = productImages;
        detail.large_img = largeImages;
//
//        if (detail.hasVariant) {
//            detail.variants = [product objectForKey:@"variants"];
//        }
        
        NSString *price = [product valueForKey:@"rate"];
        NSString *masterPrice = [product valueForKey:@"mrp"];
        
        
        
        NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
        [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
        
        NSString *display_price_string = [headerCurrencyFormatter stringForObjectValue:@(price.floatValue)];
        NSString *master_price_string  = [headerCurrencyFormatter stringFromNumber:@(masterPrice.floatValue)];
        
        [detail setValue:master_price_string forKey:@"masterPrice"];
        [detail setValue:display_price_string forKey:@"displayPrice"];
        [detail setValue:[NSNumber numberWithInt:price.intValue] forKey:@"price"];
        [detail setValue:[product valueForKey:@"description"] forKey:@"summary"];
        
        [products addObject:detail];
    }];
    
    return products;
}

-(NSString *)infiniteImageAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    NSArray *product = details.product_img;
    NSLog(@"%@",product);
    
    
    
    return (product.count == 0) ? details.default_image : product[0] ;
}

-(NSString *)getItemsCount:(NSDictionary *)dictionary {
    return [dictionary valueForKey:@"countrecord"];
}

-(NSString *)getPagesCount:(NSDictionary *)dictionary {
    if ([dictionary valueForKey:@"noofpages"] == @(0).stringValue) {
        return @"1";
    }
    else
        return [dictionary valueForKey:@"noofpages"];
}

-(NSString *)currentPage:(NSDictionary *)dictionary {
    return [dictionary valueForKey:@"currentpage"];
}

-(int)nextPage:(NSDictionary *)dictionary {
    return [self currentPage:dictionary].intValue + 1;
}



/*
 +(NSArray *)productsFromJSON:(NSDictionary *)objectNotation {
 NSMutableArray *products = [[NSMutableArray alloc] init];
 
 NSArray *entries = [objectNotation valueForKeyPath:@"feed.entry"];
 
 [entries enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger idx, BOOL *stop) {
 NSLog(@"%@",[entry valueForKeyPath:@"im:name.label"]);
 ProductDetail *detail = [[ProductDetail alloc] init];
 
 [detail setValue:[entry valueForKeyPath:@"title.label"] forKey:@"name"];
 [detail setValue:[entry valueForKeyPath:@"im:image.label"] forKey:@"image"];
 [detail setValue:[entry valueForKeyPath:@"im:price.label"] forKey:@"price"];
 [detail setValue:[entry valueForKeyPath:@"summary.label"] forKey:@"summary"];
 
 
 NSLog(@"%@",[entry valueForKeyPath:@"[collect].title.label"]);
 
 [products addObject:detail];
 }];
 
 NSLog(@"%lu",(unsigned long)products.count);
 
 return products;
 }
 
 
 
 -(NSString *)imageAtIndex:(NSInteger)index {
 ProductDetail *details = self.viewModelProducts[index];
 NSArray *array = (NSArray *)details.image;
 return array[2];
 }
 
 */



/*

+(NSArray *)secondVersionInfiniteProductsFromJSON:(NSArray *)allProducts {
    NSMutableArray *products = [[NSMutableArray alloc]init];
    
    if ([allProducts isKindOfClass:[NSArray class]]) {
        [allProducts enumerateObjectsUsingBlock:^(NSDictionary *product, NSUInteger idx, BOOL * _Nonnull stop) {
            ProductDetail *detail = [[ProductDetail alloc]init];
            
            detail.productID =  [product valueForKey:@"id"];
            detail.name =       [product valueForKeyPath:@"master.name"];
            
            NSArray *variants = [product objectForKey:@"variants"];
            if (variants.count == 0) {
                detail.hasVariant = NO;
            } else
                detail.hasVariant = YES;
            
            
//            NSArray *imagesArray = [product objectForKey:@"images"];
//            
//            if (imagesArray.count != 0) {
//                NSDictionary *images = imagesArray[0];
//                
//                detail.smallImage = [images valueForKeyPath:@"links.small"];
//                detail.productImage = [images valueForKeyPath:@"links.product"];
//                detail.largeImage = [images valueForKeyPath:@"links.large"];
//            }
            
            
            // Master Images
            NSMutableArray *smallImages = [NSMutableArray array];
            NSMutableArray *productImages = [NSMutableArray array];
            NSMutableArray *largeImages = [NSMutableArray array];
            
            NSArray *imagesArray = [product objectForKey:@"images"];
            [imagesArray enumerateObjectsUsingBlock:^(NSDictionary *images, NSUInteger idx, BOOL *stop) {
                
                [smallImages addObject:[images valueForKeyPath:@"links.small"]];
                [productImages addObject:[images valueForKeyPath:@"links.product"]];
                [largeImages addObject:[images valueForKeyPath:@"links.large"]];
            }];
            
            detail.small_img = smallImages;
            detail.product_img = productImages;
            detail.large_img = largeImages;
            
            
            
            
            if (detail.hasVariant) {
                detail.variants = [product objectForKey:@"variants"];
            }
            
            NSString *price = [product valueForKeyPath:@"master.price"];
            [detail setValue:[product valueForKeyPath:@"master.display_price"] forKey:@"displayPrice"];
            [detail setValue:[NSNumber numberWithInt:price.intValue] forKey:@"price"];
            [detail setValue:[product valueForKey:@"description"] forKey:@"summary"];
            
            [products addObject:detail];
        }];
    }
    
    
    
    
    return products;
}

*/

@end
