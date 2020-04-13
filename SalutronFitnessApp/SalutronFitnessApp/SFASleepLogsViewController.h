//
//  SFASleepLogsViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 3/27/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFASleepLogsViewController : UIViewController

@property (weak, nonatomic) id delegate;

- (void)setContentsWithDate:(NSDate *)date;

@end
