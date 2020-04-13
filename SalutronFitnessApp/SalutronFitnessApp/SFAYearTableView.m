//
//  SFAYearTableView.m
//  SalutronFitnessApp
//
//  Created by John Bennedict Lorenzo on 12/17/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAYearTableView.h"

static NSInteger const kEpochYear = 1970;

@interface SFAYearTableView () <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_years;
}
@end

@implementation SFAYearTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)didMoveToSuperview
{
    self.delegate = self;
    self.dataSource = self;
    
    _years = [NSMutableArray array];
    
    //Get Current Year into i2
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int i2  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    //Create Years Array from 1960 to This year
    _years = [[NSMutableArray alloc] init];
    for (int i=i2; i>=kEpochYear; --i) {
        [_years addObject:[NSString stringWithFormat:@"%d",i]];
    }
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_years count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const Identifier = @"CELL";
    
    UITableViewCell *cell = nil;
    cell = [self dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = [_years objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_selectDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
        [_selectDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
