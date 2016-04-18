//
//  SearchViewController.h
//  Neediator
//
//  Created by adverto on 07/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : UITableViewController<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nearByButton;
@property (nonatomic, strong) UISearchController *searchController;

-(void)activateSearchBar;
-(void)showLocationScope;

@end
