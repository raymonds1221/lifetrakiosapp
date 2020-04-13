//
//  SFAResetPasswordController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SVProgressHUD.h"

#import "SFAServerAccountManager.h"

#import "SFAResetPasswordController.h"
#import "UIViewController+Helper.h"
#import "SFAInputCell.h"
#import "SFAButtonCell.h"
#import "SFAErrorMessageViewController.h"

@interface SFAResetPasswordController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIView *emailCellSeparator;

@property (strong, nonatomic) UIToolbar *inputAccessory;

@end

@implementation SFAResetPasswordController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emailTextField.delegate = self;
    self.title = LS_RESET_PASSWORD;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Delegate Methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return LS_RESET_PASSWORD;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 88.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SFAInputCell *cell              = [tableView dequeueReusableCellWithIdentifier:@"SFAResetPasswordCell"];
        cell.inputTitle.hidden          = YES;
        cell.inputTitle.text            = LS_EMAIL;
        cell.inputTextField.placeholder = LS_EMAIL;
        self.emailTextField             = cell.inputTextField;
        self.emailTextField.text        = @"";
        self.emailTextField.delegate    = self;
        self.emailLabel                 = cell.inputTitle;
        self.emailCellSeparator         = cell.cellSeparator;
        return cell;
    }
    return [UITableViewCell new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SFAButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFAResetPassworbButtonCell"];
    [cell.button addTarget:self action:@selector(resetButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [cell.button setTitle:LS_RESET_PASSWORD_CAPS forState:UIControlStateNormal];
    cell.button.titleLabel.minimumScaleFactor = 0.5;
    cell.button.titleLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.emailTextField becomeFirstResponder];
}

#pragma mark - IBAction Methods

- (IBAction)resetButtonPressed:(id)sender
{
    [self.emailTextField resignFirstResponder];
    
    if ([self hasValidInput]) {
        
        if ([self.emailTextField.text isEmail]) {
            SFAServerAccountManager *serverAccountManager = [SFAServerAccountManager sharedManager];
            
            [serverAccountManager resetPasswordWithEmailAddress:self.emailTextField.text success:^{
                
                [self alertWithTitle:LS_RESET_PASSWORD message:LS_RESET_PASSWORD_MESSAGE];
                [SVProgressHUD dismiss];
            } failure:^(NSError *error) {
                NSString *errorMessage = error.localizedDescription;
                if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound  || [error.description rangeOfString:SERVER_ERROR_2].location != NSNotFound ) {
                    errorMessage = SERVER_ERROR_MESSAGE;
                }
                else if ([errorMessage isEqualToString:LS_REQUEST_TIMEOUT] || [errorMessage rangeOfString:SERVER_ERROR_PARSE].location != NSNotFound) {
                    errorMessage = SERVER_ERROR_MESSAGE;
                }
                else if ([errorMessage rangeOfString:SERVER_ERROR_COCOA].location != NSNotFound) {
                    errorMessage = SERVER_ERROR_MESSAGE;
                }
                else if ([errorMessage rangeOfString:NO_INTERNET_ERROR].location != NSNotFound){
                    errorMessage = NO_INTERNET_ERROR_MESSAGE;
                }
           //     else{
           //         errorMessage = SERVER_ERROR_MESSAGE;
            //    }
                
                [self alertWithTitle:ERROR_TITLE message:NSLocalizedString(errorMessage, nil)];
                [SVProgressHUD dismiss];
                
            }];
            
            [SVProgressHUD showWithStatus:PLEASE_WAIT maskType:SVProgressHUDMaskTypeBlack];
        }
        else {
            
            [self alertWithTitle:LS_RESET_PASSWORD message:LS_INVALID_EMAIL_MESSAGE];
        }
    }
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message
{
    SFAErrorMessageViewController *vc = [SFAErrorMessageViewController new];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc setErrorTitle:title errorMessage1:message errorMessage2:@"" errorMessage3:@"" andErrorMessage4:@"" andButtonPosition:0 ButtonTitle1:BUTTON_TITLE_OK andButtonTitle2:@""];
    });
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Private Methods

- (BOOL)hasValidInput
{
    NSString *emailAddress  = self.emailTextField.text;
    
    // Check if all fields has text
    if (emailAddress.length > 0) {
        return YES;
    } else {
        [self alertWithTitle:ERROR_TITLE message:ERROR_RESET_PASSWORD_MISSING_FIELDS];
    }
    
    return NO;
}

- (UIToolbar *)inputAccessory
{
    if (!_inputAccessory) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE
                                                                       style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(inputAccessoryDoneButtonPressed:)];
        _inputAccessory             = [UIToolbar new];
        _inputAccessory.items       = @[doneButton];
        [_inputAccessory sizeToFit];
    }
    return _inputAccessory;
}

- (void)inputAccessoryDoneButtonPressed:(id)sender
{
    [self.emailTextField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.emailTextField]){
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
        return [resultingString rangeOfCharacterFromSet:whitespaceSet].location == NSNotFound ? YES:NO;
    }
    
    return YES;
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField == self.emailTextField) {
        self.emailLabel.textColor                   = [UIColor lightGrayColor];
        self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR_INACTIVE;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.emailTextField) {
        self.emailLabel.hidden                      = NO;
        self.emailLabel.textColor                   = LIFETRAK_COLOR;
        self.emailCellSeparator.backgroundColor     = LIFETRAK_COLOR;
    }
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0) {
        if (textField == self.emailTextField) {
            self.emailLabel.hidden = YES;
        }
    }
    
}


@end
