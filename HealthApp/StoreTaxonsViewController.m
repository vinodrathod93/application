//
//  StoreTaxonsViewController.m
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoreTaxonsViewController.h"
#import "RatingViewController.h"
#import "APIManager.h"
#import "ProductsViewController.h"
#import "StoreRealm.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "StoreTaxonHeaderViewCell.h"
#import "UploadPrescriptionViewController.h"
#import "SearchResultsTableViewController.h"
#import "StoreOptionsView.h"
#import "UploadPrescriptionCellView.h"
#import "NEntityDetailViewController.h"
#import "EntityDetailModel.h"
#import "MapLocationViewController.h"
#import "OffersPopViewController.h"
#import "NeediatorPhotoBrowser.h"
#import "ChemistOptionViewCell.h"
#import "DoctorOptionsViewCell.h"
#import "ListingModel.h"
#import "BookAppointmentVC.h"
#import "HomeRequestVC.h"
#import "UploadReportsVC.h"
#import "StoreReviewsView.h"
#import <STPopup/STPopup.h>
#import "TypeSendViewController.h"



#define kImageViewSection 0;
#define kUploadPrescriptionSection 1
#define kTaxonTaxonomySection 2;

typedef NS_ENUM(uint16_t, sections) {
    SectionStoreImageViews = 0,
    SectionStoreOptionsView,
    SectionStoreReportError,
};


@interface StoreTaxonsViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, MWPhotoBrowserDelegate>
{
    NSDictionary *webResponse;
    NSDictionary *received;
}



@property (nonatomic, strong) NSMutableArray *taxonomies;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableArray *largeStoreImages;

@property(nonatomic,retain)NSString *FinalString;



@end

@implementation StoreTaxonsViewController {
    BOOL _isExpanded;
    NSMutableArray *_dataArray;
    NSArray *_offersArray, *_shopInfoArray, *_storeAddresses;
    
    NSURLSessionDataTask *_task;
    NSURLSessionDataTask *_searchTask;
    NSInteger _footerHeight;
    UIActivityIndicatorView *_search_activityIndicator;
    
    UITapGestureRecognizer *_uploadPrsGestureRecognizer, *_quickOrderGestureRecognizer;
    //    UILongPressGestureRecognizer *_offersGestureRecognizer;
}

#pragma mark - View Did Load.
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.arForTable = [NSMutableArray array];
    // Navigation Bar
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    // Tableview
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [NeediatorUtitity defaultColor];
    
    
    // Network Request
//    [self requestTaxons];
    
    
    
    // Initialization
    _footerHeight = 0;
    self.taxonomies = [[NSMutableArray alloc] init];
    // Tap Gesture
    _uploadPrsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popUploadPrescriptionVC)];
    _quickOrderGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popQuickOrderSearchVC)];
    //    self.tableView.backgroundColor = self.background_color;
    
    
    
    

}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection");
    
    if (section == SectionStoreImageViews) {
        return 1;
    }
    else if (section == SectionStoreReportError)
    {
        //return [self.taxonomies count];
        return 1;
    }
    
    else if (section == SectionStoreOptionsView)
    {
        return 1;
    }
    else
        return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"storeTaxonomyCell";
    static NSString *chemistOptionsCellIdentifier = @"chemistStoreOptionsCellIdentifier";
    static NSString *doctorOptionsCellIdentifier = @"doctorStoreOptionsCellIdentifier";
    
    
    if (indexPath.section == SectionStoreImageViews) {
        // Taxon Header
        
        StoreTaxonHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeTaxonInfoCell"];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TaxonHeaderView" owner:self options:nil] firstObject];
            
//            if(!_isOffer)
//            {
//                cell.offersViewBottom.constant=-98;
//            }
            
            cell.scrollView.delegate = self;
            
            [cell.contentView bringSubviewToFront:cell.offersContentView];
            [self setupScrollViewFrame:cell];
            [self setupScrollViewImages:cell];
            [self setupOffersScrollView:cell];
            
            cell.pageControl.numberOfPages = self.storeImages.count;
            
            //     Offers View
            //            [_offersArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull offer, NSUInteger idx, BOOL * _Nonnull stop) {
            //
            //                NSString *offerURLString = [offer valueForKey:@"ImageUrl"];
            //                [cell.offersImageView sd_setImageWithURL:[NSURL URLWithString:offerURLString]];
            //            }];
        }
        
        
        return cell;
    }
    
    else if (indexPath.section == SectionStoreReportError)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.textLabel.text     =   @"Report Error";
        cell.textLabel.font     =   regularFont(17);
        
        return cell;
   }
    else {
        
        id cell;
        
        if ([self.cat_id isEqualToString:@"2"])
        {
            DoctorOptionsViewCell *doctorOptionsCell = [tableView dequeueReusableCellWithIdentifier:doctorOptionsCellIdentifier forIndexPath:indexPath];
            doctorOptionsCell.selectionStyle = UITableViewCellSelectionStyleNone;
            doctorOptionsCell.backgroundColor = [UIColor clearColor];
            [doctorOptionsCell.appointmentButton addTarget:self action:@selector(openAppoinmentVC) forControlEvents:UIControlEventTouchUpInside];
            [doctorOptionsCell.sendReportButton addTarget:self action:@selector(openGallery) forControlEvents:UIControlEventTouchUpInside];
            
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HomeRequestTapped)];
            [doctorOptionsCell.homeRequestView addGestureRecognizer:tap];
            
            cell = doctorOptionsCell;
        }
        else {
            
            ChemistOptionViewCell *chemistOptionCell = [tableView dequeueReusableCellWithIdentifier:chemistOptionsCellIdentifier forIndexPath:indexPath];
            chemistOptionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [chemistOptionCell.sendPrescriptionView addGestureRecognizer:_uploadPrsGestureRecognizer];
            [chemistOptionCell.quickOrderView addGestureRecognizer:_quickOrderGestureRecognizer];
            [chemistOptionCell.sendPresButton addTarget:self action:@selector(popUploadPrescriptionVC) forControlEvents:UIControlEventTouchUpInside];
            [chemistOptionCell.quickOrderButton addTarget:self action:@selector(popQuickOrderSearchVC) forControlEvents:UIControlEventTouchUpInside];
            
            chemistOptionCell.backgroundColor = [UIColor clearColor];
            
            cell = chemistOptionCell;
        }
        
        
        return cell;
    }
}



/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionStoreTaxonTaxonomies)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
      //  cell.backgroundColor=[UIColor lightGrayColor];
        NSLog(@"%ld %ld",(long)indexPath.row,(long)indexPath.section);
        
        NSLog(@"Cell TextLabel Is %@",cell.textLabel.text);
        
        //  cell.imageView.image=[UIImage imageNamed:@"Collapse Arrow"];
        //  cell.imageView.image=[UIImage imageNamed:@"Expand Arrow"];
        
        NSDictionary *d=[self.arForTable objectAtIndex:indexPath.row];
   //     cell.imageView.image=[UIImage imageNamed:@"Expand Arrow"];
        
        NSArray *abcarray=[d valueForKey:@"List"];
        
        if(!(abcarray.count==0))
        {
            NSArray *ar=[d valueForKey:@"List"];
            
            BOOL isAlreadyInserted=NO;
            
            for(NSDictionary *dInner in ar )
            {
                NSInteger index=[self.arForTable indexOfObjectIdenticalTo:dInner];
                isAlreadyInserted=(index>0 && index!=NSIntegerMax);
                if(isAlreadyInserted)
                    break;
            }
            if(isAlreadyInserted)
            {
                //cell.imageView.image=[UIImage imageNamed:@"Expand Arrow"];
                [self miniMizeThisRows:ar];
                
            } else
            {
                //           cell.imageView.image=[UIImage imageNamed:@"Collapse Arrow"];
                NSUInteger count=indexPath.row+1;
                NSMutableArray *arCells=[NSMutableArray array];
                for(NSDictionary *dInner in ar )
                {
                    [arCells addObject:[NSIndexPath indexPathForRow:count inSection:indexPath.section]];
                    [self.arForTable insertObject:dInner atIndex:count++];
                }
                [tableView insertRowsAtIndexPaths:arCells withRowAnimation:UITableViewRowAnimationFade];
                
            }
        }
        else
        {
            id model = self.arForTable[indexPath.row];
            ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
            //            productsVC.navigationTitleString = @"Hello Products";
            
            productsVC.GrandProduct=model[@"GrandProduct"];
            productsVC.ParentProduct=model[@"ParentProduct"];
            productsVC.GrandChildProduct=model[@"GrandChildProduct"];
            productsVC.ChildProduct=model[@"ChildProduct"];
            productsVC.SubChildProduct=model[@"SubChildProduct"];
            NSLog(@"\nGrandProduct--%@ \nParentProduct--%@ \nGrandChildProduct--%@ \nChildProduct--%@  \nSubChildProduct--%@\n",productsVC.GrandProduct,productsVC.ParentProduct,productsVC.GrandChildProduct,productsVC.ChildProduct,productsVC.SubChildProduct);
            
            productsVC.storeID = self.store_id;
            productsVC.categoryID = self.cat_id;
            
            [self.navigationController pushViewController:productsVC animated:YES];
        }
    }
}

-(void)miniMizeThisRows:(NSArray*)ar{
    
//    NSIndexPath *indexpath;
//     UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexpath];
    //cell.backgroundColor=[UIColor clearColor];
        for(NSDictionary *dInner in ar )
        {
            NSUInteger indexToRemove=[self.arForTable indexOfObjectIdenticalTo:dInner];
            NSArray *arInner=[dInner valueForKey:@"List"];
            if(arInner && [arInner count]>0)
            {
                [self miniMizeThisRows:arInner];
            }
            if([self.arForTable indexOfObjectIdenticalTo:dInner]!=NSNotFound) {
                [self.arForTable removeObjectIdenticalTo:dInner];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:
                                                        [NSIndexPath indexPathForRow:indexToRemove inSection:SectionStoreTaxonTaxonomies]
                                                        ]
                                      withRowAnimation:UITableViewRowAnimationRight];
            }
        }
 }
*/


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SectionStoreImageViews) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return kTaxonHeaderViewHeight_Pad;
        }
        else
            return kTaxonHeaderViewHeight_Phone;
        
    }
    else if (indexPath.section == SectionStoreReportError)
        return kStoreTaxonTaxonomyCellHeight;
    else if (indexPath.section == SectionStoreOptionsView) {
        
        if([self.cat_id isEqualToString:@"2"])
            return 172.f;
        else
            return kStoreUploadPrsViewHeight;
    }
    else
        return 0.0f;
}


#pragma mark - Header View

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (section == SectionStoreImageViews) {
        
        return [self storeReviewsView];
        
    }
    else if (section == SectionStoreOptionsView) {
        
        return [self storeOptionView];
    }
    //    else if (section == SectionStoreTaxonTaxonomies) {
    //        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    //        footer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0);
    //        footer.backgroundColor = [NeediatorUtitity defaultColor];
    ////        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.view.frame), 30)];
    ////        label.backgroundColor = [UIColor clearColor];
    ////        label.text = @"Browse by Categories";
    ////        label.textAlignment = NSTextAlignmentCenter;
    ////        label.font = [NeediatorUtitity mediumFontWithSize:17];
    ////        [footer addSubview:label];
    //        return footer;
    //    }
    return header;
}




-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == SectionStoreImageViews) {
        return kStoreReviewsViewHeight;
    }
    else if (section == SectionStoreOptionsView) {
        return kStoreButtonOptionsViewHeight;
    }
    else if (section == SectionStoreReportError) {
        
        return 5;
    }
    else
        return 0;
}







#pragma mark - Footer View

/*
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == SectionStoreTaxonTaxonomies) {
        if (_footerHeight > 0) {
            return [self getHudView];
        }
        else
            return nil;
    }
    //    else if (section == SectionStoreOptionsView) {
    //
    //        UploadPrescriptionCellView *view =  [self uploadPrescriptionCellView];
    //        view.frame = CGRectMake(0, 5, CGRectGetWidth(self.view.frame), kStoreUploadPrsViewHeight);
    //
    //        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    //        footer.frame = CGRectMake(0, view.frame.size.height, CGRectGetWidth(self.view.frame), 50 + view.frame.size.height);
    //
    //        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10 + view.frame.size.height, CGRectGetWidth(self.view.frame), 30)];
    //        label.backgroundColor = [UIColor clearColor];
    //        label.text = @"Browse by Categories";
    //        label.textAlignment = NSTextAlignmentCenter;
    //        label.font = [NeediatorUtitity mediumFontWithSize:17];
    //
    //        [footer addSubview:label];
    //        [footer addSubview:view];
    //
    //        return footer;
    //
    //
    //    }
    else
        return nil;
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == SectionStoreTaxonTaxonomies)
    {
        return _footerHeight;
    }
    //    else if (section == SectionStoreOptionsView)
    //        return kStoreUploadPrsViewHeight + 50;
    //    else
    return 0;
    
}
*/

#pragma mark - UITableViewDelegate








#pragma mark - Collapse - Expand Methods
/*
-(void)collapseCellsFromIndexOf:(TaxonomyModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSLog(@"collapseCellsFromIndexOf");
    
    if (indexPath.section == SectionStoreTaxonTaxonomies) {
        
        NSInteger collapseCount = [self numberOfCellsToBeCollapsed:model];
        NSRange collapseRange = NSMakeRange(indexPath.row + 1, collapseCount);
        
        
        [self.taxonomies removeObjectsInRange:collapseRange];
        model.isExpanded = NO;
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i<collapseRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:indexPath.section]];
        }
        // Animate and delete
        [tableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    
}



-(void)expandCellsFromIndexOf:(TaxonomyModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    NSLog(@"expandCellsFromIndexOf");
    
    if (indexPath.section == SectionStoreTaxonTaxonomies) {
        if (model.taxons.count > 0) {
            model.isExpanded = YES;
            
            int i=0;
            
            for (TaxonModel *taxonModel in model.taxons) {
                [self.taxonomies insertObject:taxonModel atIndex:indexPath.row + i + 1];
                i++;
            }
            
            NSRange expandedRange = NSMakeRange(indexPath.row, i);
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (int i=0; i< expandedRange.length; i++) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:indexPath.section]];
            }
            
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            
            [tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    
}
*/


#pragma mark - Custom Views

-(StoreReviewsView *)storeReviewsView
{
    StoreReviewsView *storeReviewsView = [[[NSBundle mainBundle] loadNibNamed:@"StoreReviewsView" owner:self options:nil] lastObject];
    storeReviewsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kStoreReviewsViewHeight);
#warning remove the hardcoded value
    storeReviewsView.ratingView.rating = 0.5;
    NSString *reviews = [NSString stringWithFormat:@"✍ %@",self.reviewsCount];
    [storeReviewsView.reviewsLabel setTitle:reviews forState:UIControlStateNormal];
    //sb storeReviewsView.backgroundColor = [NeediatorUtitity defaultColor];
    
    [storeReviewsView.reviewsLabel addTarget:self action:@selector(ReviewButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    
    storeReviewsView.likedStore  =  self.isLikedStore;
    
    if (self.isLikedStore) {
        storeReviewsView.likeButton.selected = YES;
        [storeReviewsView.likeImageView setImage:[UIImage imageNamed:@"thumbs_up_filled"]];
    }
    else
    {
        storeReviewsView.likeButton.selected = NO;
        [storeReviewsView.likeImageView setImage:[UIImage imageNamed:@"thumbs_up"]];
    }
    
    
    
    
    [storeReviewsView.likeButton addTarget:self action:@selector(requestLike:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if (self.likeUnlikeArray.count == 0)
    {
        [storeReviewsView.likeButton setTitle:@"0" forState:UIControlStateNormal];
        [storeReviewsView.dislikeButton setTitle:@"0" forState:UIControlStateNormal];
    }
    else {
        
        NSLog(@"%@", self.likeUnlikeArray);
        NSDictionary *likeUnlikeDict = [self.likeUnlikeArray lastObject];
        
        NSNumber *likeCount = likeUnlikeDict[@"like"];
        
        NSNumber *dislikeCount = likeUnlikeDict[@"unlike"];
        
        if ([dislikeCount isEqual:[NSNull null]]) {
            dislikeCount = @0;
        }
        
        [storeReviewsView.likeButton setTitle:likeCount.stringValue forState:UIControlStateNormal];
        [storeReviewsView.dislikeButton setTitle:dislikeCount.stringValue forState:UIControlStateNormal];
    }
    return storeReviewsView;
}


-(void)requestLike:(UIButton *)button
{
    
    
    NSString *likeTag;
    //  NSString *dislikeTag;
    StoreReviewsView *storeReviewsView = (StoreReviewsView *)button.superview;
    
    
    
    if (!storeReviewsView.dislikeButton.isSelected) {
        button.selected = !button.selected;
        
        if (button.isSelected) {
            
            NSLog(@"Button is Selected");
            likeTag = @"1";
            //  dislikeTag = @"0";
            
            [button setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
        }
        
        else {
            
            NSLog(@"Button is  not Selected");
            likeTag = @"0";
            //     dislikeTag = @"0";
            [button setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        }
        
    }
    else
    {
        likeTag = @"1";
        //    dislikeTag = @"0";
        
        storeReviewsView.dislikeButton.selected = NO;
        [storeReviewsView.dislikeButton setImage:[UIImage imageNamed:@"dislike"] forState:UIControlStateNormal];
        
        storeReviewsView.likeButton.selected = YES;
        [storeReviewsView.likeButton setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateNormal];
    }
    
    [self requestLikeDislike:button];
}



-(void)requestLikeDislike:(UIButton *)sender  {
    
    User *user = [User savedUser];
    
    if (user != nil) {
        
        NSDictionary *parameter = @{
                                    @"user_id": user.userID,
                                    @"Section_id" : [NeediatorUtitity savedDataForKey:kSAVE_SEC_ID],
                                    @"store_id" : [NeediatorUtitity savedDataForKey:kSAVE_STORE_ID]
                                    };
        
        [[NAPIManager sharedManager] postlikeDislikeWithData:parameter success:^(NSDictionary *likeDislikes)
         {
             NSNumber *Totallike=likeDislikes[@"Totallike"];
             
             
             StoreReviewsView *storeReviewsView = (StoreReviewsView *)sender.superview;
             
             
             [storeReviewsView.likeButton setTitle:Totallike.stringValue forState:UIControlStateNormal];
             
             
             
         } failure:^(NSError *error) {
             [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
         }];
    }
    else
        [NeediatorUtitity showLoginOnController:self isPlacingOrder:NO];
}






-(StoreOptionsView *)storeOptionView {
    
    StoreOptionsView *storeOptionView = [[[NSBundle mainBundle] loadNibNamed:@"StoreOptionsView" owner:self options:nil] lastObject];
    storeOptionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kStoreButtonOptionsViewHeight);
 //sb   [storeOptionView.locationButton setTitle:self.storeDistance forState:UIControlStateNormal];
    storeOptionView.favouriteStore = self.isFavourite;
    
    if (self.isFavourite) {
        storeOptionView.favButton.selected = YES;
    }
    else
        storeOptionView.favButton.selected = NO;
    
    [storeOptionView.favButton addTarget:self action:@selector(requestFavourites:) forControlEvents:UIControlEventTouchUpInside];
    [storeOptionView.infoButton addTarget:self action:@selector(goToStoreInfoDetailVC) forControlEvents:UIControlEventTouchUpInside];
    [storeOptionView.shareButton addTarget:self action:@selector(shareStoreDetails:) forControlEvents:UIControlEventTouchUpInside];
    [storeOptionView.locationButton addTarget:self action:@selector(showLocation:) forControlEvents:UIControlEventTouchUpInside];
    [storeOptionView.callButton addTarget:self action:@selector(showPhoneNumbers:) forControlEvents:UIControlEventTouchUpInside];
    
    return storeOptionView;
}

-(UploadPrescriptionCellView *)uploadPrescriptionCellView {
    UploadPrescriptionCellView *cell =  [[[NSBundle mainBundle] loadNibNamed:@"UploadPrescriptionCellView" owner:self options:nil] lastObject];
    
    /* Upload Prs & Quick Order */
    [cell.uploadPrpButton addTarget:self action:@selector(popUploadPrescriptionVC) forControlEvents:UIControlEventTouchUpInside];
    [cell.quickOrderButton addTarget:self action:@selector(popQuickOrderSearchVC) forControlEvents:UIControlEventTouchUpInside];
    
    
    [cell.uploadPrsView addGestureRecognizer: _uploadPrsGestureRecognizer];
    [cell.quickOrderView addGestureRecognizer:_quickOrderGestureRecognizer];
    
    
    return cell;
}



#pragma mark Rating View Controller Code
-(void)ReviewButtonTapped
{
    User *saved_user = [User savedUser];
    
    
    if (saved_user != nil) {
        
        
        RatingViewController *rvc = [self.storyboard instantiateViewControllerWithIdentifier:@"RatingViewController"];
        
        rvc.title=@"Reviews";
        
        rvc.sectionID=self.cat_id;
        rvc.storeID=self.store_id;
        rvc.storeImageUrl=self.storeURL;
        rvc.storeName=self.storeName;
        rvc.Area=self.storearea;
        
        [self.navigationController pushViewController:rvc animated:YES];
        NSLog(@"Review Tapped ");
        
    }
    
    else {
        
        LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            logSignVC.modalPresentationStyle    = UIModalPresentationFormSheet;
        }
        
        [self presentViewController:logSignVC animated:YES completion:nil];
    }
}




#pragma mark - Navigation


-(void)showLocation:(UIButton *)button
{
    
    if (_storeAddresses != nil) {
        MapLocationViewController *mapVC = [[MapLocationViewController alloc] init];
        mapVC.storeName                     = self.title;
        mapVC.storeAddressArray             = _storeAddresses;
        mapVC.storeDistance                 = _storeDistance;
        
        NSLog(@" Store Address Array %@",_storeAddresses);
        [self.navigationController pushViewController:mapVC animated:YES];
    }
    else
        NSLog(@"Store Addresses nil");
}


-(void)makeCall:(NSString *)number {
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",number]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *callAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [callAlertView show];
    }
}

-(void)showPhoneNumbers:(UIButton *)button {
    
    if (self.storePhoneNumbers != nil) {
        UIAlertController *phoneAlertController = [UIAlertController alertControllerWithTitle:@"Select Number" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [self.storePhoneNumbers enumerateObjectsUsingBlock:^(NSString *_Nonnull phoneNumber, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:phoneNumber style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self makeCall:phoneNumber];
            }];
            
            [phoneAlertController addAction:action];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [phoneAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [phoneAlertController addAction:cancelAction];
        
        
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:phoneAlertController animated:YES completion:nil];
        }
        else {
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:phoneAlertController];
            [popup presentPopoverFromRect:button.frame inView:[button superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
        NSLog(@"Phone numbers are nil");
    
}


-(void)shareStoreDetails:(UIButton *)button
{
    
    NSString *texttoshare = @"Hey! I Found this Awesome Listing - Checkout this on .\n neediator://stores";
    
    NSArray *activityItems = @[texttoshare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityVC animated:TRUE completion:nil];
    }
    else
    {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popup presentPopoverFromRect:button.frame inView:[button superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


-(void)goToStoreInfoDetailVC
{
    
    NSDictionary *image = [self.storeImages firstObject];
    
    if (_shopInfoArray != nil)
    {
        NEntityDetailViewController *storeInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NEntityVC"];
        storeInfoVC.isStoreInfo = YES;
        storeInfoVC.storeInfoArray = _shopInfoArray;
        storeInfoVC.entity_image = image[@"image_url"];
        
        
        [self.navigationController pushViewController:storeInfoVC animated:YES];
    }
    else
        NSLog(@"Shop Info is nil");
    
}

-(void)popUploadPrescriptionVC
{
    UploadPrescriptionViewController *uploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uploadPrescriptionVC"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}

-(void)openAppoinmentVC
{
    BookAppointmentVC *BAVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BookAppointmentVC"];
    [self.navigationController pushViewController:BAVC animated:YES];
}

-(void)HomeRequestTapped
{
    HomeRequestVC *hrvc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeRequestVC"];
    [self.navigationController pushViewController:hrvc animated:YES];
}

-(void)openGallery
{
    UploadReportsVC *reportVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadReportsVC"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:reportVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}


-(void)popQuickOrderSearchVC
{
    /*
    SearchResultsTableViewController *searchResultsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsVC"];
    searchResultsVC.isQuickOrder = YES;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsVC];
    
    [UIView transitionWithView:self.searchController.view duration:0.53 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
        self.searchController.view.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        NSLog(@"Finished Transition");
    }];
    
    
    self.searchController.searchBar.placeholder = @"Search Product for Quick Order";
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    _search_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _search_activityIndicator.center = CGPointMake(self.searchController.view.center.x, self.searchController.view.center.y - 100);
    
    
    [self.searchController.view addSubview:_search_activityIndicator];
    [self presentViewController:self.searchController animated:YES completion:nil];
    */
    
    UIStoryboard *typeSendStoryboard  =   [UIStoryboard storyboardWithName:@"TypeSendStoryboard" bundle:nil];
    TypeSendViewController *typeSendVC  =   [typeSendStoryboard instantiateViewControllerWithIdentifier:@"typeSendVC"];
    
    [self.navigationController pushViewController:typeSendVC animated:YES];
    
    
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchController.searchBar.placeholder = @"";

}


-(void)storeMWPhotos {
    
    self.largeStoreImages = [NSMutableArray array];
    
    NSMutableArray *largePhotos = [NSMutableArray array];
    
    for (NSDictionary *store in self.storeImages) {
        [largePhotos addObject:store[@"image_url"]];
    }
    
    MWPhoto *photo;
    
    if (largePhotos.count != 0) {
        for (NSString *largeImageString in largePhotos)
        {
            photo = [MWPhoto photoWithURL:[NSURL URLWithString:largeImageString]];
            photo.caption = @"Store Fronts";
            
            [self.largeStoreImages addObject:photo];
        }
    }
}

-(void)showLargeImages {
    
    [self storeMWPhotos];
    NeediatorPhotoBrowser *browser = [[NeediatorPhotoBrowser alloc]initWithDelegate:self];
    //
    //    browser.backgroundColor = [UIColor whiteColor];
    //    browser.navBarTintColor = self.tableView.tintColor;
    //    browser.barStyle        = UIBarStyleDefault;
    
    browser.displayActionButton = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableSwipeToDismiss = NO;
    browser.enableGrid = NO;
    
    //    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    //    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    [self presentViewController:nc animated:YES completion:nil];
    
    [self.navigationController pushViewController:browser animated:YES];
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.largeStoreImages.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.largeStoreImages.count)
        return [self.largeStoreImages objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < self.largeStoreImages.count)
        return [self.largeStoreImages objectAtIndex:index];
    return nil;
}



- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark - Private Methods



-(void)hideHUD {
    [self.hud hide:YES];
    
    _footerHeight = 0;
    
    [self tableView:self.tableView viewForFooterInSection:1];
    
    [self.tableView reloadData];
}


-(UIView *)showNeediatorHUD {
    
    
    NeediatorHUD *hud = [[NeediatorHUD alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _footerHeight)];
    hud.overlayColor = [UIColor clearColor];
    hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds)/2, _footerHeight/2);
    [hud fadeInAnimated:YES];
    
    return hud;
}


-(UIView *)getHudView {
    
    //    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _footerHeight)];
    //
    //    self.hud = [MBProgressHUD showHUDAddedTo:hudView animated:YES];
    //    self.hud.color          = [UIColor clearColor];
    //    self.hud.activityIndicatorColor = [UIColor blackColor];
    //
    //
    //    return hudView;
    
    return [self showNeediatorHUD];
}


-(UIView*) viewForDisclosureForState:(BOOL) isExpanded
{
    NSString *imageName;
    if(isExpanded)
    {
        imageName = @"Collapse Arrow";
    }
    else
    {
        imageName = @"Expand Arrow";
    }
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imgView setFrame:CGRectMake(0, 6, 24, 24)];
    [myView addSubview:imgView];
    return myView;
}


-(NSInteger) numberOfCellsToBeCollapsed:(TaxonomyModel *) model
{
    
    NSLog(@"numberOfCellsToBeCollapsed");
    
    NSInteger total = 0;
    
    if(model.isExpanded)
    {
        // Set the expanded status to no
        model.isExpanded = NO;
        NSArray *child = model.taxons;
        
        total = child.count;
        
    }
    return total;
}







#pragma mark  - Network


-(void)requestStoreDetails {
    
    NSLog(@"requestTaxons");
    
    NSDictionary *parameter = @{
                                
                                @"sectionId"        :   [NeediatorUtitity savedDataForKey:kSAVE_SEC_ID],
                                @"categoryId"       :   self.cat_id,
                                @"subCategoryId"    :   @"",
                                @"storeId"          :   self.store_id
                                };
    
    
    NSLog(@"Parameter %@", parameter);
    
    _task = [[NAPIManager sharedManager] getStoreDetails:parameter WithSuccess:^(NSArray *storeData, NSArray *storeImages, NSArray *offers, NSArray *storeAddress) {
        
        NSLog(@"Success");
        
        
        _offersArray        =   offers;
        self.storeImages    =   storeImages;
        _storeAddresses     =   storeAddress;
        
//        _shopInfoArray = responseModel.shopInfo;
        
        
        [self.tableView reloadData];
        [self hideHUD];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Failure");
        [self hideHUD];
        
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
        
    }];
}


-(void)requestFavourites:(UIButton *)button {
    
    User *user = [User savedUser];
    
    if (user != nil) {
        
        NSDictionary *parameter = @{
                                    @"user_id"      : user.userID,
                                    @"Section_id"   : [NeediatorUtitity savedDataForKey:kSAVE_SEC_ID],
                                    @"store_id"     : [NeediatorUtitity savedDataForKey:kSAVE_STORE_ID]
                                    };
        
        
        [[NAPIManager sharedManager] postFavouritesWithData:parameter success:^(BOOL success) {
            if (success)
            {
                button.selected = YES;
                NSString *message = @"Added To Favourites";
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:nil];
                int duration = 1; // duration in seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            }
            else
            {
                button.selected = NO;
                NSString *message = @"Removed From Favourites";
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:YES completion:nil];
                int duration = 1; // duration in seconds
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });

            }
            
            if (button.isSelected) {
                [button setImage:[UIImage imageNamed:@"store_fav_filled"] forState:UIControlStateNormal];
            }
            else
                [button setImage:[UIImage imageNamed:@"store_fav"] forState:UIControlStateNormal];
            
        } failure:^(NSError *error) {
            NSLog(@"Fav. Error = %@", [error localizedDescription]);
        }];
    }
    
    else
    {
        NSLog(@"User Not Logged In");
        [NeediatorUtitity showLoginOnController:self isPlacingOrder:NO];
        
    }
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Store Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [_task suspend];
//    [self hideHUD];
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    
    StoreTaxonHeaderViewCell *cell = (StoreTaxonHeaderViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.scrollView.contentSize         = CGSizeMake(CGRectGetWidth(cell.scrollView.frame) * self.storeImages.count, CGRectGetHeight(cell.scrollView.frame));
    cell.offersScrollView.contentSize   = CGSizeMake(CGRectGetWidth(cell.offersScrollView.frame) * self.offersarray.count, CGRectGetHeight(cell.offersScrollView.frame));
    
}





#pragma mark - UISearchControllerDelegate & SearchResultsDelegate

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = self.searchController.searchBar.text;
    
    NSLog(@"SEarch Results %@", searchString);
    
    NSDictionary *parameter = @{
                                @"Section_id"   : self.cat_id,
                                @"store_id"     : self.store_id,
                                @"search"       : searchString
                                };
    
    [_search_activityIndicator startAnimating];
    
    _searchTask = [[NAPIManager sharedManager] getSearchedProductsWithData:parameter success:^(NSArray *products) {
        
        // search products.
        self.searchResults = [products mutableCopy];
        
        if (self.searchController.searchResultsController) {
            
            SearchResultsTableViewController *vc = (SearchResultsTableViewController *)self.searchController.searchResultsController;
            
            [_search_activityIndicator stopAnimating];
            
            // Update searchResults
            vc.searchResults = self.searchResults;
            
            if (self.searchResults.count == 0) {
                
                NSDictionary *noProduct = @{
                                            @"productname" : @"No Products",
                                            @"brandname"   : @""
                                            };
                [self.searchResults addObject:noProduct];
            }
            // And reload the tableView with the new data
            [vc.tableView reloadData];
        }
        
        
    } failure:^(NSError *error) {
        
        [_search_activityIndicator stopAnimating];
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
}






#pragma mark - ImageViews Cell Methods

-(void)setupScrollViewImages:(StoreTaxonHeaderViewCell *)cell {
    
    NSLog(@"setupScrollViewImages");
    
    [self.storeImages enumerateObjectsUsingBlock:^(NSDictionary *imageData, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.scrollView.frame) * idx, 0, CGRectGetWidth(cell.scrollView.frame), CGRectGetHeight(cell.scrollView.frame))];
        imageView.tag = idx;
        
        NSURL *url  =  [NSURL URLWithString:imageData[@"image_url"]];
        NSLog(@"%@",imageData[@"image_url"]);
        
        
        NSLog(@"Start Manager");
        
        
        
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
        
        
        (imageView.isUserInteractionEnabled) ? NSLog(@"Yes") : NSLog(@"No");
        imageView.userInteractionEnabled = YES;
        // add tap gesture to see large images.
        UITapGestureRecognizer *storeImageViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLargeImages)];
        [imageView addGestureRecognizer:storeImageViewTapGestureRecognizer];
        
        
        [cell.scrollView addSubview:imageView];
        cell.scrollView.clipsToBounds = NO;
    }];
}


-(void)setupOffersScrollView:(StoreTaxonHeaderViewCell *)cell {
    
    cell.offersScrollView.frame = CGRectMake(cell.offersScrollView.frame.origin.x, cell.offersScrollView.frame.origin.y, cell.offersScrollView.frame.size.width - 30, cell.offersScrollView.frame.size.height);
    cell.offersScrollView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(cell.offersContentView.bounds)/2 + 6);
    
    [self.offersarray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull imageData, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView *offerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.offersScrollView.frame) * idx + 3, 5, CGRectGetWidth(cell.offersScrollView.frame) - 6 , kStoreOffersViewHeight - (2*5))];
        offerImageView.contentMode = UIViewContentModeScaleToFill;
        offerImageView.userInteractionEnabled=YES;
        NSURL *url  =  [NSURL URLWithString:imageData[@"ImageUrl"]];
        [offerImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
        offerImageView.backgroundColor = [UIColor lightGrayColor];
        offerImageView.layer.cornerRadius = 5.f;
        offerImageView.layer.masksToBounds = YES;
        offerImageView.tag = idx;
        [cell.offersScrollView addSubview:offerImageView];
        cell.offersScrollView.clipsToBounds = NO;
        
        UITapGestureRecognizer *offersGestureRecognizer    = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(displayPopupView:)];
        
        [offerImageView addGestureRecognizer:offersGestureRecognizer];
    }];
    
}


-(void)displayPopupView:(UITapGestureRecognizer *)recognizer
{
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        UIImageView *offerView = (UIImageView *)[recognizer view];
        NSLog(@"Tapped on %ld", (long)offerView.tag);
        NSUInteger abc=offerView.tag;
        
        
        
        NSMutableDictionary *dict=[_offersarray objectAtIndex:abc];
        
        OffersPopViewController *offersPopVC = [self.storyboard instantiateViewControllerWithIdentifier:@"offersPopVC"];
        offersPopVC.DescriptionString=dict[@"Description"];
        offersPopVC.termsAndCondition=dict[@"Terms_Condition"];
        offersPopVC.PromoCodeString=dict[@"Code"];
        offersPopVC.imageurlString=dict[@"ImageUrl"];
        offersPopVC.validityString=dict[@"fromdate"];
        
        offersPopVC.contentSizeInPopup      =   CGSizeMake(self.view.frame.size.width - (2*20), 400);
        
//        [self setPresentationStyleForSelfController:self presentingController:offersPopVC];
//        [self presentViewController:offersPopVC animated:YES completion:nil];
        
        STPopupController *popupController  =   [[STPopupController alloc] initWithRootViewController:offersPopVC];
        popupController.navigationBarHidden     =   YES;
        [popupController presentInViewController:self];
        
    }
}


- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}


-(void)setupScrollViewFrame:(StoreTaxonHeaderViewCell *)cell {
    CGRect frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(0, 0, self.view.frame.size.width, kTaxonHeaderViewHeight_Pad);
    }
    else
        frame = CGRectMake(0, 0, self.view.frame.size.width, kTaxonHeaderViewHeight_Phone);
    
    cell.frame = frame;
    [cell layoutIfNeeded];
    
    
    
    
    CGRect scrollViewFrame      = cell.scrollView.frame;
    CGRect offerScrollViewFrame = cell.offersScrollView.frame;
    
    CGRect currentFrame         = self.view.frame;
    
    scrollViewFrame.size.width  = currentFrame.size.width;
    offerScrollViewFrame.size.width = currentFrame.size.width;
    
    cell.scrollView.frame       = scrollViewFrame;
    cell.offersScrollView.frame = offerScrollViewFrame;
}






#pragma mark - Scroll view Delegate


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    StoreTaxonHeaderViewCell *cell = (StoreTaxonHeaderViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (scrollView == cell.scrollView) {
        uint page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        
        [cell.pageControl setCurrentPage:page];
    }
    
}























#pragma mark - Not needed

/*
 - (void)tableView:(UITableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
 {
 NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
 
 RLMRealm *realm = [RLMRealm defaultRealm];
 StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
 
 
 if (taxons.count != 0) {
 TaxonModel *taxon = taxons[indexPath.subRow - 1];
 
 NSLog(@"Taxon ID %d", taxon.taxonId.intValue);
 
 ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
 productsVC.navigationTitleString = taxon.taxonName;
 productsVC.taxonProductsURL = [NSString stringWithFormat:@"http://%@/api/taxons/%d/products?token=%@", store.storeUrl, taxon.taxonId.intValue, kStoreTokenKey];
 [self.navigationController pushViewController:productsVC animated:YES];
 }
 
 }
 
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"UITableViewCell";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (!cell)
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 
 NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
 
 if (taxons.count != 0) {
 
 TaxonModel *taxon = taxons[indexPath.subRow - 1];
 cell.textLabel.text = taxon.taxonName;
 }
 
 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 
 return cell;
 }
 
 
 
 - (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
 {
 TaxonomyModel *taxonomy = self.taxonomies[indexPath.section];
 NSLog(@"%@",taxonomy);
 
 return taxonomy.taxons.count;
 }
 
 - (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
 {
 
 return NO;
 }
 
 */
@end
