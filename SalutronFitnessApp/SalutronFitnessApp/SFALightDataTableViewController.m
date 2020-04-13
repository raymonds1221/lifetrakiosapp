//
//  SFALightDataTableViewController.m
//  SalutronFitnessApp
//
//  Created by Patricia Cesar on 9/1/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFALightDataTableViewController.h"
#import "LightDataPointEntity+Data.h"
#import "LightDataPointEntity+GraphData.h"
#import "SFALightDataTableViewCell.h"
#import "StatisticalDataPointEntity+Data.h"
#import "DayLightAlertEntity+Data.h"
#import "TimeDate+Data.h"
#import "SFALightDataManager.h"

@interface SFALightDataTableViewController ()

@property (strong, nonatomic) NSArray *lightDataPointArray;

@end

@implementation SFALightDataTableViewController

static NSString * const cellID = @"CellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor blackColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"SFALightDataTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reloadDataWithDate:(NSDate *)date
{
    self.lightDataPointArray = [LightDataPointEntity lightDataPointsForDate:date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   // Return the number of rows in the section.
    return self.lightDataPointArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFALightDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[SFALightDataTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    LightDataPointEntity *entity = (LightDataPointEntity *)self.lightDataPointArray[indexPath.row];
    
    cell.indexLabel.text = [NSString stringWithFormat:@" index: %d", [entity.dataPointID intValue]];
    cell.sensorLabel.text = [NSString stringWithFormat:@" gain: %d", [entity.sensorGain intValue]];
    cell.wristDetection.text = [NSString stringWithFormat:@" wrist: %d", [entity.dataPoint.wristDetection boolValue]];
    cell.timeLabel.text = [NSString stringWithFormat:@" time: %@", [self timeForIndex:[entity.dataPoint.dataPointID intValue]]];
    //cell.threshold.text = [NSString stringWithFormat:@"threshold: %d", 350];
    
    cell.redLabel.text = [NSString stringWithFormat:@"red: %d", [entity.red intValue]];
    cell.greenLabel.text = [NSString stringWithFormat:@"green: %d", [entity.green intValue]];
    cell.blueLabel.text = [NSString stringWithFormat:@"blue: %d", [entity.blue intValue]];
    
    cell.redCoeffLabel.text = [NSString stringWithFormat:@"%d: %f", [entity.sensorGain intValue], [entity.redLightCoeff floatValue]];
    cell.greenCoeffLabel.text = [NSString stringWithFormat:@"%d: %f", [entity.sensorGain intValue], [entity.greenLightCoeff floatValue]];
    cell.blueCoeffLabel.text = [NSString stringWithFormat:@"%d: %f", [entity.sensorGain intValue], [entity.blueLightCoeff floatValue]];
    
    cell.redLuxLabel.text = [NSString stringWithFormat:@"%f LX", [entity redLux]];
    
    cell.greenLuxLabel.text = [NSString stringWithFormat:@"%f LX", [entity greenLux]];
    
    cell.blueLuxLabel.text = [NSString stringWithFormat:@"%f LX", [entity blueLux]];
    
    cell.allLuxLabel.text = [NSString stringWithFormat:@"%f LX", [entity allLux]];
    
    cell.redView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5f];
    cell.greenView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
    
    if ([SFALightDataManager isAmbientLight:[entity blueLux] lightColor:SFALightColorBlue]) {
        cell.blueView.backgroundColor = BLUE_LIGHT_LINE_COLOR;
    }
    else {
        cell.blueView.backgroundColor = BLUE_LIGHT_ARTIFICIAL_LINE_COLOR;
    }
    
    if ([SFALightDataManager isAmbientLight:[entity allLux] lightColor:SFALightColorAll]) {
        cell.allView.backgroundColor = ALL_LIGHT_LINE_COLOR;
    }
    else {
        cell.allView.backgroundColor = ALL_LIGHT_ARTIFICIAL_LINE_COLOR;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0f;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

- (NSString *)timeForIndex:(NSInteger)index
{
    NSInteger hour      = index / 6;
    NSInteger minute    = index - (hour * 6);
    hour                = (hour == 24) ? 0 : hour;
    
    TimeDate *_timeDate = [TimeDate getData];
    
    NSString *_time     = [NSString stringWithFormat:@"%i:%i0", hour, minute];
    NSDate *_dateTime   = [_time getDateFromStringWithFormat:@"HH:mm"];
    
    if (_timeDate.hourFormat == 0)
    {
        return [_dateTime getDateStringWithFormat:@"hh:mma"];
    }
    else
    {
        return [_dateTime getDateStringWithFormat:@"HH:mm"];
    }
    
    return nil;
}

@end
