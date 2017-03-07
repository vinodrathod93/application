//
//  VariantsViewController.h
//  Chemist Plus
//
//  Created by adverto on 28/09/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VariantsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;
- (IBAction)headerButtonPressed:(id)sender;

@property (nonatomic, strong) NSArray *variants;
@property (nonatomic, strong) NSString *productTitle;
@property (nonatomic, strong) NSString *productImage;

@end
