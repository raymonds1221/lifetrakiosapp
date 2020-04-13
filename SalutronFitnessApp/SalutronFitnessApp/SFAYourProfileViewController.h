//
//  SFAYourProfileViewController.h
//  SalutronFitnessApp
//
//  Created by John Dwaine Alingarog on 12/10/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ProfileTypeDefault1,
    ProfileTypeDefault2,
    ProfileTypeDefault3,
    ProfileTypeWeight,
    ProfileTypeHeight,
    ProfileTypeBirth,
    ProfileTypeGender
}ProfileType;

@protocol SFAYourProfileViewControllerDelegate;

@interface SFAYourProfileViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) id <SFAYourProfileViewControllerDelegate> delegate;

@end

@protocol SFAYourProfileViewControllerDelegate <NSObject>

- (void)didPressSaveInYourProfileViewController:(SFAYourProfileViewController *)viewController;
- (void)didPressCancelInYourProfileViewController:(SFAYourProfileViewController *)viewController;

@end