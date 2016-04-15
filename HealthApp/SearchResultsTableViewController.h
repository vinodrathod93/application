//
//  SearchResultsTableViewController.h
//  Neediator
//
//  Created by adverto on 07/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol SearchResultsTableviewDelegate <NSObject>

-(void)searchResultsTableviewControllerDidSelectResult:(NSDictionary *)data;

@end

@interface SearchResultsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic) NeediatorSearchScope neediatorSearchScope;
@property (nonatomic, weak) id <SearchResultsTableviewDelegate> delegate;

-(void)startNeediatorHUD;
-(void)hideHUD;

@end
