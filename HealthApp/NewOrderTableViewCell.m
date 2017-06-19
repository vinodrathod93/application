//
//  NewOrderTableViewCell.m
//  Neediator
//
//  Created by Vinod Rathod on 17/04/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "NewOrderTableViewCell.h"
#import "CancelOrderView.h"

@implementation NewOrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    self.pendingCancelView.backgroundColor      =   [UIColor whiteColor];
    self.inProcessStatusView.backgroundColor    =   [UIColor whiteColor];
    self.completedRRView.backgroundColor        =   [UIColor whiteColor];
    self.completedReorderView.backgroundColor   =   [UIColor whiteColor];
    self.cancelledDetailView.backgroundColor    =   [UIColor whiteColor];
    
    self.pendingCancelView.hidden       =   YES;
    self.inProcessStatusView.hidden     =   YES;
    self.completedReorderView.hidden    =   YES;
    self.completedRRView.hidden         =   YES;
    self.cancelledDetailView.hidden     =   YES;
    
    self.itemsHeightConstraint.constant =   0.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setExpand:(BOOL)expand {
    if (expand) {
        [UIView animateWithDuration:0.3 animations:^{
            self.itemsHeightConstraint.constant =   150.0;
        }];
        
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            self.itemsHeightConstraint.constant =   0.0;
        }];
        
    }
}


-(void)setPendingCancelExpand:(BOOL)pendingCancelExpand {
    if (pendingCancelExpand) {
        [UIView animateWithDuration:0.33 animations:^{
            self.actionViewHeightConstraint.constant    =   134;
        }];
    }
    else {
        [UIView animateWithDuration:0.33 animations:^{
            self.actionViewHeightConstraint.constant    =   0;
        }];
    }
}


-(void)setOrderStage:(NSUInteger)orderStage {
    switch (orderStage) {
        case 1:
        {
            self.pendingCancelView.hidden       =   YES;
            self.inProcessStatusView.hidden     =   NO;
            self.completedReorderView.hidden    =   YES;
            self.completedRRView.hidden         =   YES;
            self.cancelledDetailView.hidden     =   YES;
        }
            break;
            
        case 2: {
            self.pendingCancelView.hidden       =   YES;
            self.inProcessStatusView.hidden     =   YES;
            self.completedReorderView.hidden    =   YES;
            self.completedRRView.hidden         =   NO;
            self.cancelledDetailView.hidden     =   YES;
        }
            break;
            
        case 3: {
            self.pendingCancelView.hidden       =   YES;
            self.inProcessStatusView.hidden     =   YES;
            self.completedReorderView.hidden    =   YES;
            self.completedRRView.hidden         =   YES;
            self.cancelledDetailView.hidden     =   NO;
        }
            break;
            
        case 0: {
            self.pendingCancelView.hidden       =   NO;
            self.inProcessStatusView.hidden     =   YES;
            self.completedReorderView.hidden    =   YES;
            self.completedRRView.hidden         =   YES;
            self.cancelledDetailView.hidden     =   YES;
        }
            break;
    }
}


- (IBAction)dropdownTapped:(UIButton *)sender {
    
    if (sender.isSelected) {
        
        
        [UIView animateWithDuration:0.3 animations:^{
            self.itemsHeightConstraint.constant =   0.0;
        }];
        
        self.expandAction(NO, self);
    }
    else {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.itemsHeightConstraint.constant =   150.0;
        }];
        
        self.expandAction(YES, self);
    }
    
    sender.selected = !sender.selected;
}

- (IBAction)storeLinkTapped:(id)sender {
}

- (IBAction)referenceLinkTapped:(id)sender {
}
- (IBAction)inProcessCancelTapped:(id)sender {
}
- (IBAction)inProcessTrackTapped:(id)sender {
}
- (IBAction)cancelledDetailTapped:(id)sender {
}
- (IBAction)completedReorderTapped:(id)sender {
}
- (IBAction)completedReplaceTapped:(id)sender {
}
- (IBAction)completedReturnTapped:(id)sender {
}
- (IBAction)pendingCancelTapped:(UIButton *)sender {
    
    
    if (sender.isSelected) {
        [UIView animateWithDuration:0.33 animations:^{
            self.actionViewHeightConstraint.constant    =   0;
        }];
        
        for (UIView *view in self.actionView.subviews) {
            [view removeFromSuperview];
        }
        
        self.pendingCancelAction(NO, self);
    }
    else {
        
        
        [UIView animateWithDuration:0.33 animations:^{
            self.actionViewHeightConstraint.constant    =   134;
        }];
        
        CancelOrderView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderView" owner:self options:nil] firstObject];
        
        [self.actionView addSubview:cancelView];
        cancelView.frame = CGRectMake(0, 0, self.frame.size.width, 134);
        
        
        
        
        self.pendingCancelAction(YES, self);
        
    }
    
    sender.selected = !sender.selected;
    
}
@end
