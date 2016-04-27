//
//  NATextView.h
//  Neediator Admin
//
//  Created by Vinod Rathod on 21/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface NATextView : UITextView

@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
