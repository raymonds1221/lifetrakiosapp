//
//  SFADashboardSleepCell.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 11/15/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFADashboardSleepCell.h"

@implementation SFADashboardSleepCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    if (self.cellTitle.text) {
        if (![self.cellTitle.text isEqualToString:@""]) {
            if (LANGUAGE_IS_FRENCH) {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:self.cellTitle.text];
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.alignment = NSTextAlignmentLeft;
                paragraphStyle.lineSpacing = 0.25f;
                paragraphStyle.minimumLineHeight = 10.0f;
                paragraphStyle.maximumLineHeight = 15.0f;
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                
                [title addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, title.length)];
                
                self.cellTitle.text = @"";
                self.cellTitle.attributedText = title;
            }
        }
    }
}

- (void)setContentsWithIntValue:(float)value goal:(float)goal
{
    int hours           = value / 60;
    int minutes         = floorf(fmodf(value, 60.0f));
    self.hours.text     = [NSString stringWithFormat:@"%i", hours];
    self.minutes.text   = [NSString stringWithFormat:@"%i", minutes];
    
    [self setProgressViewWithValue:value goal:goal];
}

- (void)setContentsWithHours:(NSInteger)hours minutes:(NSInteger)minutes
{
    self.hours.text     = [NSString stringWithFormat:@"%i", hours];
    self.minutes.text   = [NSString stringWithFormat:@"%i", minutes];
}

@end
