//
//  SFAPulsewaveAnalysisViewController.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/20/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAPulsewaveAnalysisViewController.h"
#import "ECSlidingViewController.h"
#import "ErrorCodeToStringConverter.h"
#import "SFAGraph.h"
#import "SFALinePlot.h"
#import "SFAGraphTools.h"
#import "GraphView.h"

#define DISCOVER_TIMEOUT 3
#define MAX_X_RANGE 40
#define MAX_Y_RANGE 40
#define BUFFER_SIZE 100

@interface SFAPulsewaveAnalysisViewController () <SalutronSDKDelegate, SFALinePlotDelegate, UIAlertViewDelegate>
{
    CGFloat floatData[BUFFER_SIZE];
}

@property (strong, nonatomic) SalutronSDK *salutronSDK;
@property (assign, nonatomic) BOOL isPulsewaveEnabled;
@property (assign, nonatomic) NSUInteger deviceIndex;
@property (assign, nonatomic) NSUInteger ppgCount;
@property (strong, nonatomic) SFAGraph *graph;
@property (strong, nonatomic) SFALinePlot *linePlot;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (assign, nonatomic) NSUInteger rrInterval;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CGFloat pulseValue;
@property (strong, nonatomic) GraphView *customGraphView;
@property (assign, nonatomic) CGFloat ppgValue;

@end

@implementation SFAPulsewaveAnalysisViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isPulsewaveEnabled = NO;
    //[self initializeObjects];
    self.customGraphView = [[GraphView alloc] initWithFrame:self.graphView.bounds];
    [self.customGraphView setBackgroundColor:[UIColor whiteColor]];
    [self.customGraphView setFill:NO];
    [self.customGraphView setZeroLineStrokeColor:[UIColor whiteColor]];
    [self.customGraphView setLineWidth:2];
    [self.customGraphView setCurvedLines:YES];
    [self.customGraphView setStrokeColor:[UIColor blueColor]];
    [self.graphView addSubview:self.customGraphView];
    
    self.salutronSDK = [SalutronSDK sharedInstance];
    self.salutronSDK.delegate = nil;
    self.salutronSDK.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Properties

- (void)initializeObjects {
    /*self.dataSource = [[NSMutableArray alloc] init];
    
    self.graph = [SFAGraph graphWithGraphView:self.graphView];
    self.graphView.hostedGraph = self.graph;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.25f) length:CPTDecimalFromFloat(MAX_X_RANGE)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.25f) length:CPTDecimalFromFloat(MAX_Y_RANGE)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.hidden = YES;
    axisSet.yAxis.hidden = YES;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.0f;
    lineStyle.lineColor = [CPTColor blueColor];
    
    self.linePlot = [SFALinePlot linePlot];
    self.linePlot.dataDelegate = self;
    self.linePlot.dataLineStyle = lineStyle;
    self.linePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    [self.graph addPlot:self.linePlot toPlotSpace:plotSpace];*/
}

- (void)handlerPulsewaveTimer {
    static NSInteger ppgCount;
    /*static NSUInteger x;
    static CGFloat initialYValue = 1000.0f;
    
    CGFloat ppg = [[NSString stringWithFormat:@"%.2f", self.ppgValue] substringWithRange:NSMakeRange(0, 4)].floatValue;
    
    CGFloat y = [SFAGraphTools yWithMinY:0.0f
                                    maxY:initialYValue
                               minYRange:0.0f
                               maxYRange:MAX_Y_RANGE
                                  yValue:ppg];
    y += MAX_Y_RANGE / 2;
    
    if(x < MAX_X_RANGE) {
        x++;
    } else {
        [self.dataSource removeAllObjects];
        x = 0;
    }
    
    CGPoint point = CGPointMake(x, y);
    NSValue *value = [NSValue valueWithCGPoint:point];
    [self.dataSource addObject:value];
    
    [self.linePlot insertDataAtIndex:self.dataSource.count - 1 numberOfRecords:1];
    [self.linePlot reloadDataInIndexRange:NSMakeRange(0, self.dataSource.count)];
    self.ppgValue = 0;*/
    
    @try {
        [self.customGraphView setPoint:floatData[ppgCount]];
    }
    @catch (NSException *exception) {
    }
    
    ppgCount++;
    
    if(ppgCount >= BUFFER_SIZE) {
        ppgCount = 0;
    }
}

- (void)startPulsewaveStream {
    Status status = [self.salutronSDK retrieveConnectedDevice];
    
    if(status != NO_ERROR) {
        DDLogError(@"startPulsewaveStream error: %@", [ErrorCodeToStringConverter convertToString:status]);
    }
    
    [self.customGraphView resetGraph];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.183f
                                                  target:self
                                                selector:@selector(handlerPulsewaveTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (NSString *)_fixStringFormat:(NSString *)str
{
    NSMutableString *_fixedDataString = [[NSMutableString alloc] init];
    
    DDLogError(@"length == %i", str.length);
    str = (str.length < 8) ? [@"0" stringByAppendingString:str] : str;
    
    for (NSInteger i = 0; i < str.length; i+=2)
    {
        NSRange _stringRange    = NSMakeRange(i , 2);
        NSString *_extract      = [str substringWithRange:_stringRange];
        _extract                = [self reverseString:_extract];
        [_fixedDataString appendString:_extract];
    }
    
    return _fixedDataString;
}

- (NSString *)reverseString:(NSString *)str {
    NSMutableString *val = [NSMutableString string];
    
    for(NSInteger i=[str length] - 1;i>-1;i--) {
        NSRange range = NSMakeRange(i, 1);
        [val appendString:[str substringWithRange:range]];
    }
    return val;
}

#pragma mark - IBActions

- (IBAction)menuButtonPressed{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)enableDisablePulsewave {
    //[self.salutronSDK retrieveConnectedDevice];
    
    [self.salutronSDK clearDiscoveredDevice];
    
    if(self.isPulsewaveEnabled) {
        self.isPulsewaveEnabled = NO;
        [self.salutronSDK disableR500demo];
        [self.timer invalidate];
        self.barBtnEnableDisable.title = BUTTON_TITLE_ENABLE;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PULSEWAVE_SYNC_ALERT_TITLE
                                                        message:PULSEWAVE_SYNC_ALERT_MESSAGE
                                                       delegate:self
                                              cancelButtonTitle:BUTTON_TITLE_CANCEL
                                              otherButtonTitles:BUTTON_TITLE_CONTINUE, nil];
        [alert show];
    }
}

#pragma mark - SalutronSDKDelegate

- (void)didDisconnectDevice:(Status)status {
    self.isPulsewaveEnabled = NO;
    self.barBtnEnableDisable.title = BUTTON_TITLE_ENABLE;
    
    if(self.timer)
        [self.timer invalidate];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BUTTON_TITLE_DISCONNECT
                                                    message:LS_R500_DISCONNECTED
                                                   delegate:nil cancelButtonTitle:BUTTON_TITLE_OK
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status {
    if(numDevice > 0) {
        if(self.deviceIndex < numDevice) {
            [self.salutronSDK connectDevice:self.deviceIndex];
        }
    } else {
        if(self.timer)
            [self.timer invalidate];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BUTTON_TITLE_DEVICE
                                                        message:LS_R500_NOT_FOUND
                                                       delegate:nil
                                              cancelButtonTitle:BUTTON_TITLE_OK
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status {
    if(self.isPulsewaveEnabled) {
        [self.salutronSDK enableR500demo];
        self.barBtnEnableDisable.title = BUTTON_TITLE_DISABLE;
    } else {
        [self.salutronSDK disableR500demo];
    }
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status {
    if(numDevice > 0) {
        if(self.isPulsewaveEnabled) {
            self.isPulsewaveEnabled = NO;
            [self.salutronSDK disableR500demo];
        } else {
            self.isPulsewaveEnabled = YES;
            Status s = [self.salutronSDK enableR500demo];
            
            if(s != NO_ERROR) {
                DDLogError(@"didRetrieveConnectedDevice error:%@", [ErrorCodeToStringConverter convertToString:s]);
            }
        }
    } else {
        [self.salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    }
}

- (void)didGetHeartRate:(NSString *)heartrate withStatus:(Status)status {
    self.labelBPM.text = [NSString stringWithFormat:@"%i", [heartrate intValue]];
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    
}

- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status {
    
}

- (void)didGetRRInterval:(NSData *)RRInterval withStatus:(Status)status {
    DDLogError(@"%@", RRInterval);
    static NSUInteger ppg_count;
    //remove brackets from start and end of data string and white space
    unsigned char datatype[1];
    [RRInterval getBytes:datatype length:1];
    
    if(datatype[0] == 0) {
        NSString *_dataString   = [RRInterval.description regexReplaceWithPattern:@"[(^<)(>$)( )]"
                                                                         template:@""
                                                                          options:0];
        
        if(![_dataString isEmpty] &&
           _dataString.length > (8*8))
        {
            
            //Get optical points count
            NSRange _opticalPointsCountRange    = NSMakeRange(3, 1);
            NSInteger _opticalPointsCount       = [[_dataString substringWithRange:_opticalPointsCountRange] integerValue];
            
            //Remove optical point counter description (0008, 0009) from data string
            NSRange _dataRange  = NSMakeRange(4, _dataString.length - 4);
            _dataString = [_dataString substringWithRange:_dataRange];
            
            //Store optical points in array
            NSMutableArray *_opticalPoints  = [NSMutableArray array];
            for (NSInteger i = 0; i < _opticalPointsCount; i++)
            {
                NSRange _opticalPointRange  = NSMakeRange(i * 8, 8);
                NSString *_opticalPoint     = [_dataString substringWithRange:_opticalPointRange];
                [_opticalPoints addObject:_opticalPoint];
            }
            
            //Get graph point
            NSInteger temp_ram_01;
            NSInteger temp_ram_02;
            NSInteger temp_ram_03;
            NSInteger temp_ram_04;
            NSInteger float2;
            float float3 = 0; // prevent garbage value --JB
            
            for (NSString *float1 in _opticalPoints)
            {
                NSString *float_01 = [float1 substringWithRange:NSMakeRange(6,2)];
                sscanf([float_01 UTF8String],"%x",&temp_ram_01);
                NSString *float_02 = [float1 substringWithRange:NSMakeRange(4,2)];
                sscanf([float_02 UTF8String],"%x",&temp_ram_02);
                NSString *float_03 = [float1 substringWithRange:NSMakeRange(2,2)];
                sscanf([float_03 UTF8String],"%x",&temp_ram_03);
                NSString *float_04 = [float1 substringWithRange:NSMakeRange(0,2)];
                sscanf([float_04 UTF8String],"%x",&temp_ram_04);
                
                float2 = (temp_ram_01*0x1000000)+(temp_ram_02*0x10000)+(temp_ram_03*0x100)+temp_ram_04;
                float3 = float2;
                char *pul = (char *)&float2;
                char *pf = (char *)&float3;
                
                memcpy(pf, pul,sizeof(float));
            }
            
            floatData[ppg_count] = float3;
            ppg_count++;
            
            if(ppg_count >= BUFFER_SIZE) {
                ppg_count = 0;
            }
        }
    } else if(datatype[0] == 1) {
        unsigned char dataBytes[3];
        unsigned char low_ms,hi_ms;
        [RRInterval getBytes:dataBytes length:3];
        
        low_ms = dataBytes[1];
        hi_ms = dataBytes[2];
        
        DDLogError(@"low_ms: %i, hi_ms: %i, ms: %i", low_ms, hi_ms, hi_ms*0x100+low_ms);
        
        self.rrInterval = hi_ms*0x100+low_ms;
        self.ppgCount = 0;
    }
}

#pragma mark - SFALinePlotDelegate

- (NSInteger)numberOfPointsForLinePlot:(SFALinePlot *)linePlot {
    return self.dataSource.count;
}

- (CGPoint)linePlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index {
    NSValue *value = [self.dataSource objectAtIndex:index];
    CGPoint point = [value CGPointValue];
    return point;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"PulsewaveInsightsIdentifer";
    UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(cell1 == nil) {
        cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    switch (indexPath.row) {
        case 0:
            cell1.textLabel.text = @"Interbeat interval histogram";
            break;
        case 1:
            cell1.textLabel.text = @"Interbeat interval pointcare plot";
            break;
        case 2:
            cell1.textLabel.text = @"HRV Spectral Analysis";
            break;
        default:
            break;
    }
    
    return cell1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"Helvetica Neue" size:10]];
    label.text = @"PULSEWAVE INSIGHTS";
    [view addSubview:label];
    view.backgroundColor = [UIColor colorWithRed:200.0f/255.0f
                                           green:200.0f/255.0f
                                            blue:200.0f/255.0f
                                           alpha:1.0f];
    return view;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1)
        [self startPulsewaveStream];
}

@end
