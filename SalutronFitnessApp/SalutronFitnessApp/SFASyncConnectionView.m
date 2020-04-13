//
//  SFASyncConnectionView.m
//  SalutronFitnessApp
//
//  Created by Dana Elisa Nicolas on 12/9/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFASyncConnectionView.h"
#import "Constants.h"

@interface SFASyncConnectionView()
{
    NSNumber *_isArrow;
    BOOL     _isAnimating;
    
    NSArray *_syncImages;
}

@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UILabel *syncLabel;
@property (strong, nonatomic) UIImageView *syncImage;
@property (strong, nonatomic) UILabel *syncReminder;
@property (strong, nonatomic) UIButton *tryAgain;

@end

@implementation SFASyncConnectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor whiteColor];
        
        /*self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 64)];
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
        UINavigationItem *navItems = [[UINavigationItem alloc] initWithTitle:@"LifeTrak"];
        [navItems setLeftBarButtonItem:cancel];
        
        NSArray *barItemArray = [[NSArray alloc]initWithObjects:navItems,nil];

        [self.navBar setItems:barItemArray];*/
        
        self.syncImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ll_preloader_default.png"]];
        self.syncImage.center = CGPointMake(frame.size.width*0.5, frame.size.height*0.36); // 0.45
        
        self.syncLabel = [[UILabel alloc] init];
        self.syncLabel.textAlignment = NSTextAlignmentCenter;
        self.syncLabel.numberOfLines = 0;
        self.syncLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.syncLabel.minimumScaleFactor = 0.4f;
        self.syncLabel.font = [UIFont systemFontOfSize:12];
        
        NSInteger width = frame.size.width - 100;
        self.syncLabel.frame = CGRectMake(0, 0, width, 48);
        self.syncLabel.center = CGPointMake(frame.size.width*0.5, frame.size.height*0.20); // 0.32
        
        // offset height from 0.23 to 0.15
        
        self.syncReminder = [[UILabel alloc] init];
        self.syncReminder.textAlignment = NSTextAlignmentLeft;
        self.syncReminder.lineBreakMode = NSLineBreakByWordWrapping;
        self.syncReminder.font = [UIFont systemFontOfSize:13];
        self.syncReminder.frame = CGRectMake(40, 0, frame.size.width-80, 100);
        self.syncReminder.center = CGPointMake(frame.size.width*0.53, frame.size.height*0.53); // 0.58
        self.syncReminder.hidden = YES;
        self.syncReminder.numberOfLines = 0;
        self.syncReminder.text = SETUP_ALERT_SYNC_FAILED_MESSAGE;
        
        self.tryAgain = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.tryAgain setTitle:LS_TRY_AGAIN forState:UIControlStateNormal];
//        [self.tryAgain setImage:[UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_6tryagainbutton.png"] forState:UIControlStateNormal];
        self.tryAgain.frame = CGRectMake(0, 0, 230, 40);
        self.tryAgain.center = CGPointMake(frame.size.width/2, frame.size.height*0.67); //0.72
        self.tryAgain.hidden = YES;
        self.tryAgain.userInteractionEnabled = NO;
        [self.tryAgain addTarget:self action:@selector(tryAgainButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.navBar];
        [self addSubview:self.syncImage];
        [self addSubview:self.syncLabel];
        [self addSubview:self.syncReminder];
        [self addSubview:self.tryAgain];
        
        _isArrow = [NSNumber numberWithBool:NO];
        _isAnimating = NO;

        _syncImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_radar_01.png"], [UIImage imageNamed:@"ll_preloader_radar_02.png"], [UIImage imageNamed:@"ll_preloader_radar_03.png"], [UIImage imageNamed:@"ll_preloader_radar_04.png"], [UIImage imageNamed:@"ll_preloader_radar_05.png"], [UIImage imageNamed:@"ll_preloader_radar_06.png"], [UIImage imageNamed:@"ll_preloader_radar_07.png"], [UIImage imageNamed:@"ll_preloader_radar_08.png"], [UIImage imageNamed:@"ll_preloader_radar_09.png"], [UIImage imageNamed:@"ll_preloader_radar_10.png"], [UIImage imageNamed:@"ll_preloader_radar_11.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_radar_01.png"], [UIImage imageNamed:@"ll_preloader_radar_02.png"], [UIImage imageNamed:@"ll_preloader_radar_03.png"], [UIImage imageNamed:@"ll_preloader_radar_04.png"], [UIImage imageNamed:@"ll_preloader_radar_05.png"], [UIImage imageNamed:@"ll_preloader_radar_06.png"], [UIImage imageNamed:@"ll_preloader_radar_07.png"], [UIImage imageNamed:@"ll_preloader_radar_08.png"], [UIImage imageNamed:@"ll_preloader_radar_09.png"], [UIImage imageNamed:@"ll_preloader_radar_10.png"], [UIImage imageNamed:@"ll_preloader_radar_11.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_arrow_01.png"], [UIImage imageNamed:@"ll_preloader_arrow_02.png"], [UIImage imageNamed:@"ll_preloader_arrow_03.png"], [UIImage imageNamed:@"ll_preloader_arrow_04.png"], [UIImage imageNamed:@"ll_preloader_arrow_05.png"], [UIImage imageNamed:@"ll_preloader_arrow_06.png"], [UIImage imageNamed:@"ll_preloader_arrow_07.png"], [UIImage imageNamed:@"ll_preloader_default.png"], [UIImage imageNamed:@"ll_preloader_arrow_01.png"], [UIImage imageNamed:@"ll_preloader_arrow_02.png"], [UIImage imageNamed:@"ll_preloader_arrow_03.png"], [UIImage imageNamed:@"ll_preloader_arrow_04.png"], [UIImage imageNamed:@"ll_preloader_arrow_05.png"], [UIImage imageNamed:@"ll_preloader_arrow_06.png"], [UIImage imageNamed:@"ll_preloader_arrow_07.png"], [UIImage imageNamed:@"ll_preloader_default.png"], nil];
    }
    return self;
}

- (void)cancelButtonClicked:(id)sender
{
    [self.delegate cancelButtonDidClicked:sender];
}

- (void)tryAgainButtonClicked:(id)sender
{
    [self.delegate tryAgainButtonDidClicked:sender];
}

- (void)beginAnimating
{
    self.hidden = NO;
    [self hideFail];
    self.syncLabel.text = LS_SYNCING;
    
    self.syncImage.animationImages = _syncImages;
    self.syncImage.animationDuration = 3.0f;
    [self.syncImage startAnimating];
    
//    self.syncImage.image = [UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_0beginsync.png"];
    
//    [self performSelector:@selector(toggleImages:) withObject:_isArrow afterDelay:3.0];
    _isAnimating = YES;
}

- (void)showFail
{
    DDLogInfo(@"");
    
    _isAnimating = NO;
    
    [self.syncImage stopAnimating];
    
    self.syncLabel.text = LS_SYNC_FAILED;
    [self.syncLabel setNeedsDisplay];
    
    self.syncImage.image = [UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_4failed.png"];
    [self.syncImage sizeToFit];
    CGPoint center = self.syncImage.center;
    center.x = 160.0f;
    self.syncImage.center = center;
    DDLogInfo(@"sync image frame: x: %f y: %f width: %f height: %f ",self.syncImage.frame.origin.x, self.syncImage.frame.origin.y, self.syncImage.frame.size.width, self.syncImage.frame.size.height);
    [self.syncImage setNeedsDisplay];
    
    self.tryAgain.hidden = NO;
    self.tryAgain.userInteractionEnabled = YES;
    [self.tryAgain setNeedsDisplay];
    
    self.syncReminder.hidden = NO;
    [self.syncReminder setNeedsDisplay];
}

- (void)hideFail
{
    DDLogInfo(@"");
    self.tryAgain.hidden = YES;
    self.tryAgain.userInteractionEnabled = NO;
    
    self.syncReminder.hidden = YES;
}

- (void)toggleImages:(NSNumber *)isArrow
{
    if (_isAnimating) {
        self.syncLabel.text = LS_SYNCING;
        [self.syncLabel setNeedsDisplay];

        if (![isArrow boolValue])
            self.syncImage.image = [UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_2syncing.png"];
        else
            self.syncImage.image = [UIImage imageNamed:@"LT_Sprint1_v1.2_UI_asset_connect_0beginsync.png"];
        
        [self.syncImage setNeedsDisplay];
        isArrow = [NSNumber numberWithBool:![isArrow boolValue]];
        [self performSelector:@selector(toggleImages:) withObject:isArrow afterDelay:2.0];
    }
}

- (void)stopAnimating
{
    _isAnimating = NO;
    [self.syncImage stopAnimating];
    
    self.syncLabel.text = SYNC_SUCCESS;
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNCING_FINISHED object:nil];
    [self.syncLabel setNeedsDisplay];
    
    DDLogError(@"frame: %f %f %f %f", self.syncImage.frame.origin.x, self.syncImage.frame.origin.y, self.syncImage.frame.size.width, self.syncImage.frame.size.height);
    DDLogError(@"image frame: %f %f", self.syncImage.image.size.width, self.syncImage.image.size.height);
    self.syncImage.image = [UIImage imageNamed:@"ll_preloader_sync_success.png"];
    DDLogError(@"frame: %f %f %f %f", self.syncImage.frame.origin.x, self.syncImage.frame.origin.y, self.syncImage.frame.size.width, self.syncImage.frame.size.height);
    DDLogError(@"image frame: %f %f", self.syncImage.image.size.width, self.syncImage.image.size.height);
    [self.syncImage sizeToFit];
    [self.syncImage setNeedsDisplay];
}

- (void)setLabelValue:(NSString *)value {
    self.syncLabel.text = value;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
