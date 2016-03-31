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
    
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.deleteButton.layer.cornerRadius = self.deleteButton.frame.size.width;
        self.deleteButton.layer.masksToBounds = YES;
        
        
        self.pContentView.backgroundColor = [NeediatorUtitity defaultColor];
        self.pContentView.userInteractionEnabled = YES;
        self.pContentView.layer.cornerRadius = 5.f;
        self.pContentView.layer.masksToBounds = YES;
    }
    return self;
}


@end
