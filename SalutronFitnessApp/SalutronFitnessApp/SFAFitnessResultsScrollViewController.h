//
//  SFACaloriesScrollViewController.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/2/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFAFitnessResultsViewController.h"

@interface SFAFitnessResultsScrollViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIView         *leftFitnessResultsView;
@property (weak, nonatomic) IBOutlet UIView         *centerFitnessResultsView;
@property (weak, nonatomic) IBOutlet UIView         *rightFitnessResultsView;

@property (readwrite, nonatomic) SFAGraphType       graphType;

@end
