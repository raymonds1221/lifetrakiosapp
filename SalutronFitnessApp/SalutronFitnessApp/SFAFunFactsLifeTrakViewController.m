//
//  SFAFunFactsLifeTrakViewController.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 12/8/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SFAFunFactsLifeTrakViewController.h"

@interface SFAFunFactsLifeTrakViewController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic)NSArray *funFactTitles;
@property (strong, nonatomic)NSArray *funFactContents;
@property (strong, nonatomic)NSArray *funFactButtonTitles1;
@property (strong, nonatomic)NSArray *funFactButtonTitles2;
@property (strong, nonatomic)NSArray *funFactButtonTitles3;
@property (strong, nonatomic)NSArray *funFactIcons;

@property (nonatomic) int intTest;


@end

@implementation SFAFunFactsLifeTrakViewController


- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                 presentingController:(UIViewController *)presenting
                                                                     sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self closeButtonClicked:self];
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController* vc1 =[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* vc2 =[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* con = [transitionContext containerView];
    UIView* v1 = vc1.view;
    UIView* v2 = vc2.view;
    
    if (vc2 == self) { // presenting
        [con addSubview:v2];
        v2.frame                    = v1.frame;
        self.funFactsView.transform    = CGAffineTransformMakeScale(1.6,1.6);
        self.funFactChartView.transform    = CGAffineTransformMakeScale(1.6,1.6);
        v2.alpha                    = 0;
        v1.tintAdjustmentMode       = UIViewTintAdjustmentModeDimmed;
        [UIView animateWithDuration:0.25 animations:^{
            v2.alpha                    = 1;
            v2.backgroundColor          = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
            self.funFactsView.transform    = CGAffineTransformIdentity;
            self.funFactChartView.transform    = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else { // dismissing
        [UIView animateWithDuration:0.25 animations:^{
            self.funFactsView.transform    = CGAffineTransformMakeScale(0.5,0.5);
            self.funFactChartView.transform    = CGAffineTransformMakeScale(0.5,0.5);
            v1.alpha                    = 0;
        } completion:^(BOOL finished) {
            v2.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [transitionContext completeTransition:YES];
        }];
    }
    
}

/*
- (IBAction) doDismiss: (id) sender {
    [self.presentingViewController
     dismissViewControllerAnimated:YES completion:nil];
}

*/

-(void)setDismissOnOutsideViewTap{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapsOutside)];
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.numberOfTouchesRequired = 1;
   // [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)userTapsOutside{
    [self closeButtonClicked:self];
}


- (IBAction)closeButtonClicked:(id)sender {
    /*
    self.intTest += 1;
    if (self.intTest > 30) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
    [self setFact:self.intTest];
    }
#warning remove comment after testing
    */
   [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
   // [self setRandomFact];
}

- (IBAction)moreFactsButton1Clicked:(id)sender {
    NSString *buttonTitle = self.moreFactsButton1.titleLabel.text;
    if ([buttonTitle isEqualToString:FUN_FACT_1_BUTTON1_TITLE]) {
        //What is blue light
        [self setFact:2];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_2_BUTTON1_TITLE]){
        //tell me about light and sleep
        [self setFact:3];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_3_BUTTON1_TITLE]){
        //tell me about morning light
        [self setFact:4];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_4_BUTTON1_TITLE]){
        [self setFact:5];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_5_BUTTON1_TITLE]){
        [self setFact:6];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_6_BUTTON1_TITLE]){
        [self setFact:7];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_7_BUTTON1_TITLE]){
        [self setFact:8];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_8_BUTTON1_TITLE]){
        [self setFact:9];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_9_BUTTON1_TITLE]){
        [self setFact:10];
    }
}

- (IBAction)moreFactsButton2Clicked:(id)sender {
    NSString *buttonTitle = self.moreFactsButton2.titleLabel.text;
    if ([buttonTitle isEqualToString:FUN_FACT_1_BUTTON2_TITLE]) {
        //tell me about light and sleep
        [self setFact:3];
    }
    else if([buttonTitle isEqualToString:FUN_FACT_3_BUTTON2_TITLE]){
        //tell me about evening light
        [self setFact:7];
    }
}

- (IBAction)moreFactsButton3Clicked:(id)sender {
    NSString *buttonTitle = self.moreFactsButton3.titleLabel.text;
    if([buttonTitle isEqualToString:FUN_FACT_3_BUTTON3_TITLE]){
        //tell me about uv light
        [self setFact:10];
    }
}

- (IBAction)moreButtonChartClicked:(id)sender {
    
    NSString *buttonTitleChart = self.funFactChartMoreButton.titleLabel.text;
    if([buttonTitleChart isEqualToString:FUN_FACT_5_BUTTON1_TITLE]){
        [self setFact:6];
    }
    else if([buttonTitleChart isEqualToString:FUN_FACT_8_BUTTON1_TITLE]){
        [self setFact:9];
    }
}

- (void)initializeObjects{
    // Do any additional setup after loading the view.
    //self.funFactsView.layer.borderColor = [UIColor blueColor].CGColor;
    //self.funFactsView.layer.borderWidth = 2;
    self.funFactsView.layer.cornerRadius = 8;
    self.funFactChartView.layer.cornerRadius = 8;
    self.funFactChartMoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.moreFactsButton1.titleLabel.numberOfLines = 1;
    self.moreFactsButton1.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.moreFactsButton1.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.moreFactsButton2.titleLabel.numberOfLines = 1;
    self.moreFactsButton2.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.moreFactsButton2.titleLabel.lineBreakMode = NSLineBreakByClipping;
    self.moreFactsButton3.titleLabel.numberOfLines = 1;
    self.moreFactsButton3.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.moreFactsButton3.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    [self setDismissOnOutsideViewTap];
    [self initializeFunFactsTitlesArray];
    [self initializeFunFactsContentsArray];
    [self initializeFunFactsButton1sArray];
    [self initializeFunFactsButton2sArray];
    [self initializeFunFactsButton3sArray];
    [self initializeFunFactsIconsArray];
    /*
    self.intTest = 1;
    [self setFact:self.intTest];
#warning remove comment after testing
     */
    if (self.isLightPlot) {
        [self setLightFact];
    }
    else{
        [self setRandomFact];
    }
}

- (void)initializeFunFactsTitlesArray{
    self.funFactTitles = @[FUN_FACT_1_TITLE,
                           FUN_FACT_2_TITLE,
                           FUN_FACT_3_TITLE,
                           FUN_FACT_4_TITLE,
                           FUN_FACT_5_TITLE,
                           FUN_FACT_6_TITLE,
                           FUN_FACT_7_TITLE,
                           FUN_FACT_8_TITLE,
                           FUN_FACT_9_TITLE,
                           FUN_FACT_10_TITLE,
                           FUN_FACT_11_TITLE,
                           FUN_FACT_12_TITLE,
                           FUN_FACT_13_TITLE,
                           FUN_FACT_14_TITLE,
                           FUN_FACT_15_TITLE,
                           FUN_FACT_16_TITLE,
                           FUN_FACT_17_TITLE,
                           FUN_FACT_18_TITLE,
                           FUN_FACT_19_TITLE,
                           FUN_FACT_20_TITLE,
                           FUN_FACT_21_TITLE,
                           FUN_FACT_22_TITLE,
                           FUN_FACT_23_TITLE,
                           FUN_FACT_24_TITLE,
                           FUN_FACT_25_TITLE,
                           FUN_FACT_26_TITLE,
                           FUN_FACT_27_TITLE,
                           FUN_FACT_28_TITLE,
                           FUN_FACT_29_TITLE,
                           FUN_FACT_30_TITLE];
}

- (void)initializeFunFactsContentsArray{
    self.funFactContents = @[FUN_FACT_1_CONTENT,
                           FUN_FACT_2_CONTENT,
                           FUN_FACT_3_CONTENT,
                           FUN_FACT_4_CONTENT,
                           FUN_FACT_5_CONTENT,
                           FUN_FACT_6_CONTENT,
                           FUN_FACT_7_CONTENT,
                           FUN_FACT_8_CONTENT,
                           FUN_FACT_9_CONTENT,
                           FUN_FACT_10_CONTENT,
                           FUN_FACT_11_CONTENT,
                           FUN_FACT_12_CONTENT,
                           FUN_FACT_13_CONTENT,
                           FUN_FACT_14_CONTENT,
                           FUN_FACT_15_CONTENT,
                           FUN_FACT_16_CONTENT,
                           FUN_FACT_17_CONTENT,
                           FUN_FACT_18_CONTENT,
                           FUN_FACT_19_CONTENT,
                           FUN_FACT_20_CONTENT,
                           FUN_FACT_21_CONTENT,
                           FUN_FACT_22_CONTENT,
                           FUN_FACT_23_CONTENT,
                           FUN_FACT_24_CONTENT,
                           FUN_FACT_25_CONTENT,
                           FUN_FACT_26_CONTENT,
                           FUN_FACT_27_CONTENT,
                           FUN_FACT_28_CONTENT,
                           FUN_FACT_29_CONTENT,
                           FUN_FACT_30_CONTENT];
}

- (void)initializeFunFactsButton1sArray{
    self.funFactButtonTitles1 = @[FUN_FACT_1_BUTTON1_TITLE,
                           FUN_FACT_2_BUTTON1_TITLE,
                           FUN_FACT_3_BUTTON1_TITLE,
                           FUN_FACT_4_BUTTON1_TITLE,
                           FUN_FACT_5_BUTTON1_TITLE,
                           FUN_FACT_6_BUTTON1_TITLE,
                           FUN_FACT_7_BUTTON1_TITLE,
                           FUN_FACT_8_BUTTON1_TITLE,
                           FUN_FACT_9_BUTTON1_TITLE,
                           FUN_FACT_10_BUTTON1_TITLE,
                           FUN_FACT_11_BUTTON1_TITLE,
                           FUN_FACT_12_BUTTON1_TITLE,
                           FUN_FACT_13_BUTTON1_TITLE,
                           FUN_FACT_14_BUTTON1_TITLE,
                           FUN_FACT_15_BUTTON1_TITLE,
                           FUN_FACT_16_BUTTON1_TITLE,
                           FUN_FACT_17_BUTTON1_TITLE,
                           FUN_FACT_18_BUTTON1_TITLE,
                           FUN_FACT_19_BUTTON1_TITLE,
                           FUN_FACT_20_BUTTON1_TITLE,
                           FUN_FACT_21_BUTTON1_TITLE,
                           FUN_FACT_22_BUTTON1_TITLE,
                           FUN_FACT_23_BUTTON1_TITLE,
                           FUN_FACT_24_BUTTON1_TITLE,
                           FUN_FACT_25_BUTTON1_TITLE,
                           FUN_FACT_26_BUTTON1_TITLE,
                           FUN_FACT_27_BUTTON1_TITLE,
                           FUN_FACT_28_BUTTON1_TITLE,
                           FUN_FACT_29_BUTTON1_TITLE,
                           FUN_FACT_30_BUTTON1_TITLE];
}

- (void)initializeFunFactsButton2sArray{
    self.funFactButtonTitles2 = @[FUN_FACT_1_BUTTON2_TITLE,
                           FUN_FACT_2_BUTTON2_TITLE,
                           FUN_FACT_3_BUTTON2_TITLE,
                           FUN_FACT_4_BUTTON2_TITLE,
                           FUN_FACT_5_BUTTON2_TITLE,
                           FUN_FACT_6_BUTTON2_TITLE,
                           FUN_FACT_7_BUTTON2_TITLE,
                           FUN_FACT_8_BUTTON2_TITLE,
                           FUN_FACT_9_BUTTON2_TITLE,
                           FUN_FACT_10_BUTTON2_TITLE,
                           FUN_FACT_11_BUTTON2_TITLE,
                           FUN_FACT_12_BUTTON2_TITLE,
                           FUN_FACT_13_BUTTON2_TITLE,
                           FUN_FACT_14_BUTTON2_TITLE,
                           FUN_FACT_15_BUTTON2_TITLE,
                           FUN_FACT_16_BUTTON2_TITLE,
                           FUN_FACT_17_BUTTON2_TITLE,
                           FUN_FACT_18_BUTTON2_TITLE,
                           FUN_FACT_19_BUTTON2_TITLE,
                           FUN_FACT_20_BUTTON2_TITLE,
                           FUN_FACT_21_BUTTON2_TITLE,
                           FUN_FACT_22_BUTTON2_TITLE,
                           FUN_FACT_23_BUTTON2_TITLE,
                           FUN_FACT_24_BUTTON2_TITLE,
                           FUN_FACT_25_BUTTON2_TITLE,
                           FUN_FACT_26_BUTTON2_TITLE,
                           FUN_FACT_27_BUTTON2_TITLE,
                           FUN_FACT_28_BUTTON2_TITLE,
                           FUN_FACT_29_BUTTON2_TITLE,
                           FUN_FACT_30_BUTTON2_TITLE];
}

- (void)initializeFunFactsButton3sArray{
    self.funFactButtonTitles3 = @[FUN_FACT_1_BUTTON3_TITLE,
                           FUN_FACT_2_BUTTON3_TITLE,
                           FUN_FACT_3_BUTTON3_TITLE,
                           FUN_FACT_4_BUTTON3_TITLE,
                           FUN_FACT_5_BUTTON3_TITLE,
                           FUN_FACT_6_BUTTON3_TITLE,
                           FUN_FACT_7_BUTTON3_TITLE,
                           FUN_FACT_8_BUTTON3_TITLE,
                           FUN_FACT_9_BUTTON3_TITLE,
                           FUN_FACT_10_BUTTON3_TITLE,
                           FUN_FACT_11_BUTTON3_TITLE,
                           FUN_FACT_12_BUTTON3_TITLE,
                           FUN_FACT_13_BUTTON3_TITLE,
                           FUN_FACT_14_BUTTON3_TITLE,
                           FUN_FACT_15_BUTTON3_TITLE,
                           FUN_FACT_16_BUTTON3_TITLE,
                           FUN_FACT_17_BUTTON3_TITLE,
                           FUN_FACT_18_BUTTON3_TITLE,
                           FUN_FACT_19_BUTTON3_TITLE,
                           FUN_FACT_20_BUTTON3_TITLE,
                           FUN_FACT_21_BUTTON3_TITLE,
                           FUN_FACT_22_BUTTON3_TITLE,
                           FUN_FACT_23_BUTTON3_TITLE,
                           FUN_FACT_24_BUTTON3_TITLE,
                           FUN_FACT_25_BUTTON3_TITLE,
                           FUN_FACT_26_BUTTON3_TITLE,
                           FUN_FACT_27_BUTTON3_TITLE,
                           FUN_FACT_28_BUTTON3_TITLE,
                           FUN_FACT_29_BUTTON3_TITLE,
                           FUN_FACT_30_BUTTON3_TITLE];
}

- (void)initializeFunFactsIconsArray{
    self.funFactIcons = @[FUN_FACT_1_ICON,
                           FUN_FACT_2_ICON,
                           FUN_FACT_3_ICON,
                           FUN_FACT_4_ICON,
                           FUN_FACT_5_ICON,
                           FUN_FACT_6_ICON,
                           FUN_FACT_7_ICON,
                           FUN_FACT_8_ICON,
                           FUN_FACT_9_ICON,
                           FUN_FACT_10_ICON,
                           FUN_FACT_11_ICON,
                           FUN_FACT_12_ICON,
                           FUN_FACT_13_ICON,
                           FUN_FACT_14_ICON,
                           FUN_FACT_15_ICON,
                           FUN_FACT_16_ICON,
                           FUN_FACT_17_ICON,
                           FUN_FACT_18_ICON,
                           FUN_FACT_19_ICON,
                           FUN_FACT_20_ICON,
                           FUN_FACT_21_ICON,
                           FUN_FACT_22_ICON,
                           FUN_FACT_23_ICON,
                           FUN_FACT_24_ICON,
                           FUN_FACT_25_ICON,
                           FUN_FACT_26_ICON,
                           FUN_FACT_27_ICON,
                           FUN_FACT_28_ICON,
                           FUN_FACT_29_ICON,
                           FUN_FACT_30_ICON];
}

- (void)setRandomFact{
    int randomIndex = arc4random() % 30 + 1; //1-30
    
    SFAUserDefaultsManager *userDefaultsManager = [SFAUserDefaultsManager sharedManager];
    if (userDefaultsManager.watchModel == WatchModel_Zone_C410 ||
        userDefaultsManager.watchModel == WatchModel_R420) {
        randomIndex = arc4random() % 16 + 15; // 15-30
    }
    else if (userDefaultsManager.watchModel == WatchModel_Move_C300 ||
             userDefaultsManager.watchModel == WatchModel_Move_C300_Android){
        randomIndex = arc4random() % 6 + 25; // 25-30
    }
    [self setFact:randomIndex];
}

- (void)setLightFact{
    int randomIndex = arc4random() % 14 + 1; //1-14
    [self setFact:randomIndex];
}

- (void)setFact:(int)factNumber{
    //factnumber must be the same as the number that corresponds to the fact. Subtract 1 for array index
    factNumber -= 1;
    NSString *factTitle   = self.funFactTitles[factNumber];
    NSString *factContent = self.funFactContents[factNumber];
    NSString *factButton1 = self.funFactButtonTitles1[factNumber];
    NSString *factButton2 = self.funFactButtonTitles2[factNumber];
    NSString *factButton3 = self.funFactButtonTitles3[factNumber];
    NSString *factIcon    = self.funFactIcons[factNumber];
    if (factNumber == 7 || factNumber == 4) { // 8 and 5 in constants.h
        self.funChartTitle.text = factTitle;
        self.funFactChartContent.text = factContent;
        self.funFactChartImage.image = [UIImage imageNamed:factIcon];
        [self setUpFactButton:self.funFactChartMoreButton withTitle:factButton1];
        [self setUpFactButton:self.moreFactsButton1 withTitle:@" "];
        [self setUpFactButton:self.moreFactsButton2 withTitle:@" "];
        [self setUpFactButton:self.moreFactsButton3 withTitle:@" "];
        self.funFactChartView.hidden = NO;
    }
    else{
        self.funFactTitle.text = factTitle;
        self.funFactContent.text = factContent;
        self.funFactIcon.image = [UIImage imageNamed:factIcon];
        [self setUpFactButton:self.moreFactsButton1 withTitle:factButton1];
        [self setUpFactButton:self.moreFactsButton2 withTitle:factButton2];
        [self setUpFactButton:self.moreFactsButton3 withTitle:factButton3];
        self.funFactChartView.hidden = YES;
    }
}

- (void)setUpFactButton:(UIButton *)button withTitle:(NSString *)title{
    if (title.length > 0) {
        [button setTitle:title forState:UIControlStateNormal];
        button.hidden = NO;
        button.enabled = YES;
        if (button.tag == 1) {
            self.buttonConstraint1.constant = 18;
        }
        else if (button.tag == 2) {
            self.buttonConstraint2.constant = 18;
        }
        else if (button.tag == 3) {
            self.buttonConstraint3.constant = 18;
        }
    }
    else{
        button.hidden = YES;
        button.enabled = NO;
        if (button.tag == 1) {
            self.buttonConstraint1.constant = 0;
        }
        else if (button.tag == 2) {
            self.buttonConstraint2.constant = 0;
        }
        else if (button.tag == 3) {
            self.buttonConstraint3.constant = 0;
        }
    }

}
@end
