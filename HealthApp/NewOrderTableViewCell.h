//
//  NewOrderTableViewCell.h
//  Neediator
//
//  Created by Vinod Rathod on 17/04/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewOrderTableViewCell;

typedef void(^ExpandCollapseAction)(BOOL expand, NewOrderTableViewCell *cell);
//typedef void(^ExpandCollapseAction)(BOOL expand, NewOrderTableViewCell *cell);


@interface NewOrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *referenceNoButton;
@property (weak, nonatomic) IBOutlet UIButton *storeButton;
@property (weak, nonatomic) IBOutlet UIButton *dropdownButton;

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *separator;

@property (weak, nonatomic) IBOutlet UITextView *itemsTextview;

@property (weak, nonatomic) IBOutlet UIView *inProcessStatusView;
@property (weak, nonatomic) IBOutlet UIView *cancelledDetailView;
@property (weak, nonatomic) IBOutlet UIView *completedReorderView;
@property (weak, nonatomic) IBOutlet UIView *completedRRView;
@property (weak, nonatomic) IBOutlet UIView *pendingCancelView;

@property (weak, nonatomic) IBOutlet UIButton *inProcessCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *inProcessTrackButton;
@property (weak, nonatomic) IBOutlet UILabel *inProcessStatusLabel;

@property (weak, nonatomic) IBOutlet UIButton *pendingCancelButton;

@property (weak, nonatomic) IBOutlet UIButton *completedReorderButton;
@property (weak, nonatomic) IBOutlet UIButton *completedReplaceButton;
@property (weak, nonatomic) IBOutlet UIButton *completedReturnButton;
@property (weak, nonatomic) IBOutlet UILabel *completedRRValidityLabel;


@property (weak, nonatomic) IBOutlet UIButton *cancelledDetailButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemsHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionViewHeightConstraint;

@property (nonatomic) ExpandCollapseAction expandAction;
@property (nonatomic) ExpandCollapseAction pendingCancelAction;


@property (nonatomic) BOOL expand;
@property (nonatomic) BOOL pendingCancelExpand;

@property (nonatomic) NSUInteger orderStage;

@end
