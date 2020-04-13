//
//  SFANotesViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/2/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFANotesViewControllerDelegate;

@interface SFANotesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView                 *textView;
@property (weak, nonatomic) id <SFANotesViewControllerDelegate> delegate;

- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end

@protocol SFANotesViewControllerDelegate <NSObject>

- (void)notesViewController:(SFANotesViewController *)viewController didAddNote:(NSString *)note;

@end