//
//  SFAHelpViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/16/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    SFASettingsTypeAboutMe          = 0,
    SFASettingsTypePreference       = 1,
    SFASettingsTypeNotification     = 2,
    SFASettingsTypeCompatibleApps   = 3,
    SFASettingsTypeHelp             = 4
}SFASettingsType;

@interface SFAHelpViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>



@end
