//
//  UploadPrsCollectionViewCell.m
//  Neediator
//
//  Created by adverto on 31/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "UploadPrsCollectionViewCell.h"

@implementation UploadPrsCollectionViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.deleteButton.layer.cornerRadius = 15.f;
    self.deleteButton.layer.borderColor = [UIColor redColor].CGColor;
    self.deleteButton.layer.borderWidth = 0.7f;
    self.deleteButton.layer.masksToBounds = YES;
    
    
    self.pContentView.backgroundColor = [NeediatorUtitity defaultColor];
    self.pContentView.userInteractionEnabled = YES;
    self.pContentView.layer.cornerRadius = 5.f;
    self.pContentView.layer.masksToBounds = YES;
}


-(void)hideDeleteButton
{
    self.deleteButton.hidden = YES;
}

-(void)showDeleteButton {
    self.deleteButton.hidden = NO;
}

@end
