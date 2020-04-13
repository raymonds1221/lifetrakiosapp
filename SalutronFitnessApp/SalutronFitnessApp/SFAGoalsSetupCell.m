//
//  SFAGoalsSetupCell.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 11/14/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAGoalsSetupCell.h"

@interface SFAGoalsSetupCell()

//@property (weak, nonatomic) UITapGestureRecognizer *tap;

@end

@implementation SFAGoalsSetupCell

@synthesize goalName            = _goalName;
@synthesize goalCurrentValue    = _goalCurrentValue;
@synthesize goalMaxValue        = _goalMaxValue;
@synthesize goalMinValue        = _goalMinValue;
@synthesize goalUnit            = _goalUnit;
@synthesize cellSeparator       = _cellSeparator;

@synthesize slider              = _slider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.goalName = [[UILabel alloc] init];
        self.goalName.textAlignment = NSTextAlignmentLeft;
        self.goalName.font = [UIFont systemFontOfSize:17];
        self.goalName.backgroundColor = [UIColor clearColor];
        
        self.goalCurrentValue = [[UITextField alloc] init];
        self.goalCurrentValue.textAlignment = NSTextAlignmentLeft;
        self.goalCurrentValue.font = [UIFont systemFontOfSize:48];
        self.goalCurrentValue.backgroundColor = [UIColor clearColor];
        
        self.goalUnit = [[UILabel alloc] init];
        self.goalUnit.textAlignment = NSTextAlignmentLeft;
        self.goalUnit.font = [UIFont systemFontOfSize:36];
        self.goalUnit.backgroundColor = [UIColor clearColor];
        
        self.goalMaxValue = [[UILabel alloc] init];
        self.goalMaxValue.textAlignment = NSTextAlignmentRight;
        self.goalMaxValue.font = [UIFont systemFontOfSize:12];
        self.goalMaxValue.backgroundColor = [UIColor clearColor];
        
        self.goalMinValue = [[UILabel alloc] init];
        self.goalMinValue.textAlignment = NSTextAlignmentLeft;
        self.goalMinValue.font = [UIFont systemFontOfSize:12];
        self.goalMinValue.backgroundColor = [UIColor clearColor];
        
        self.slider = [[UISlider alloc] init];
        [self.slider setEnabled:YES];
        
        self.cellSeparator = [[UIView alloc] init];
        self.cellSeparator.backgroundColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
        
        [self addSubview:self.goalName];
        [self addSubview:self.goalCurrentValue];
        [self addSubview:self.goalUnit];
        [self addSubview:self.goalMaxValue];
        [self addSubview:self.goalMinValue];
        [self addSubview:self.slider];
        [self addSubview:self.cellSeparator];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect contentRect = self.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat boundsY = contentRect.origin.y;
    CGSize textSize;
    CGRect frame;
    
    frame = CGRectMake(boundsX+10, boundsY+15, contentRect.size.width-20, 20);
    self.goalName.frame = frame;
    textSize = [self.goalCurrentValue sizeThatFits:CGSizeMake(contentRect.size.width-20, 50)];
    
    int width = textSize.width;
    
    UIFont *font = [UIFont systemFontOfSize:48];
    
    if ([self.goalName.text isEqualToString:LS_STEPS_ALL_CAPS]) {
        width = font.pointSize*5/2 + 20;
    }
    else if ([self.goalName.text isEqualToString:[LS_CALORIES uppercaseString]] ||
             [self.goalName.text isEqualToString:[LS_DISTANCE uppercaseString]]) {
        NSArray *versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
        if([versionComponents[0] integerValue] >= 9){
            
        }
        else{
            width = font.pointSize*4/2;
        }
    }
    /*
    else if ([self.goalName.text isEqualToString:[LS_DISTANCE uppercaseString]]) {
        //width = font.pointSize*5/2;
    }
    */
    frame = CGRectMake(boundsX+10, self.goalName.frame.origin.y+self.goalName.frame.size.height, width+10, textSize.height);
    self.goalCurrentValue.frame = frame;
    
    [self.goalCurrentValue sizeToFit];
    frame = CGRectMake(self.goalCurrentValue.frame.origin.x+self.goalCurrentValue.frame.size.width-3, self.goalCurrentValue.frame.origin.y+7, 150, 50);
    self.goalUnit.frame = frame;
    
    frame = CGRectMake(boundsX+10, self.goalCurrentValue.frame.origin.y+self.goalCurrentValue.frame.size.height+5, contentRect.size.width-20, 20);
    self.slider.frame = frame;

    frame = CGRectMake(boundsX+10, self.slider.frame.origin.y+self.slider.frame.size.height, 70, 14);
    self.goalMinValue.frame = frame;
    
    frame = CGRectMake(contentRect.size.width-80, self.goalMinValue.frame.origin.y, 70, 14);
    self.goalMaxValue.frame = frame;
    
    frame = CGRectMake(boundsX+10, contentRect.size.height-1, contentRect.size.width-10, 1);
    self.cellSeparator.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
