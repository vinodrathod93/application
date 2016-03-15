//
//  UploadPrescriptionCellView.m
//  Neediator
//
//  Created by adverto on 14/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "UploadPrescriptionCellView.h"

@implementation UploadPrescriptionCellView

- (void)awakeFromNib {
    // Initialization code
    
    
    self.backgroundColor = [UIColor clearColor];
    
    self.uploadPrsView.layer.cornerRadius = 12.f;
    self.uploadPrsView.layer.masksToBounds = YES;
    
    self.quickOrderView.layer.cornerRadius = 12.f;
    self.quickOrderView.layer.masksToBounds = YES;
    
}


@end
