//
//  SFAEditProfileViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/15/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SVProgressHUD.h"

#import "SFAInputCell.h"
#import "SFAButtonCell.h"
#import "SFAProfileCell.h"
#import "SFAProfileGenderCell.h"

#import "SalutronUserProfile+Data.h"
#import "UserProfileEntity+Data.h"
#import "DeviceEntity+Data.h"

#import "SFAServerAccountManager.h"
#import "SFAHealthKitManager.h"
#import "ECSlidingViewController.h"

#import "SFAEditProfileViewController.h"

#import "UIActionSheet+MKBlockAdditions.h"
#import "UIView+CircularMask.h"
#import "UIImageView+WebCache.h"

#define FIRST_NAME_CELL         @"SFAProfileFirstNameCell"
#define LAST_NAME_CELL          @"SFAProfileLastNameCell"
#define EMAIL_ADDRESS_CELL      @"SFAProfileEmailAddressCell"
#define OLD_PASSWORD_CELL       @"SFAProfileOldPasswordCell"
#define PASSWORD_CELL           @"SFAProfilePasswordCell"
#define CONFIRM_PASSWORD_CELL   @"SFAProfileConfirmPasswordCell"
#define SAVE_CHANGES_CELL       @"SFAProfileSaveChangesCell"
#define PROFILE_CELL            @"SFAProfileCell"
#define GENDER_CELL             @"SFAProfileGenderCell"

@interface SFAEditProfileViewController () <UITableViewDataSource, UITableViewDelegate, SFAProfileGenderCellDelegate, SFAProfileCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextField *firstNameTextField;
@property (strong, nonatomic) UITextField *lastNameTextField;
@property (strong, nonatomic) UITextField *oldPasswordTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *cPasswordTextField;
@property (weak, nonatomic) IBOutlet UIView *changeProfilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *changeProfilePictureButton;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UserEntity *user;
@property (strong, nonatomic) SalutronUserProfile *salutronUserProfile;
@property (nonatomic) BOOL profilePictureChanged;

- (IBAction)changeProfilePictureButtonClicked:(id)sender;

@end

@implementation SFAEditProfileViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inputContainer = self.tableView;
    
   // [self.navigationController setTitle:MY_ACCOUNT_ACCOUNT];
    self.navigationController.navigationBar.topItem.title = MY_ACCOUNT_ACCOUNT;
    [self.changeProfilePictureButton setTitle:LS_CHANGE_PROFILE_PICTURE forState:UIControlStateNormal];
    [self hideCancelAndSave];
}

- (void)viewWillAppear:(BOOL)animated{
    
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    self.user = manager.user;
    self.salutronUserProfile = [SalutronUserProfile getData];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.image == nil || !self.profilePictureChanged) {
        UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.user.imageURL]];
            UIImage *img = [[UIImage alloc] initWithData:data];//[[UIImage alloc] initWithData:data cache:NO];
            self.userImage.image = placeholderImage;
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.userImage.image = img;
                if (!img) {
                    self.userImage.image = placeholderImage;
                }
            });
            //    [self.userImage setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageRefreshCached];
            [self.userImage addCircularMaskToBounds:self.userImage.frame];
        });
        //[self.userImage setImageWithURL:[NSURL URLWithString:self.user.imageURL] placeholderImage:placeholderImage options:SDWebImageRefreshCached];
        //[self.userImage addCircularMaskToBounds:self.userImage.frame];
    }
    self.profilePictureChanged = NO;
    UITapGestureRecognizer *changeProfilePictureViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeProfilePictureButtonClicked:)];
    [self.changeProfilePictureView addGestureRecognizer:changeProfilePictureViewTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    /*
    if (section == 1) {
        return 80.0f;
    }
    */
    return 22.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    /*
    if (section == 1) {
        SFAButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:SAVE_CHANGES_CELL];
        [cell.button addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchDown];
        cell.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:245/255.0 alpha:1];
        return cell;
    }
    */
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 7;
    } else if (section == 1) {
        return 3;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0f;
    } else if (indexPath.section == 1){
        if (indexPath.row < 3) {
            SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
            
            if (!manager.isFacebookLogIn) {
                return 44.0f;
            }
        } else if (indexPath.row == 3) {
            return 80.0f;
        }
    }
    return 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return SECTION_BLANK;
    } else if (section == 1) {
        SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
        
        return manager.isFacebookLogIn ? nil : LS_CHANGE_PASSWORD;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            SFAInputCell *cell = [tableView dequeueReusableCellWithIdentifier:EMAIL_ADDRESS_CELL];
            self.emailTextField = cell.inputTextField;
            self.emailTextField.delegate = self;
            cell.inputTextField.delegate = self;
            cell.inputTitle.text = LS_LOGGED_IN_AS;
            
            if (cell.inputTextField.text.length == 0) {
                cell.inputTextField.text = self.user.emailAddress;
                cell.inputTextField.textColor = [UIColor lightGrayColor];
                cell.inputTextField.userInteractionEnabled = NO;
                cell.inputTextField.enabled = NO;
            }
            
            return cell;
        } else if (indexPath.row == 1) {
            SFAInputCell *cell = [tableView dequeueReusableCellWithIdentifier:FIRST_NAME_CELL];
            self.firstNameTextField = cell.inputTextField;
            self.firstNameTextField.delegate = self;
            cell.inputTextField.delegate = self;
            cell.inputTitle.text = LS_FIRST_NAME;
            
            if (cell.inputTextField.text.length == 0) {
                cell.inputTextField.text = self.user.firstName;
            }
            
            return cell;
        } else if (indexPath.row == 2) {
            SFAInputCell *cell = [tableView dequeueReusableCellWithIdentifier:LAST_NAME_CELL];
            self.lastNameTextField = cell.inputTextField;
            self.lastNameTextField.delegate = self;
            cell.inputTextField.delegate = self;
            cell.inputTitle.text = LS_LAST_NAME;
            
            if (cell.inputTextField.text.length == 0) {
                cell.inputTextField.text = self.user.lastName;
            }
            return cell;
        }
        if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5) {
            SFAProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:PROFILE_CELL];
            cell.salutronUserProfile = self.salutronUserProfile;
            [cell setContentsWithProfileType:indexPath.row];
            cell.delegate = self;
            return cell;
        } else if (indexPath.row == 6) {
            SFAProfileGenderCell *cell = [tableView dequeueReusableCellWithIdentifier:GENDER_CELL];
            cell.delegate = self;
            cell.salutronUserProfile = self.salutronUserProfile;
            cell.labelTitle.text = LS_GENDER;
            cell.femaleLabel.text = LS_FEMALE;
            cell.maleLabel.text = LS_MALE;
            [cell setGenderContent];
            return cell;
        }

    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SFAInputCell *cell = [tableView dequeueReusableCellWithIdentifier:OLD_PASSWORD_CELL];
            [cell.inputTextField setText:@""];
            self.oldPasswordTextField = cell.inputTextField;
            self.oldPasswordTextField.delegate = self;
            cell.inputTextField.delegate = self;
            cell.inputTitle.text = LS_OLD_PASSWORD;
            return cell;
        } else if (indexPath.row == 1) {
            SFAInputCell *cell = [tableView dequeueReusableCellWithIdentifier:PASSWORD_CELL];
            [cell.inputTextField setText:@""];
            self.passwordTextField = cell.inputTextField;
            self.passwordTextField.delegate = self;
            cell.inputTextField.delegate = self;
            cell.inputTitle.text = LS_NEW_PASSWORD;
            return cell;
        } else if (indexPath.row == 2) {
            SFAInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CONFIRM_PASSWORD_CELL];
            [cell.inputTextField setText:@""];
            self.cPasswordTextField = cell.inputTextField;
            self.cPasswordTextField.delegate = self;
            cell.inputTextField.delegate = self;
            cell.inputTitle.text = LS_CONFIRM_PASSWORD;
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self.firstNameTextField becomeFirstResponder];
        }
        else if (indexPath.row == 2) {
            [self.lastNameTextField becomeFirstResponder];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.oldPasswordTextField becomeFirstResponder];
        }
        else if (indexPath.row == 1) {
            [self.passwordTextField becomeFirstResponder];
        }
        else if (indexPath.row == 2) {
            [self.cPasswordTextField becomeFirstResponder];
        }
    }
}

#pragma mark - UITextFieldDelegate Methods

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self showCancelAndSave];
    // only when adding on the end of textfield && it's a space
    /*if (range.location == textField.text.length && [string isEqualToString:@" "]) {
        // ignore replacement string and add your own
        textField.text = [textField.text stringByAppendingString:@"\u00a0"];
        return NO;
    }
    else {*/
        if (textField == self.firstNameTextField ||
            textField == self.lastNameTextField) {
            if (textField.text.length >= 20 && range.length == 0) {
                return NO;
            } else {
               NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                // NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
                NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
                return [string isEqualToString:filtered];
            }
        }
    //}
    // for all other cases, proceed with replacement
    
    self.firstNameTextField.text = [self escapeExtraWhiteSpacesOfString:self.firstNameTextField.text];
    self.lastNameTextField.text = [self escapeExtraWhiteSpacesOfString:self.lastNameTextField.text];
    return YES;
}

#pragma mark - Private Methods

- (BOOL)hasValidInput
{
    if (![self textIsEmpty:self.firstNameTextField.text] &&
        ![self textIsEmpty:self.lastNameTextField.text]) {
        
        if ((self.firstNameTextField.text.length    > 0 &&
             self.firstNameTextField.text.length    < 2) ||
            (self.lastNameTextField.text.length     > 0 &&
             self.lastNameTextField.text.length     < 2)) {
                [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_NAME_SINGLE_LETTER];
                
                return NO;
            }
        
        if ([self textIsEmpty:self.oldPasswordTextField.text] &&
            [self textIsEmpty:self.passwordTextField.text] &&
            [self textIsEmpty:self.cPasswordTextField.text]) {
            
            return YES;
        }
        else {
            
            if ([self textLengthValid:self.oldPasswordTextField.text] &&
                [self textLengthValid:self.passwordTextField.text] &&
                [self textLengthValid:self.cPasswordTextField.text]) {
                
                if ([self textsMatch:@[self.passwordTextField.text, self.cPasswordTextField.text]]) {
                    return YES;
                }
                else {
                    [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_UNMATCHED_PASSWORD];
                    return NO;
                }
            }
            else {
                
                [self alertWithTitle:ERROR_TITLE message:ERROR_PASSWORD_LESS_THAN_MIN];
                return NO;
            }
        }
    }
    else {
        [self alertWithTitle:ERROR_TITLE message:ERROR_REGISTER_MISSING_FIELDS];
        return NO;
    }
}

- (BOOL)textIsEmpty:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text.length ? NO : YES;
}

- (BOOL)textLengthValid:(NSString *)text
{
    int min = 6;
    return (text.length > 0 && text.length >= min) ? YES : NO;
}

- (BOOL)textsMatch:(NSArray *)textArray
{
    BOOL unmatch = NO;
    
    for (NSString *text in textArray) {
        if (![[textArray firstObject] isEqualToString:text]) {
            unmatch = YES;
        }
    }
    
    return !unmatch;
}

- (void)saveChanges
{
    if ([self hasValidInput]) {
        NSString *firstName     = [self.firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastName      = [self.lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        firstName = [self escapeExtraWhiteSpacesOfString:firstName];
        lastName = [self escapeExtraWhiteSpacesOfString:lastName];
        NSString *password      = self.passwordTextField.text;
        NSString *oldPassword   = self.oldPasswordTextField.text;
        
        SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
        
        [SVProgressHUD showWithStatus:STATUS_PROFILE_UPDATE maskType:SVProgressHUDMaskTypeBlack];
        [manager updateProfileWithFirstName:firstName lastName:lastName password:password oldPassword:oldPassword userImage:self.image success:^{
            self.passwordTextField.text     = @"";
            self.cPasswordTextField.text    = @"";
            self.oldPasswordTextField.text  = @"";
            
            self.user = manager.user;
            [SVProgressHUD showSuccessWithStatus:STATUS_PROFILE_UPDATE_SUCCESS];
            
            [[SDImageCache sharedImageCache] removeImageForKey:self.user.imageURL fromDisk:YES];
            
            
            [SalutronUserProfile saveWithSalutronUserProfile:self.salutronUserProfile];
            DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
            [UserProfileEntity userProfileWithSalutronUserProfile:self.salutronUserProfile forDeviceEntity:deviceEntity];
            [self saveHeightAndWeightToHealthStore];
            [self.tableView reloadData];
            
            UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.user.imageURL]];
                UIImage *img = [[UIImage alloc] initWithData:data];//[[UIImage alloc] initWithData:data cache:NO];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    self.userImage.image = img;
                });
                //    [self.userImage setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageRefreshCached];
                [self.userImage addCircularMaskToBounds:self.userImage.frame];
            });
            //[self.userImage setImageWithURL:[NSURL URLWithString:self.user.imageURL] placeholderImage:placeholderImage options:SDWebImageRefreshCached];
            //[self.userImage addCircularMaskToBounds:self.userImage.frame];
            
            /*
            UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
            if (self.user.imageURL != nil) {
                [self.userImage setImageWithURL:[NSURL URLWithString:self.user.imageURL] placeholderImage:placeholderImage options:SDWebImageRefreshCached];
                [self.userImage addCircularMaskToBounds:self.userImage.frame];
            }
            else{
                [self.userImage setImage:placeholderImage];
                [self.userImage addCircularMaskToBounds:self.userImage.frame];
            }
*/
            
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
            if (self.user.imageURL != nil) {
                [self.userImage setImageWithURL:[NSURL URLWithString:self.user.imageURL] placeholderImage:placeholderImage options:SDWebImageRefreshCached];
                [self.userImage addCircularMaskToBounds:self.userImage.frame];
            }
            else{
                [self.userImage setImage:placeholderImage];
                [self.userImage addCircularMaskToBounds:self.userImage.frame];
            }

            [self alertError:error];
        }];
        
        [self hideCancelAndSave];
        [self resignFirstResponder];
    }
    else{
        [SalutronUserProfile saveWithSalutronUserProfile:self.salutronUserProfile];
        DeviceEntity *deviceEntity          = [DeviceEntity deviceEntityForMacAddress:[SFAUserDefaultsManager sharedManager].macAddress];
        [UserProfileEntity userProfileWithSalutronUserProfile:self.salutronUserProfile forDeviceEntity:deviceEntity];
        [self saveHeightAndWeightToHealthStore];
        [self.tableView reloadData];
    }
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

#pragma mark - Change profile picture

- (IBAction)changeProfilePictureButtonClicked:(id)sender
{
    [UIActionSheet photoPickerWithTitle:LS_UPLOAD_PHOTO showInView:self.view presentVC:self onPhotoPicked:^(UIImage *chosenImage) {
        self.userImage.image = [chosenImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.image = [chosenImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.userImage addCircularMaskToBounds:self.userImage.frame];
        [self showCancelAndSave];
        self.profilePictureChanged = YES;
    } onCancel:^{
        self.profilePictureChanged = YES;
    }];
}

- (IBAction)menuButtonPressed:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)showCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    //self.saveButton.hidden = NO;
    UIBarButtonItem *newBackButton2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveChanges)];//[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"st_v4_navbar_ic_back"] style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    [newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.rightBarButtonItem = newBackButton2;
    
}

- (void)hideCancelAndSave{
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MenuIcon"] style:UIBarButtonItemStyleBordered target:self action:@selector(menuButtonPressed:)];
    //[newBackButton setImageInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
    self.navigationItem.leftBarButtonItem = newBackButton;
    self.navigationItem.rightBarButtonItem = nil;
}


#pragma mark - SFAProfileGenderCellDelegate

- (void)genderValueChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile{
    [self.view endEditing:YES];
    self.salutronUserProfile = salutronUserProfile;
    [self.tableView reloadData];
    [self showCancelAndSave];
}

- (void)profileDataChangedWithSalutronUserProfile:(SalutronUserProfile *)salutronUserProfile{
    self.salutronUserProfile = salutronUserProfile;
    [self showCancelAndSave];
}


- (void)cancelChanges{
    DDLogInfo(@"");
    
    
    SFAServerAccountManager *manager = [SFAServerAccountManager sharedManager];
    self.user = manager.user;
    self.salutronUserProfile = [SalutronUserProfile getData];
    [self hideCancelAndSave];
    [self.tableView reloadData];
    
    
    UIImage *placeholderImage           = [UIImage imageNamed:@"ProfileDefaultPicture"];
    if (self.user.imageURL != nil) {
        [self.userImage setImageWithURL:[NSURL URLWithString:self.user.imageURL] placeholderImage:placeholderImage options:SDWebImageRefreshCached];
        [self.userImage addCircularMaskToBounds:self.userImage.frame];
    }
    else{
        [self.userImage setImage:placeholderImage];
        [self.userImage addCircularMaskToBounds:self.userImage.frame];
    }
    
}


- (void)saveHeightAndWeightToHealthStore{
    DDLogInfo(@"");
    if([[SFAHealthKitManager sharedManager] isHealthKitAvailable]) {
        // [[SFAHealthKitManager sharedManager] requestAuthorizationWithSuccess:^(BOOL success) {
        //     if (success) {
        //SalutronUserProfile *userProfile = [SalutronUserProfile userProfile];
        [[SFAHealthKitManager sharedManager] saveHeight:(double)(self.salutronUserProfile.height/100.0)];
        [[SFAHealthKitManager sharedManager] saveWeight:round(self.salutronUserProfile.weight / 2.20462)];
        //      }
        //  } failure:^(NSError *error) {
        
        //  }];
    }
}
@end
