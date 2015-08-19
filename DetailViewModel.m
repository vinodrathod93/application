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


-(NSString *)imageAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    NSArray *array = (NSArray *)details.image;
    return array[2];
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
    return details.price;
}

-(NSString *)summaryAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    return details.summary;
}

-(void)addProducts:(NSArray *)array {
    [self.viewModelProducts addObjectsFromArray:array];
}


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



+(NSArray *)infiniteProductsFromJSON:(NSDictionary *)dictionary {
    NSMutableArray *products = [[NSMutableArray alloc]init];
    
    NSArray *array = [dictionary valueForKey:@"all_products"];
    
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        ProductDetail *detail = [[ProductDetail alloc]init];
        
        [detail setValue:[obj valueForKey:@"product_name"] forKey:@"name"];
        [detail setValue:[obj valueForKey:@"product_image"] forKey:@"image"];
        [detail setValue:[obj valueForKey:@"price"] forKey:@"price"];
        [detail setValue:[obj valueForKey:@"summary"] forKey:@"summary"];
        
        [products addObject:detail];
    }];
    
    return products;
}

-(NSString *)infiniteImageAtIndex:(NSInteger)index {
    ProductDetail *details = self.viewModelProducts[index];
    return details.image;
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

-(NSString *)nextPage:(NSDictionary *)dictionary {
    return [dictionary valueForKey:@"next_page"];
}

@end
