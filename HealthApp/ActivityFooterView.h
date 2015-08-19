//
//  ActivityFooterView.h
//  Chemist Plus
//
//  Created by adverto on 17/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityFooterView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end
