//
//  StoreTaxonsViewController.h
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreTaxonsViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *storeURL;
@property(nonatomic,retain)   NSString *storeName;
@property (nonatomic, strong) NSArray *storeImages;
@property(nonatomic,strong)   NSString *storearea;


//Neediator API
@property (nonatomic, strong) NSString *cat_id;
@property (nonatomic, strong) NSString *store_id;
@property (nonatomic, strong) NSArray *storePhoneNumbers;
@property (nonatomic, strong) NSString *storeDistance;
@property (nonatomic, strong) NSString *ratings;
@property (nonatomic, strong) NSString *reviewsCount;


@property (nonatomic, assign) BOOL isFavourite;
@property(nonatomic,assign)   BOOL isOffer;
@property (nonatomic, assign) BOOL isLikedStore;
@property (nonatomic, assign) BOOL isDislikedStore;


@property (nonatomic, strong) UIColor *background_color;


@property(nonatomic,strong)     NSArray *offersarray;
@property (nonatomic, strong)   NSArray *likeUnlikeArray;



#pragma mark - Taxanomies Controls.
@property (nonatomic, retain) NSArray *arrayOriginal;
@property (nonatomic, retain) NSMutableArray *arForTable;
-(void)miniMizeThisRows:(NSArray*)ar;







@end
