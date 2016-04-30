//
//  ListingOptionsCell.m
//  Neediator
//
//  Created by adverto on 30/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingOptionsCell.h"
#import "UploadPrescriptionCellView.h"

@implementation ListingOptionsCell

- (void)awakeFromNib {
    [super awakeFromNib];

//    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCategoryView:(UIView *)categoryView {
    
    
    if ([self.contentView.subviews containsObject:categoryView]) {
        NSLog(@"this view already contains");
    }
    else {
        [self.contentView addSubview:categoryView];
    }
}



@end
