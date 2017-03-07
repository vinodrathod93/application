//
//  ProductDetailVC.h
//  Neediator
//
//  Created by adverto on 11/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailVC : UIViewController<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSString *AdminProductID;
@property(nonatomic,retain)NSString *VendorProductID;
@property(nonatomic,retain)NSString *AdminProductName;
@property(nonatomic,retain)NSString *AdminProductPrice;
@property(nonatomic,retain)NSArray *ImagesArray;
@property(nonatomic,retain)NSString *ProductQuantity;






@property (weak, nonatomic) IBOutlet UITableView *TableView;

@property (weak, nonatomic) IBOutlet UILabel *ProductNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ProductPrice;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraints;



- (IBAction)SpecificationPressed:(id)sender;
- (IBAction)DescriptionPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *SpecificationOutlet;
@property (weak, nonatomic) IBOutlet UIButton *DescriptionOutlet;



- (IBAction)AddToCartPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *AddToCartOutlet;

- (IBAction)BuyNowPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *BuyNowOutlet;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@end
