//
//  DoctorViewController.h
//  Chemist Plus
//
//  Created by adverto on 31/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoctorViewController : UITableViewController
- (IBAction)bookButtonPressed:(id)sender;

@property (nonatomic, strong) NSString *subCategoryID;
@end
