//
//  BookingDIDatePicker.h
//  Neediator
//
//  Created by adverto on 06/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <DIDatepicker/DIDatepicker.h>

@interface BookingDIDatePicker : DIDatepicker

- (void)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)nextDatesCount;
- (void)fillCurrentWeek;
- (void)fillCurrentMonth;
- (void)fillCurrentYear;

@end
