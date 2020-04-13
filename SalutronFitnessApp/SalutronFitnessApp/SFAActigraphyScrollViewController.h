//
//  SFAActigraphyScrollViewController.h
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/11/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAActigraphyScrollViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *leftActigraphy;
@property (weak, nonatomic) IBOutlet UIView *centerActigraphy;
@property (weak, nonatomic) IBOutlet UIView *rightActigraphy;

@property (readwrite, nonatomic) BOOL isActigraphy;

@end
