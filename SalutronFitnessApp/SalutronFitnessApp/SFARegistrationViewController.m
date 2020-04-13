//
//  SFARegistrationViewController.m
//  SalutronFitnessApp
//
//  Created by Dana Nicolas on 4/21/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SVProgressHUD.h"

#import "SFAFacebookManager.h"
#import "SFAServerAccountManager.h"

#import "SFAInputCell.h"
#import "SFAButtonCell.h"
#import "SFARegisterUserCell.h"

#import "SFARegistrationViewController.h"
#import "SFARegisteringViewController.h"
#import "SFAErrorMessageViewController.h"

#import "UIActionSheet+MKBlockAdditions.h"
#import "UIView+CircularMask.h"

#import "DeviceEntity+Data.h"
#import "UserProfileEntity+Data.h"
#import "SFAServerSyncManager.h"
#import "Flurry.h"

#pragma mark - Change profile picture

#define SERVER_UPLOAD_SEGUE_IDENTIFIER  @"RegisterToServerUpload"
#define REGISTER_TO_WELCOME_SEGUE_IDENTIFER @"RegistrationToWelcomeSegueIdentifier"
#define TAC_SEGUE_IDENTIFIER   @"TermsAndConditions"

#define REGISTER_USER_CELL      @"SFARegisterUserCell"
#define EMAIL_CELL              @"SFARegisterEmailCell"
#define PASSWORD_CELL           @"SFARegisterPasswordCell"
#define CONFIRM_PASSWORD_CELL   @"SFARegisterConfirmPasswordCell"
#define REGISTER_BUTTON_CELL    @"SFARegisterButtonCell"
#define SIGNUP_CELL             @"SFASignupCell"

@interface SFARegistrationViewController () <UITableViewDataSource, UITableViewDelegate, SFAErrorMessageViewControllerDelegate, SFARegisteringViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField    *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField    *cPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField    *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField    *lastNameTextField;
@property (weak, nonatomic) IBOutlet UILabel        *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel        *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel        *cPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel        *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel        *lastNameLabel;
@property (weak, nonatomic) IBOutlet UIView         *emailCellSeparator;
@property (weak, nonatomic) IBOutlet UIView         *passwordCellSeparator;
@property (weak, nonatomic) IBOutlet UIView         *cPasswordCellSeparator;
@property (weak, nonatomic) IBOutlet UIView         *firstNameCellSeparator;
@property (weak, nonatomic) IBOutlet UIView         *lastNameCellSeparator;
@property (weak, nonatomic) IBOutlet UIButton       *userImageButton;
@property (weak, nonatomic) IBOutlet UIButton       *changeProfileButton;
@property (weak, nonatomic) IBOutlet UIScrollView   *scrollView;
@property (weak, nonatomic) IBOutlet UIButton       *signUpViaFBButton;
@property (weak, nonatomic) IBOutlet UIButton       *checkBox;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) BOOL isFacebookSignup;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) UIViewController *registeringVC;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL termsAndConditionsAccepted;
@end

@implementation SFARegistrationViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.isFirstLoad = YES;
    // set for Localization
    //NSString *fbImagePath = @"RegisterFacebook";
    
    //if (LANGUAGE_IS_FRENCH) {
    //    fbImagePath = @"RegisterFacebook_fr";
    //}
    
    //[self.signUpViaFBButton setImage:[UIImage imageNamed:fbImagePath] forState:UIControlStateNormal];
    [self.signUpViaFBButton setTitle:SIGNUP_FB forState:UIControlStateNormal];
    
    self.inputContainer = self.tableView;
    self.tableView.tableFooterView = [UIView new];
    
    self.termsAndConditionsAccepted = NO;
    
    [SFAUserDefaultsManager sharedManager].promptChangeSettings = YES;
    
    //UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)];
    //[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed:)];
    //[newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    //self.navigationItem.leftBarButtonItem=newBackButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Flurry logEvent:REGISTRATION_PAGE];
    self.navigationController.navigationBar.backItem.title = @" ";
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    self.title = SIGNUP_SMALL;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return LS_SIGN_UP_EMAIL;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 168.0f;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        SFAButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:REGISTER_BUTTON_CELL];
        [cell.button addTarget:self action:@selector(registrationButtonClicked:) forControlEvents:UIControlEventTouchDown];
        [cell.button setTitle:CREATE_ACCOUNT forState:UIControlStateNormal];
        [cell.checkBox addTarget:self action:@selector(checkBoxClicked:) forControlEvents:UIControlEventTouchDown];
        if (self.termsAndConditionsAccepted == YES) {
            cell.checkBox.selected = YES;
        }
        else{
            cell.checkBox.selected = NO;
        }
        
        NSMutableAttributedString * attributedString= [[NSMutableAttributedString alloc] initWithString:LS_ACCEPT_TERMS];
        
        //[attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:[attributedString.string rangeOfString:LS_TERMS_AND_CONDITIONS]];
        
        [attributedString addAttribute:NSForegroundColorAttributeName value:LIFETRAK_COLOR range:[attributedString.string rangeOfString:LS_TERMS_AND_CONDITIONS]];
        
        cell.label.attributedText = attributedString;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToTermsAndConditions)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setNumberOfTouchesRequired:1];
        tapRecognizer.delegate = self;
        cell.label.userInteractionEnabled = YES;
        [cell.label addGestureRecognizer:tapRecognizer];
        
        cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:245/255.0 alpha:1];
        self.checkBox = cell.checkBox;
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 6;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 80.0f;
        }
        
        return 62.0f;
    }
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            SFARegisterUserCell *cell   = [tableView dequeueReusableCellWithIdentifier:REGISTER_USER_CELL];
            cell.selectionStyle         = UITableViewCellSelectionStyleNone;
            /*
            self.firstNameTextField = cell.firstNameTextField;
            self.firstNameTextField.delegate = self;
            
            self.lastNameTextField = cell.lastNameTextField;
            self.lastNameTextField.delegate = self;
            */
            if (self.isFirstLoad) {
                [cell.changeProfileButton setTitle:LS_SIGN_UP_ADD_PROFILE_PIC forState:UIControlStateNormal];
                self.isFirstLoad        = NO;
            }
            
            cell.changeProfileButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            cell.changeProfileButton.titleLabel.minimumScaleFactor = 0.5;
            self.changeProfileButton    = cell.changeProfileButton;
            self.userImageButton        = cell.userImageButton;
            
            return cell;
        } else if (indexPath.row == 1) {
            SFAInputCell *cell                  = [tableView dequeueReusableCellWithIdentifier:SIGNUP_CELL];
            cell.inputTitle.text                = LS_FIRST_NAME;
            cell.inputTextField.placeholder     = LS_FIRST_NAME;
            self.firstNameTextField             = cell.inputTextField;
            self.firstNameTextField.delegate    = self;
            self.firstNameLabel                 = cell.inputTitle;
            self.firstNameCellSeparator         = cell.cellSeparator;
            
            return cell;
        }
        else if (indexPath.row == 2) {
            SFAInputCell *cell                  = [tableView dequeueReusableCellWithIdentifier:SIGNUP_CELL];
            cell.inputTitle.text                = LS_LAST_NAME;
            cell.inputTextField.placeholder     = LS_LAST_NAME;
            self.lastNameTextField              = cell.inputTextField;
            self.lastNameTextField.delegate     = self;
            self.lastNameLabel                  = cell.inputTitle;
            self.lastNameCellSeparator          = cell.cellSeparator;
            
            return cell;
        }
        else if (indexPath.row == 3) {
            SFAInputCell *cell                  = [tableView dequeueReusableCellWithIdentifier:SIGNUP_CELL];
            cell.inputTitle.text                = LS_EMAIL;
            cell.inputTextField.placeholder     = LS_EMAIL;
            cell.inputTextField.keyboardType    = UIKeyboardTypeEmailAddress;
            self.emailTextField                 = cell.inputTextField;
            self.emailTextField.delegate        = self;
            self.emailLabel                     = cell.inputTitle;
            self.emailCellSeparator             = cell.cellSeparator;
            
            return cell;
        } else if (indexPath.row == 4) {
            SFAInputCell *cell                      = [tableView dequeueReusableCellWithIdentifier:SIGNUP_CELL];
            cell.inputTextField.secureTextEntry     = YES;
            cell.inputTitle.text                    = LS_PASSWORD;
            cell.inputTextField.placeholder         = LS_PASSWORD;
            self.passwordTextField                  = cell.inputTextField;
            self.passwordTextField.delegate         = self;
            self.passwordLabel                      = cell.inputTitle;
            self.passwordCellSeparator              = cell.cellSeparator;
            
            return cell;
        } else if (indexPath.row == 5) {
            SFAInputCell *cell                      = [tableView dequeueReusableCellWithIdentifier:SIGNUP_CELL];
            cell.inputTextField.secureTextEntry     = YES;
            cell.inputTitle.text                    = LS_CONFIRM_PASSWORD;
            cell.inputTextField.placeholder         = LS_CONFIRM_PASSWORD;
            self.cPasswordTextField                 = cell.inputTextField;
            self.cPasswordTextField.delegate        = self;
            self.cPasswordLabel                     = cell.inputTitle;
            self.cPasswordCellSeparator             = cell.cellSeparator;
            
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        self.firstNameLabel.textColor   = [UIColor lightGrayColor];
        self.lastNameLabel.textColor    = [UIColor lightGrayColor];
        self.emailLabel.textColor       = [UIColor lightGrayColor];
        self.passwordLabel.textColor    = [UIColor lightGrayColor];
        self.cPasswordLabel.textColor   = [UIColor lightGrayColor];
        self.firstNameCellSeparator.backgroundColor   = LIFETRAK_COLOR_INACTIVE;
        self.lastNameCellSeparator.backgroundColor    = LIFETRAK_COLOR_INACTIVE;
        self.emailCellSeparator.backgroundColor       = LIFETRAK_COLOR_INACTIVE;
        self.passwordCellSeparator.backgroundColor    = LIFETRAK_COLOR_INACTIVE;
        self.cPasswordCellSeparator.backgroundColor   = LIFETRAK_COLOR_INACTIVE;
        switch (indexPath.row) {
            case 1:
                self.firstNameLabel.textColor               = LIFETRAK_COLOR;
                self.firstNameLabel.hidden                  = NO;
                self.firstNameCellSeparator.backgroundColor = LIFETRAK_COLOR;
                [self.firstNameTextField becomeFirstResponder];
                break;
            case 2:
                self.lastNameLabel.textColor                = LIFETRAK_COLOR;
                self.lastNameLabel.hidden                   = NO;
                self.lastNameCellSeparator.backgroundColor  = LIFETRAK_COLOR;
                [self.lastNameTextField becomeFirstResponder];
                break;
            case 3:
                self.emailLabel.textColor                   = LIFETRAK_COLOR;
                self.emailLabel.hidden                      = NO;
                self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR;
                [self.emailTextField becomeFirstResponder];
                break;
            case 4:
                self.passwordLabel.textColor                = LIFETRAK_COLOR;
                self.passwordLabel.hidden                   = NO;
                self.passwordCellSeparator.backgroundColor  = LIFETRAK_COLOR;
                [self.passwordTextField becomeFirstResponder];
                break;
            case 5:
                self.cPasswordLabel.textColor               = LIFETRAK_COLOR;
                self.cPasswordLabel.hidden                  = NO;
                self.cPasswordCellSeparator.backgroundColor = LIFETRAK_COLOR;
                [self.cPasswordTextField becomeFirstResponder];
                break;
            default:
                break;
        }
    }
}

#pragma mark - UITextFieldDelegate Methods

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-'"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.firstNameTextField ||
        textField == self.lastNameTextField) {
        /*
        if (range.location == textField.text.length && [string isEqualToString:@" "]) {
            // ignore replacement string and add your own
            textField.text = [textField.text stringByAppendingString:@"\u00a0"];
            return NO;
        }
        */
        if (textField.text.length >= 20 && range.length == 0) {
            return NO;
        } else {
            NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];//[[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            
            return [string isEqualToString:filtered];
        }
    }
    
    self.firstNameTextField.text = [self escapeExtraWhiteSpacesOfString:self.firstNameTextField.text];
    self.lastNameTextField.text = [self escapeExtraWhiteSpacesOfString:self.lastNameTextField.text];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.firstNameTextField) {
        self.firstNameLabel.hidden                  = NO;
        self.firstNameLabel.textColor               = LIFETRAK_COLOR;
        self.firstNameCellSeparator.backgroundColor = LIFETRAK_COLOR;
    }
    if (textField == self.lastNameTextField) {
        self.lastNameLabel.hidden                   = NO;
        self.lastNameLabel.textColor                = LIFETRAK_COLOR;
        self.lastNameCellSeparator.backgroundColor  = LIFETRAK_COLOR;
    }
    if (textField == self.emailTextField) {
        self.emailLabel.hidden                      = NO;
        self.emailLabel.textColor                   = LIFETRAK_COLOR;
        self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR;
    }
    if (textField == self.passwordTextField) {
        self.passwordLabel.hidden                   = NO;
        self.passwordLabel.textColor                = LIFETRAK_COLOR;
        self.passwordCellSeparator.backgroundColor  = LIFETRAK_COLOR;
    }
    if (textField == self.cPasswordTextField) {
        self.cPasswordLabel.hidden                  = NO;
        self.cPasswordLabel.textColor               = LIFETRAK_COLOR;
        self.cPasswordCellSeparator.backgroundColor = LIFETRAK_COLOR;
    }

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField == self.firstNameTextField) {
        self.firstNameLabel.textColor               = [UIColor lightGrayColor];
        self.firstNameCellSeparator.backgroundColor = LIFETRAK_COLOR_INACTIVE;
    }
    if (textField == self.lastNameTextField) {
        self.lastNameLabel.textColor                = [UIColor lightGrayColor];
        self.lastNameCellSeparator.backgroundColor  = LIFETRAK_COLOR_INACTIVE;
    }
    if (textField == self.emailTextField) {
        self.emailLabel.textColor                   = [UIColor lightGrayColor];
        self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR_INACTIVE;
    }
    if (textField == self.passwordTextField) {
        self.passwordLabel.textColor                = [UIColor lightGrayColor];
        self.passwordCellSeparator.backgroundColor  = LIFETRAK_COLOR_INACTIVE;
    }
    if (textField == self.cPasswordTextField) {
        self.cPasswordLabel.textColor               = [UIColor lightGrayColor];
        self.cPasswordCellSeparator.backgroundColor = LIFETRAK_COLOR_INACTIVE;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "];
    if (textField.text.length == 0) {
        if (textField == self.firstNameTextField) {
            self.firstNameLabel.hidden = YES;
        }
        if (textField == self.lastNameTextField) {
            self.lastNameLabel.hidden = YES;
        }
        if (textField == self.emailTextField) {
            self.emailLabel.hidden = YES;
        }
        if (textField == self.passwordTextField) {
            self.passwordLabel.hidden = YES;
        }
        if (textField == self.cPasswordTextField) {
            self.cPasswordLabel.hidden = YES;
        }
    }
    
}

#pragma mark - IBAction Methods

- (IBAction)userImageButtonClicked:(id)sender
{
    [UIActionSheet photoPickerWithTitle:LS_UPLOAD_PHOTO showInView:self.navigationController.view presentVC:self.navigationController onPhotoPicked:^(UIImage *chosenImage) {
        [self.userImageButton setImage:[chosenImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.userImageButton addCircularMaskToBounds:self.userImageButton.frame];
        [self.changeProfileButton setTitle:LS_CHANGE_PROFILE_PICTURE forState:UIControlStateNormal];
    } onCancel:^{
        [self.changeProfileButton setTitle:LS_SIGN_UP_ADD_PROFILE_PIC forState:UIControlStateNormal];
        [self.userImageButton setImage:nil forState:UIControlStateNormal];
    }];
    
    [self resignFirstResponder];
}
- (IBAction)changePictureButtonClicked:(id)sender {
    [UIActionSheet photoPickerWithTitle:LS_UPLOAD_PHOTO showInView:self.navigationController.view presentVC:self.navigationController onPhotoPicked:^(UIImage *chosenImage) {
        [self.userImageButton setImage:[chosenImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.userImageButton addCircularMaskToBounds:self.userImageButton.frame];
        [self.changeProfileButton setTitle:LS_CHANGE_PROFILE_PICTURE forState:UIControlStateNormal];
    } onCancel:^{
        [self.changeProfileButton setTitle:LS_SIGN_UP_ADD_PROFILE_PIC forState:UIControlStateNormal];
        [self.userImageButton setImage:nil forState:UIControlStateNormal];
    }];
    
    [self resignFirstResponder];
}

- (IBAction)facebookSignUpButtonClicked:(id)sender
{
    self.isFacebookSignup = YES;
    if (self.termsAndConditionsAccepted == NO) {
        //[self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_TAC_UNCHECKED];
        SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
        vc.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [vc setErrorTitle:@""
                errorMessage1:TERMS_AND_COND_FB_ERROR1
                errorMessage2:TERMS_AND_COND_FB_ERROR2
                errorMessage3:TERMS_AND_COND_FB_ERROR3
             andErrorMessage4:@"" andButtonPosition:1 ButtonTitle1:LS_CANCEL andButtonTitle2:LS_AGREE];
            
            NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:TERMS_AND_COND_FB_ERROR2];
            [attributedString addAttribute:NSForegroundColorAttributeName
                                     value:LIFETRAK_COLOR
                                     range:[attributedString.string
                                            rangeOfString:TERMS_AND_COND_FB_ERROR2]];
            
            vc.errorMessage1.attributedText = attributedString;
            vc.errorMessage1.font           = [UIFont boldSystemFontOfSize:12.0f];
            
        });
        [self presentViewController:vc animated:YES completion:nil];

    }
    else{
        SFAFacebookManager *manager = [SFAFacebookManager sharedManager];
        
        [manager logInWithFacebookWithSuccess:^(NSString *accessToken) {
            self.accessToken = accessToken;
            [self startRegistering];
        } failure:^(NSError *error) {
            //[SVProgressHUD dismiss];
            [self alertError:error];
            //[self alertWithTitle:ERROR_FB_TITLE message:ERROR_FB_MESSAGE];
        }];

        //[self performSegueWithIdentifier:@"SignupToRegistering" sender:self];
        /*
        SFAFacebookManager *manager = [SFAFacebookManager sharedManager];
        
        [manager logInWithFacebookWithSuccess:^(NSString *accessToken) {
            [self logInWithFacebookAccessToken:accessToken];
        } failure:^(NSError *error) {
            //[SVProgressHUD dismiss];
            //[self alertError:error];
        }];
        
        //[SVProgressHUD showWithStatus:LS_SIGN_UP_VIA_FACEBOOK maskType:SVProgressHUDMaskTypeBlack];
         */
    }
    [self resignFirstResponder];
}

- (IBAction)registrationButtonClicked:(id)sender
{
    self.isFacebookSignup = NO;
    if ([self hasValidInput]) {
        if (self.termsAndConditionsAccepted == NO) {
            //[self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_TAC_UNCHECKED];
            
            SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
            vc.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc setErrorTitle:@""
                    errorMessage1:TERMS_AND_COND_ERROR1
                    errorMessage2:TERMS_AND_COND_ERROR2
                    errorMessage3:TERMS_AND_COND_ERROR3
                 andErrorMessage4:@"" andButtonPosition:1 ButtonTitle1:BUTTON_TITLE_CANCEL andButtonTitle2:LS_AGREE];
                
                NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:TERMS_AND_COND_ERROR2];
                [attributedString addAttribute:NSForegroundColorAttributeName
                                         value:LIFETRAK_COLOR
                                         range:[attributedString.string
                                                rangeOfString:TERMS_AND_COND_ERROR2]];
                vc.errorMessage1.attributedText = attributedString;
                vc.errorMessage1.font           = [UIFont boldSystemFontOfSize:12.0f];

            });
            [self presentViewController:vc animated:YES completion:nil];
        }
        else{
            [self startRegistering];
            //[self performSegueWithIdentifier:@"SignupToRegistering" sender:self];
        }
    }
    
    [self resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[SFARegisteringViewController class]]) {
        SFARegisteringViewController *registeringVC  = segue.destinationViewController;
        registeringVC.firstName                      = self.firstNameTextField.text;
        registeringVC.lastName                       = self.lastNameTextField.text;
        registeringVC.email                          = self.emailTextField.text;
        registeringVC.password                       = self.passwordTextField.text;
        registeringVC.isFacebookSignup               = self.isFacebookSignup;
        registeringVC.delegate                       = self;
    }
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)checkBoxClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.selected == YES) {
        self.termsAndConditionsAccepted = NO;
        button.selected = NO;
    }
    else{
        self.termsAndConditionsAccepted = YES;
        button.selected = YES;
    }
    [self.tableView reloadInputViews];
}

- (void)goToTermsAndConditions{
    DDLogInfo(@"goToTermsAndConditions");
    [self.view endEditing:YES];
    [self performSegueWithIdentifier:TAC_SEGUE_IDENTIFIER sender:self];
}



#pragma mark - Private Methods

- (BOOL)hasValidInput
{
    NSString *firstName     = self.firstNameTextField.text;
    NSString *lastName      = self.lastNameTextField.text;
    NSString *emailAddress  = self.emailTextField.text;
    NSString *password      = self.passwordTextField.text;
    NSString *cPassword     = self.cPasswordTextField.text;

    // Check if all fields has text
    if (firstName.length    > 1 &&
        lastName.length     > 1 &&
        emailAddress.length > 0 &&
        password.length     > 0 &&
        cPassword.length    > 0) {
        
        // Check if passwords match
        if (password.length < 6 || cPassword.length < 6) {
            [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_PASSWORD_CHARACTERS];
        }
        else if ([password isEqualToString:cPassword]) {
            if ([emailAddress isEmail]) {
                return YES;
            }
            else {
                [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_EMAIL];
            }
        }
        //Only white Spaces
        else if ([firstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 || [lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0){
            [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_MISSING_FIELDS];
        }
        else {
            [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_UNMATCHED_PASSWORD];
        }
        
    } else if ((firstName.length    > 0 &&
               firstName.length    < 2) ||
               (lastName.length     > 0 &&
               lastName.length     < 2)) {
        [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_NAME_SINGLE_LETTER];
    }
    else if ((password.length < 6 && password.length > 0) || (cPassword.length > 0 && cPassword.length < 6)) {
        [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_PASSWORD_CHARACTERS];
    }
    else {
        [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_MISSING_FIELDS];
    }
    
    self.firstNameTextField.text = [self escapeExtraWhiteSpacesOfString:firstName];
    self.lastNameTextField.text = [self escapeExtraWhiteSpacesOfString:lastName];
    
    return NO;
}

- (NSString *)escapeExtraWhiteSpacesOfString:(NSString *)stringToBeTrimmed{
    //NSRange range = [stringToBeTrimmed rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    //NSString *result = [stringToBeTrimmed stringByReplacingCharactersInRange:range withString:@""];
    NSString *result = [stringToBeTrimmed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    while ([result rangeOfString:@"  "].location != NSNotFound) {
        result = [result stringByReplacingOccurrencesOfString:@"  " withString:@" "];
    }
    return result;
    
}

- (void)logInWithFacebookAccessToken:(NSString *)accessToken
{
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    
    [manager logInWithFacebookAccessToken:accessToken success:^{
        [self getProfile];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
    
    [SVProgressHUD showWithStatus:LS_SIGN_UP_VIA_FACEBOOK maskType:SVProgressHUDMaskTypeBlack];
}

- (void)getProfile
{
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    [manager getProfileWithSuccess:^{
        [SVProgressHUD dismiss];
        [self getDeviceEntities];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
}

- (void)getDeviceEntities
{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    
    [serverSyncManager getDevicesWithSuccess:^(NSArray *deviceEntities) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:MAC_ADDRESS]) {
            [self performSegueWithIdentifier:SERVER_UPLOAD_SEGUE_IDENTIFIER sender:self];
        }
        else {
            NSArray *devices = [DeviceEntity deviceEntities];
            for (DeviceEntity *device in devices) {
                device.isSyncedToServer = [NSNumber numberWithBool:NO];
            }
            [self performSegueWithIdentifier:REGISTER_TO_WELCOME_SEGUE_IDENTIFER sender:self];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self alertError:error];
    }];
    
    [SVProgressHUD setStatus:LS_FETCHING_DEVICES];
}

#pragma mark - SFAErrorMessageViewControllerDelegate
- (void)erroMessageLeftButtonClicked{
}

- (void)erroMessageRightButtonClicked{
    [self agreeToTermsAndConditions];
    //[self performSegueWithIdentifier:@"SignupToRegistering" sender:self];
    
    if (self.isFacebookSignup) {
        SFAFacebookManager *manager = [SFAFacebookManager sharedManager];
        
        [manager logInWithFacebookWithSuccess:^(NSString *accessToken) {
            self.accessToken = accessToken;
            [self startRegistering];
        } failure:^(NSError *error) {
            //[SVProgressHUD dismiss];
            [self alertError:error];
        }];
    }
    else{
        [self startRegistering];
    }
    
}
- (void)erroMessageCenterButtonClicked{
    
}

- (void)agreeToTermsAndConditions{
    self.termsAndConditionsAccepted = YES;
    self.checkBox.selected = YES;
}


#pragma mark - SFARegisteringViewControllerDelegate

-(void)registeringVCDismissedWithError:(NSError *)error withViewController:(UIViewController *)vc{
    //[self.navigationController popViewControllerAnimated:YES];
    //[vc dismissViewControllerAnimated:YES completion:nil];
   // [vc dismissViewControllerAnimated:YES completion:nil];
   // [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
 //   [self.registeringVC dismissViewControllerAnimated:YES completion:^{
        [self alertError:error];
 //   }];
    //[self performSelector:@selector(alertError:) withObject:error afterDelay:3.0];
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)unwindToRegistration:(UIStoryboardSegue *)segue
{
    
}

- (void)startRegistering{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Signup_Main" bundle:nil];
    SFARegisteringViewController *registeringVC = [storyboard instantiateViewControllerWithIdentifier:@"SFARegisteringViewController"];
    registeringVC.firstName                      = self.firstNameTextField.text;
    registeringVC.lastName                       = self.lastNameTextField.text;
    registeringVC.email                          = self.emailTextField.text;
    registeringVC.password                       = self.passwordTextField.text;
    registeringVC.isFacebookSignup               = self.isFacebookSignup;
    registeringVC.delegate                       = self;
    registeringVC.accessToken                    = self.accessToken;
    registeringVC.userImage                      = self.userImageButton.imageView.image;
    UINavigationController *navController        = [[UINavigationController alloc] initWithRootViewController:registeringVC];
    //self.registeringVC = registeringVC;//navController;
    [self presentViewController:navController animated:YES completion:nil];
    //[self.navigationController pushViewController:registeringVC animated:YES];
}
@end
