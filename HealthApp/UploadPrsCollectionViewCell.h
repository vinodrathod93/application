//
//  UploadPrsCollectionViewCell.h
//  Neediator
//
//  Created by adverto on 31/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadPrsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *pImageView;
@property (weak, nonatomic) IBOutlet UIView *pContentView;

-(void)hideDeleteButton;

@end
