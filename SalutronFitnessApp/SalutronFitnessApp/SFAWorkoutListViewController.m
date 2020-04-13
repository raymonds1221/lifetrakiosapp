//
//  SFAWorkoutListViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 1/13/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAWorkoutListViewController.h"
#import "SFAMainViewController.h"
#import "SFAWorkoutResultsScrollViewController.h"

#import "SFAWorkoutCell.h"

#import "WorkoutInfoEntity+Data.h"
#import "NSDate+Comparison.h"

@interface SFAWorkoutListViewController () <UITableViewDataSource, UITableViewDelegate, SFACalendarControllerDelegate>

@property (strong, nonatomic) NSArray *workouts;

@end

@implementation SFAWorkoutListViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:self.calendarController.selectedDate];

    if (self.parentViewController.parentViewController && self.calendarController.selectedDate.isToday) {
        [self enableNextDateButton:NO];
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.parentViewController.parentViewController) {
        [self enableNextDateButton:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"WorkoutListToWorkoutResultsScroll"])
    {
        SFAWorkoutResultsScrollViewController *viewController   = (SFAWorkoutResultsScrollViewController *)segue.destinationViewController;
        viewController.workoutIndex                             = self.tableView.indexPathForSelectedRow.row;
        viewController.workoutCount                             = self.workouts.count;
        
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.workouts.count > 0 ? self.workouts.count : 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (self.workouts.count > 0) {
            SFAWorkoutCell *cell    = [tableView dequeueReusableCellWithIdentifier:@"SFAWorkoutCell"];
            [cell setContentsWithWorkout:self.workouts[indexPath.row] workoutIndex:indexPath.row];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFANoWorkoutCell"];
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

#pragma mark - SFACalendarControllerDelegate Methods

- (void)calendarController:(SFAMainViewController *)calendarController didSelectDate:(NSDate *)date
{
    if([self.calendarController.selectedDate compareToDate:[NSDate date]] == NSOrderedDescending){
        self.calendarController.selectedDate = [NSDate date];
    }

    if (self.parentViewController.parentViewController && self.calendarController.selectedDate.isToday) {
        [self enableNextDateButton:NO];
    }
    else if(self.parentViewController.parentViewController) {
        [self enableNextDateButton:YES];
    }
    
    self.workouts = [WorkoutInfoEntity getWorkoutInfoWithDate:self.calendarController.selectedDate];
    
    [self.tableView reloadData];
}

- (void)enableNextDateButton:(BOOL)isEnabled{
    SFAMainViewController *mainViewController = (SFAMainViewController *)self.parentViewController.parentViewController;
    mainViewController.datePicker.nextDateButton.enabled = isEnabled;
}



@end
