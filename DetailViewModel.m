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



/************ Infinite series **************/

+(NSArray *)infiniteProductsFromJSON:(NSDictionary *)dictionary {
    NSMutableArray *products = [[NSMutableArray alloc]init];
    
    
    NSArray *array = [dictionary valueForKey:@"products"];
    [array enumerateObjectsUsingBlock:^(NSDictionary *product, NSUInteger idx, BOOL *stop) {
        ProductDetail *detail = [[ProductDetail alloc]init];
        
        detail.productID =  [product valueForKeyPath:@"master.id"];
        detail.name =       [product valueForKeyPath:@"master.name"];
        detail.hasVariant = [[product objectForKey:@"has_variants"] boolValue];
        
        // Master Images
        NSMutableArray *smallImages = [NSMutableArray array];
        NSMutableArray *productImages = [NSMutableArray array];
        NSMutableArray *largeImages = [NSMutableArray array];
        
        NSArray *imagesArray = [product valueForKeyPath:@"master.images"];
        [imagesArray enumerateObjectsUsingBlock:^(NSDictionary *images, NSUInteger idx, BOOL *stop) {
            
            [smallImages addObject:[images valueForKey:@"small_url"]];
            [productImages addObject:[images valueForKey:@"product_url"]];
            [largeImages addObject:[images valueForKey:@"large_url"]];
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
        [detail setValue:[product valueForKeyPath:@"master.description"] forKey:@"summary"];
        
        [products addObject:detail];
    }];
    
    return products;
}

-(NSString *)infiniteImageAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    NSArray *product = details.small_img;
    NSLog(@"%@",product);
    
    return product[0];
}

-(NSString *)getItemsCount:(NSDictionary *)dictionary {
    return [dictionary valueForKey:@"total_count"];
}

-(NSString *)getPagesCount:(NSDictionary *)dictionary {
    return [dictionary valueForKey:@"pages"];
}

-(NSString *)currentPage:(NSDictionary *)dictionary {
    return [dictionary valueForKey:@"current_page"];
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

@end
