//
//  SFALiveHeartRateView.m
//  SalutronFitnessApp
//
//  Created by Raymond Sarmiento on 12/26/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFALiveHeartRateView.h"
#import "ErrorCodeToStringConverter.h"
#import "SFAGraph.h"
#import "SFALinePlot.h"
#import "SFAGraphTools.h"

#define DISCOVER_TIMEOUT 3
#define MAX_X_RANGE 40.0f
#define MAX_Y_RANGE 40.0f

@interface SFALiveHeartRateView () <SalutronSDKDelegate, SFALinePlotDelegate>

@property (strong, nonatomic) SalutronSDK *salutronSDK;
@property (assign, nonatomic) NSUInteger deviceIndex;
@property (assign, nonatomic) BOOL isR500Enabled;
@property (strong, nonatomic) SFAGraph *graph;
@property (strong, nonatomic) SFAGraphView *graphView;
@property (strong, nonatomic) SFALinePlot *linePlot;
@property (assign, nonatomic) NSUInteger heartRate;
@property (assign, nonatomic) NSUInteger rrInterval;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation SFALiveHeartRateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Private Methods & Properties

- (SalutronSDK *)salutronSDK {
    if(!_salutronSDK) {
        _salutronSDK = [SalutronSDK sharedInstance];
        _salutronSDK.delegate = self;
    }
    return _salutronSDK;
}

- (void)initializeObjects {
    self.dataSource = [[NSMutableArray alloc] init];
    
    self.graphView = [[SFAGraphView alloc] init];
    [self addSubview:self.graphView];
    self.graphView.frame = self.bounds;
    self.graph = [SFAGraph graphWithGraphView:self.graphView];
    self.graphView.hostedGraph = self.graph;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(MAX_X_RANGE)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(MAX_Y_RANGE)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.hidden = YES;
    axisSet.yAxis.hidden = YES;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blueColor];
    
    self.linePlot = [SFALinePlot linePlot];
    self.linePlot.dataDelegate = self;
    self.linePlot.dataLineStyle = lineStyle;
    self.linePlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    [self.graph addPlot:self.linePlot toPlotSpace:plotSpace];
}

- (void)handleHeartRateTimer {
    static NSUInteger x;
    CGFloat y = [SFAGraphTools yWithMinY:0.0f
                                    maxY:1400
                               minYRange:0.0f
                               maxYRange:MAX_Y_RANGE / 2
                                  yValue:self.rrInterval];
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
    self.rrInterval = 0;
}

#pragma mark - Public Methods

- (void)startHeartRateLiveStream {
    [self.salutronSDK clearDiscoveredDevice];
    Status status = [self.salutronSDK retrieveConnectedDevice];
    
    if(status != NO_ERROR) {
        DDLogError(@"startHeartRateLiveStream error: %@", [ErrorCodeToStringConverter convertToString:status]);
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                  target:self
                                                selector:@selector(handleHeartRateTimer)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)endHeartRateLiveStream {
    if(self.isR500Enabled) {
        if(self.timer)
            [self.timer invalidate];
        
        Status status = [self.salutronSDK disableR500demo];
        
        DDLogError(@"disableR500demo status: %@", [ErrorCodeToStringConverter convertToString:status]);
        
        if(status == NO_ERROR) {
            self.isR500Enabled = NO;
            if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_Move_C300 ||
                [SFAUserDefaultsManager sharedManager].watchModel == WatchModel_Move_C300_Android ||
                [SFAUserDefaultsManager sharedManager].watchModel== WatchModel_Zone_C410 ||
                [SFAUserDefaultsManager sharedManager].watchModel== WatchModel_R420) {
                [self.salutronSDK commDone];
            }
        }
    }
}

#pragma mark - SalutronSDKDelegate

- (void)didDiscoverDevice:(int)numDevice withStatus:(Status)status {
    Status s = [self.salutronSDK connectDevice:self.deviceIndex];
    
    DDLogError(@"didDiscoverDevice status: %@", [ErrorCodeToStringConverter convertToString:s]);
}

- (void)didConnectAndSetupDeviceWithStatus:(Status)status {
    NSString *macAddress = nil;
    Status s0 = [self.salutronSDK getModelNumber];
    DDLogError(@"getModelNumber status: %@", [ErrorCodeToStringConverter convertToString:s0]);
    
    if(macAddress != nil) {
        Status s1 = [self.salutronSDK getModelNumber];
        DDLogError(@"getModelNumber status: %@", [ErrorCodeToStringConverter convertToString:s1]);
    }
    /*NSInteger model = [self.salutronSDK getModelNumber];
    
    if(model != WatchModel_R500) {
        [self.salutronSDK disconnectDevice];
        self.deviceIndex++;
        [self.salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    } else {
        Status s = [self.salutronSDK enableR500demo];
        
        DDLogError(@"enableR500demo status: %@", [ErrorCodeToStringConverter convertToString:s]);
        
        if(s == NO_ERROR) {
            self.isR500Enabled = YES;
        }
    }*/
}

- (void)didRetrieveConnectedDevice:(int)numDevice withStatus:(Status)status {
    if(numDevice > 0) {
        NSString *macAddress = nil;
        Status s0 = [self.salutronSDK getMacAddress:&macAddress];
        
        DDLogInfo(@"\n---------------> STATUS: %@ ---> MAC ADDRESS : %@ ---> MAC ADDRESS STATUS : %@\n", Status_toString[status], macAddress, [ErrorCodeToStringConverter convertToString:s0]);
        
        if(s0 == NO_ERROR) {
            [self.salutronSDK enableR500demo];
        } else {
            [self.salutronSDK discoverDevice:DISCOVER_TIMEOUT];
        }
    } else {
        [self.salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    }
}

- (void)didDisconnectDevice:(Status)status {
    DDLogError(@"device disconnected :P");
    self.isR500Enabled = NO;
}

- (void)didGetHeartRate:(NSString *)heartrate withStatus:(Status)status {
    DDLogError(@"heart rate: %i", [heartrate integerValue]);
    self.heartRate = [heartrate integerValue];
}

- (void)didGetRRInterval:(NSData *)RRInterval withStatus:(Status)status {
    static NSUInteger ppg_count;
    unsigned char datatype[1];
    [RRInterval getBytes:datatype length:1];
    
    if(datatype[0] == 0)
    {
        ppg_count++;
    }
    else if(datatype[0] == 1)
    {
        unsigned char dataBytes[3];
        unsigned char low_ms,hi_ms;
        [RRInterval getBytes:dataBytes length:3];
        
        low_ms = dataBytes[1];
        hi_ms = dataBytes[2];
        
        DDLogError(@"low_ms: %i, hi_ms: %i, ms: %i", low_ms, hi_ms, hi_ms*0x100+low_ms);
        self.rrInterval = hi_ms*0x100+low_ms;
    }
}

- (void)didGetBattLevel:(NSString *)battLevelString withStatus:(Status)status
{
    
}

- (void)didGetModelNumber:(ModelNumber *)modelNumber withStatus:(Status)status {
    if(modelNumber.number != WatchModel_R500) {
        if ([SFAUserDefaultsManager sharedManager].watchModel == WatchModel_Move_C300 ||
            [SFAUserDefaultsManager sharedManager].watchModel == WatchModel_Move_C300_Android ||
            [SFAUserDefaultsManager sharedManager].watchModel== WatchModel_Zone_C410 ||
            [SFAUserDefaultsManager sharedManager].watchModel== WatchModel_R420) {
            [self.salutronSDK commDone];
        }
        self.deviceIndex++;
        [self.salutronSDK discoverDevice:DISCOVER_TIMEOUT];
    } else {
        Status s = [self.salutronSDK enableR500demo];
        
        DDLogError(@"enableR500demo status: %@", [ErrorCodeToStringConverter convertToString:s]);
        
        if(s == NO_ERROR) {
            self.isR500Enabled = YES;
        }
    }
}

#pragma mark - SFALinePlotDelegate

- (NSInteger)numberOfPointsForLinePlot:(SFALinePlot *)linePlot {
    return self.dataSource.count;
}

- (CGPoint)linePlot:(SFALinePlot *)linePlot pointAtIndex:(NSInteger)index {
    NSValue *value = self.dataSource[index];
    return [value CGPointValue];
}

@end
