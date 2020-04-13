//
//  SFAMenuCell.h
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/21/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFAMenuCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView    *image;
@property (weak, nonatomic) IBOutlet UILabel        *label;
@property (weak, nonatomic) IBOutlet UIView         *separator;

- (void)setContentsWithImage:(UIImage *)image label:(NSString *)label withSeparator:(BOOL)withSeparator;

//@property (strong, nonatomic) UIImageView *icon;
//@property (strong, nonatomic) UILabel *text;
//@property (strong, nonatomic) UIView *line;

@end
