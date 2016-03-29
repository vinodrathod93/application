//
//  StoreOptionsView.m
//  Neediator
//
//  Created by adverto on 12/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "StoreOptionsView.h"

@implementation StoreOptionsView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    
}


-(BOOL)favouriteStore {
    
    if ([self.favButton.imageView.image isEqual:[UIImage imageNamed:@"store_fav_filled"]]) {
        return YES;
    }
    else
        return NO;
}

-(void)setFavouriteStore:(BOOL)favouriteStore {
    if (favouriteStore) {
        [self.favButton setImage:[UIImage imageNamed:@"store_fav_filled"] forState:UIControlStateNormal];
    }
    else
        [self.favButton setImage:[UIImage imageNamed:@"store_fav"] forState:UIControlStateNormal];
}

@end
