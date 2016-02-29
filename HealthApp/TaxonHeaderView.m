//
//  TaxonHeaderView.m
//  Neediator
//
//  Created by adverto on 27/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "TaxonHeaderView.h"

@implementation TaxonHeaderView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
    self.uploadPrescriptionButton.layer.cornerRadius    = 5.f;
    self.quickOrderButton.layer.cornerRadius            = 5.f;
    
}

@end
