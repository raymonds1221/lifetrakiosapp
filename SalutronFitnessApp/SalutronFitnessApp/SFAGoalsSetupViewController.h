//
//  SFAGoalsSetupViewController.h
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFASalutronCModelSync.h"

enum GOAL_TEXTFIELD {
    STEPS_TEXTFIELD = 0,
    DISTANCE_TEXTFIELD = 1,
    CALORIES_TEXTFIELD = 2,
    SLEEP_TEXTFIELD = 3,
    LIGHT_TEXTFIELD = 4
};
    
@interface SFAGoalsSetupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, SFASalutronSyncDelegate>

- (IBAction)menuButtonPressed:(id)sender;
- (IBAction)syncButtonPressed:(id)sender;

@end
