//
//  InterfaceController.h
//  Neediator-AppleWatch Extension
//
//  Created by adverto on 04/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *tableview;
@end
