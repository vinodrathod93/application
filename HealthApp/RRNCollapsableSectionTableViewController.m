//
//  RRNCollapsableTableViewController.m
//  RRNCollapsableSectionTableView
//
//  Created by Robert Nash on 08/09/2015.
//  Copyright (c) 2015 Robert Nash. All rights reserved.
//

#import "RRNCollapsableSectionTableViewController.h"
#import "RRNCollapsableSectionItemProtocol.h"

@interface RRNCollapsableTableViewController ()
@end

@implementation RRNCollapsableTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:[self sectionHeaderNibName] bundle:nil];
    [[self collapsableTableView] registerNib:nib forHeaderFooterViewReuseIdentifier:[self sectionHeaderReuseIdentifier]];
}

-(UITableView *)collapsableTableView {
    return nil;
}

-(NSArray *)model {
    return nil;
}

-(BOOL)singleOpenSelectionOnly {
    return NO;
}

-(NSString *)sectionHeaderNibName {
    return nil;
}

-(NSString *)sectionHeaderReuseIdentifier {
    return [[self sectionHeaderNibName] stringByAppendingString:@"ID"];
}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self model].count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id menuSection = [[self model] objectAtIndex:section];
    BOOL itemConforms = [menuSection conformsToProtocol:@protocol(RRNCollapsableSectionItemProtocol)];
    return (itemConforms && ((id <RRNCollapsableSectionItemProtocol>)menuSection).isVisible.boolValue) ? ((id <RRNCollapsableSectionItemProtocol>)menuSection).items.count : 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    id menuSection = [[self model] objectAtIndex:section];
    
    UIView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[self sectionHeaderReuseIdentifier]];
    view.tag = section;
    
    BOOL headerConforms = [view conformsToProtocol:@protocol(RRNCollapsableSectionHeaderProtocol)];
    
    if (headerConforms) {
        ((id <RRNCollapsableSectionHeaderProtocol>)view).interactionDelegate = self;
    }
    
    BOOL itemConforms = [menuSection conformsToProtocol:@protocol(RRNCollapsableSectionItemProtocol)];
    
    if (headerConforms && itemConforms) {
        ((id <RRNCollapsableSectionHeaderProtocol>)view).titleLabel.text = ((id <RRNCollapsableSectionItemProtocol>)menuSection).title;
    }
    
    return view;
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    id menuSection = [[self model] objectAtIndex:section];
    
    BOOL headerConforms = [view conformsToProtocol:@protocol(RRNCollapsableSectionHeaderProtocol)];
    BOOL itemConforms = [menuSection conformsToProtocol:@protocol(RRNCollapsableSectionItemProtocol)];
    
    if (headerConforms && itemConforms && ((id <RRNCollapsableSectionItemProtocol>)menuSection).isVisible.boolValue) {
        [((id <RRNCollapsableSectionHeaderProtocol>)view) openAnimated:NO];
    } else if (headerConforms) {
        [((id <RRNCollapsableSectionHeaderProtocol>)view) closeAnimated:NO];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - ReactiveSectionHeaderProtocol

-(void)userTapped:(UIView *)view {
    
    UITableView *tableView = [self collapsableTableView];
    
    [tableView beginUpdates];
    
    BOOL foundOpenUnchosenMenuSection = NO;
    
    NSArray *menu = [self model];
    
    for (id <RRNCollapsableSectionItemProtocol> menuSection in menu) {
        
        if (![menuSection conformsToProtocol:@protocol(RRNCollapsableSectionItemProtocol)]) {
            continue;
        }
             
        BOOL chosenMenuSection = menuSection == [menu objectAtIndex:view.tag];
        
        BOOL isVisible = menuSection.isVisible.boolValue;
        
        if (isVisible && chosenMenuSection) {
            
            menuSection.isVisible = @NO;
            
            BOOL headerConforms = [view conformsToProtocol:@protocol(RRNCollapsableSectionHeaderProtocol)];
            
            if (headerConforms) {
                [((id <RRNCollapsableSectionHeaderProtocol>)view) closeAnimated:YES];
            }
            
            NSInteger section = view.tag;
            
            NSArray *indexPaths = [self indexPathsForSection:section
                                              forMenuSection:menuSection];
            
            [tableView deleteRowsAtIndexPaths:indexPaths
                             withRowAnimation:(foundOpenUnchosenMenuSection) ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop];
            
        } else if (!isVisible && chosenMenuSection) {
            
            menuSection.isVisible = @YES;
            
            BOOL headerConforms = [view conformsToProtocol:@protocol(RRNCollapsableSectionHeaderProtocol)];
            
            if (headerConforms) {
                [((id <RRNCollapsableSectionHeaderProtocol>)view) openAnimated:YES];
            }
            
            NSInteger section = view.tag;
            
            NSArray *indexPaths = [self indexPathsForSection:section
                                              forMenuSection:menuSection];
            
            [tableView insertRowsAtIndexPaths:indexPaths
                             withRowAnimation:(foundOpenUnchosenMenuSection) ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop];
            
        } else if (isVisible && !chosenMenuSection && [self singleOpenSelectionOnly]) {
            
            foundOpenUnchosenMenuSection = YES;
            
            menuSection.isVisible = @NO;
            
            NSInteger section = [menu indexOfObject:menuSection];
            
            UIView *headerView = [tableView headerViewForSection:section];
            
            BOOL headerConforms = [view conformsToProtocol:@protocol(RRNCollapsableSectionHeaderProtocol)];
            
            if (headerConforms) {
                [((id <RRNCollapsableSectionHeaderProtocol>)headerView) closeAnimated:YES];
            }
            
            NSArray *indexPaths = [self indexPathsForSection:section
                                              forMenuSection:menuSection];
            
            [tableView deleteRowsAtIndexPaths:indexPaths
                             withRowAnimation:(view.tag > section) ? UITableViewRowAnimationTop : UITableViewRowAnimationBottom];
            
        }
        
    }
    
    [tableView endUpdates];
}

-(NSArray *)indexPathsForSection:(NSInteger)section forMenuSection:(id <RRNCollapsableSectionItemProtocol>)menuSection {
    NSMutableArray *collector = [NSMutableArray new];
    NSInteger count = menuSection.items.count;
    NSIndexPath *indexPath;
    for (NSInteger i = 0; i < count; i++) {
        indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [collector addObject:indexPath];
    }
    return [collector copy];
}

@end
