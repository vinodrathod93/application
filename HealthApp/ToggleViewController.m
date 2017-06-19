//
//  ToggleViewController.m
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "ToggleViewController.h"
#import "ToggleTableViewCell.h"


typedef enum : NSUInteger {
    TG_OPEN_24HRS,
    TG_OFFER_AVAILABLE,
    TG_PROVIDES_DELIVERY,
} TOGGLE;


#define TGK_OPEN24HOURS @"24hours"
#define TGK_OFFER_AVAILABLE @"offers"
#define TGK_PROVIDES_DELIVERY @"delivery"


@interface ToggleViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary *valueDictionary;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ToggleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _toggleArray = @[
                     @{ @"name" : @"Open 24 Hours",
                        @"value": @0
                        },
                     
                     @{ @"name" : @"Provides Delivery",
                        @"value" : @0
                        },
                     
                     @{ @"name" : @"Offers Available",
                        @"value": @0
                        }
                     ];
    
    self.tableView.backgroundColor      =   [UIColor whiteColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableviewDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _toggleArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToggleTableViewCell *cell   =   [tableView dequeueReusableCellWithIdentifier:@"toggleFilterCellIdentifer" forIndexPath:indexPath];
    
    NSDictionary *dictionary    =   _toggleArray[indexPath.row];
    
    BOOL toggleSwitchValue     =   [dictionary[@"value"] boolValue];
    
    cell.toggleLabel.text       =   dictionary[@"name"];
    [cell.toggleSwitch setOn: toggleSwitchValue];
    
    cell.tag    =   indexPath.row;
    [cell.toggleSwitch addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.5f;
}


#pragma mark - Action

-(void)toggleChanged:(UISwitch *)toggle {
    
    switch (toggle.tag) {
        case TG_OPEN_24HRS: {
            _toggleDictionary[TGK_OPEN24HOURS]  =   @(toggle.isOn);
        }
            break;
            
        case TG_OFFER_AVAILABLE: {
            _toggleDictionary[TGK_OFFER_AVAILABLE]  =   @(toggle.isOn);
        }
            break;
            
        case TG_PROVIDES_DELIVERY: {
            _toggleDictionary[TGK_PROVIDES_DELIVERY]  =   @(toggle.isOn);
        }
            break;
            
        default:
            break;
    }
    
    [self.delegate appliedToggleFilter:self withData:_toggleDictionary];

}

@end
