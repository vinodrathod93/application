//
//  RatingViewController.h
//  Neediator
//
//  Created by adverto on 09/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *LocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
- (IBAction)WriteReview:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *ReviewListTableView;



@property(nonatomic,retain)NSString *sectionID;
@property(nonatomic,retain)NSString *storeID;
@property(nonatomic,retain)NSString *storeImageUrl;
@property(nonatomic,retain)NSString *storeName;
@property(nonatomic,retain)NSString *Area;


@property(nonatomic,retain)NSArray *ReviewArray;


@end
