//
//  SFAServerSyncViewController.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla   on 5/14/14.
//  Copyright (c) 2014 Raymond Sarmiento. All rights reserved.
//

#import "SVProgressHUD.h"

#import "JDACoreData.h"

#import "DeviceEntity+Data.h"
#import "SFAGoalsData.h"

#import "SFAServerSyncManager.h"
#import "SFAServerSyncViewController.h"
#import "UIViewController+Helper.h"
#import "SFASessionExpiredErrorAlertView.h"
#import "SFALoadingViewController.h"
#import "SFAServerAccountManager.h"
#import "SFAIntroViewController.h"
#import "SFALoadingViewController.h"
#import "NSDate+Format.h"
#import "NSDate+Formatter.h"
#import "SFASalutronFitnessAppDelegate.h"
#import "SFAAmazonServiceManager.h"

#define DASHBOARD_SEGUE_IDENTIFIER @"ServerSyncToDashboard"

@interface SFAServerSyncViewController () <UIAlertViewDelegate, SFASessionExpiredErrorAlertViewDelegate, SFAAmazonServiceManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *serverSyncImage;
@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (strong, nonatomic) SFASessionExpiredErrorAlertView *sessionExpiredAlertView;
@property (nonatomic) BOOL isNewlyLoaded;

@end

@implementation SFAServerSyncViewController

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isNewlyLoaded = YES;
    
    //if ([self.deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
        self.progress.text = PLEASE_WAIT;
        self.progress.hidden = NO;
//    }
//    else{
//        self.progress.hidden = YES;
//    }
    
    self.serverSyncImage.animationDuration  = 1.0f;
    self.serverSyncImage.animationImages    = @[[UIImage imageNamed:@"ServerSync01"],
                                                [UIImage imageNamed:@"ServerSync02"],
                                                [UIImage imageNamed:@"ServerSync03"],
                                                [UIImage imageNamed:@"ServerSync04"],
                                                [UIImage imageNamed:@"ServerSync05"],
                                                [UIImage imageNamed:@"ServerSync06"],
                                                [UIImage imageNamed:@"ServerSync07"],
                                                [UIImage imageNamed:@"ServerSync08"],
                                                [UIImage imageNamed:@"ServerSync09"],
                                                [UIImage imageNamed:@"ServerSync10"],
                                                [UIImage imageNamed:@"ServerSync11"]];
    
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.serverSyncImage startAnimating];
    self.navigationController.navigationBar.backItem.title = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.serverSyncImage stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isNewlyLoaded) {
        [self startServerSync];
        self.isNewlyLoaded = NO;
    }
}

#pragma mark - UIAlertView Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self startServerSync];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private Methods

- (void)startServerSync
{
    SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
    if (self.deviceEntity.header.count > 0) {
        //if ([self.deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
            [serverSyncManager restoreDeviceEntityAPIV2:self.deviceEntity
                                   startDateString:[self.deviceEntity.updatedSynced getDateStringWithFormat:API_DATE_FORMAT]
                                     endDateString:[[NSDate date] getDateStringWithFormat:API_DATE_FORMAT] success:^(NSDictionary *response) {
                NSString *bucketName = response[@"bucket"];
                NSString *folderName = response[@"uuid"];
                NSArray *filenames = response[@"files"];
                
                SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
                amazonServiceManager.delegate = self;
                                         if (filenames.count > 0) {
                                             
                                             [amazonServiceManager downloadDataFromS3withBucketName:bucketName
                                                                                      andFilesNames:filenames
                                                                                      andFolderName:folderName
                                                                                    andDeviceEntity:self.deviceEntity];
                                         }
                                         else{
                                             DDLogError(@"no files to download from s3. response = %@", response);
                                             if (self.isIOS8AndAbove) {
                                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                                                          message:NSLocalizedString(SERVER_ERROR_MESSAGE, nil)
                                                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                                                 
                                                 UIAlertAction *cancelAction = [UIAlertAction
                                                                                actionWithTitle:BUTTON_TITLE_CANCEL
                                                                                style:UIAlertActionStyleDefault
                                                                                handler:^(UIAlertAction *action)
                                                                                {
                                                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                                                }];
                                                 UIAlertAction *retryAction = [UIAlertAction
                                                                               actionWithTitle:BUTTON_TITLE_RETRY
                                                                               style:UIAlertActionStyleDefault
                                                                               handler:^(UIAlertAction *action)
                                                                               {
                                                                                   [self startServerSync];
                                                                               }];
                                                 
                                                 [alertController addAction:cancelAction];
                                                 [alertController addAction:retryAction];
                                                 
                                                 [self presentViewController:alertController animated:YES completion:nil];
                                             }
                                             else{
                                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                                                     message:NSLocalizedString(SERVER_ERROR_MESSAGE, nil)
                                                                                                    delegate:self
                                                                                           cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                                                           otherButtonTitles:BUTTON_TITLE_RETRY, nil];
                                                 
                                                 [alertView show];
                                             }
                                         }
                                         
                                         
                
            } failure:^(NSError *error) {
                DDLogError(@"server restore error - %@", error);
                if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
                    [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
                }
                else {
                    NSString *errorMessage = error.localizedDescription;
                    if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound) {
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
                         else{
                             errorMessage = SERVER_ERROR_MESSAGE;
                         }
                    if (self.isIOS8AndAbove) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                                 message:NSLocalizedString(errorMessage, nil)
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction
                                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                       }];
                        UIAlertAction *retryAction = [UIAlertAction
                                                      actionWithTitle:BUTTON_TITLE_RETRY
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                                      {
                                                          [self startServerSync];
                                                      }];
                        
                        [alertController addAction:cancelAction];
                        [alertController addAction:retryAction];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                            message:NSLocalizedString(errorMessage, nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                                  otherButtonTitles:BUTTON_TITLE_RETRY, nil];
                        
                        [alertView show];
                    }
                }
            }];
//        }else{
//            [serverSyncManager restoreDeviceEntity:self.deviceEntity
//                                   startDateString:[self.deviceEntity.updatedSynced getDateStringWithFormat:API_DATE_FORMAT]
//                                     endDateString:[[NSDate date] getDateStringWithFormat:API_DATE_FORMAT]
//                                           success:^{
//                                               [self initializeGoals];
//                                               [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
//                                           } failure:^(NSError *error) {
//                                               //[SVProgressHUD dismiss];
//                                               DDLogError(@"server restore error - %@", error);
//                                               if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
//                                                   [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
//                                               }
//                                               else {
//                                                   NSString *errorMessage = error.localizedDescription;
//                                                   if (error.code == 408 || error.code == 503 || error.code == 504) {
//                                                       errorMessage = SERVER_ERROR_MESSAGE;
//                                                   }
//                                                   else if ([errorMessage isEqualToString:LS_REQUEST_TIMEOUT] || [errorMessage rangeOfString:SERVER_ERROR_PARSE].location != NSNotFound) {
//                                                       errorMessage = SERVER_ERROR_MESSAGE;
//                                                   }
//                                                   else if ([errorMessage rangeOfString:SERVER_ERROR_COCOA].location != NSNotFound) {
//                                                       errorMessage = SERVER_ERROR_MESSAGE_COCOA;
//                                                   }
//                                                   else if ([errorMessage rangeOfString:NO_INTERNET_ERROR].location != NSNotFound){
//                                                       errorMessage = NO_INTERNET_ERROR_MESSAGE;
//                                                   }
//                                                   //     else{
//                                                   //         errorMessage = SERVER_ERROR_MESSAGE;
//                                                   //     }
//                                                   if (self.isIOS8AndAbove) {
//                                                       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
//                                                                                                                                message:NSLocalizedString(errorMessage, nil)
//                                                                                                                         preferredStyle:UIAlertControllerStyleAlert];
//                                                       
//                                                       UIAlertAction *cancelAction = [UIAlertAction
//                                                                                      actionWithTitle:BUTTON_TITLE_CANCEL
//                                                                                      style:UIAlertActionStyleDefault
//                                                                                      handler:^(UIAlertAction *action)
//                                                                                      {
//                                                                                          [self dismissViewControllerAnimated:YES completion:nil];
//                                                                                      }];
//                                                       UIAlertAction *retryAction = [UIAlertAction
//                                                                                     actionWithTitle:BUTTON_TITLE_RETRY
//                                                                                     style:UIAlertActionStyleDefault
//                                                                                     handler:^(UIAlertAction *action)
//                                                                                     {
//                                                                                         [self startServerSync];
//                                                                                     }];
//                                                       
//                                                       [alertController addAction:cancelAction];
//                                                       [alertController addAction:retryAction];
//                                                       
//                                                       [self presentViewController:alertController animated:YES completion:nil];
//                                                   }
//                                                   else{
//                                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
//                                                                                                           message:NSLocalizedString(errorMessage, nil)
//                                                                                                          delegate:self
//                                                                                                 cancelButtonTitle:BUTTON_TITLE_CANCEL
//                                                                                                 otherButtonTitles:BUTTON_TITLE_RETRY, nil];
//                                                       
//                                                       [alertView show];
//                                                   }
//                                               }
//                                               
//                                           }];
//        }
    
    }
    else{
        //if ([self.deviceEntity.modelNumber isEqualToNumber:@(WatchModel_R420)]) {
            [serverSyncManager restoreDeviceEntityAPIV2:self.deviceEntity success:^(NSDictionary *response) {
                NSString *bucketName = response[@"bucket"];
                NSString *folderName = response[@"uuid"];
                NSArray *filenames = response[@"files"];
                
                SFAAmazonServiceManager *amazonServiceManager = [SFAAmazonServiceManager sharedManager];
                amazonServiceManager.delegate = self;
                if (filenames.count > 0) {
                    
                    [amazonServiceManager downloadDataFromS3withBucketName:bucketName
                                                             andFilesNames:filenames
                                                             andFolderName:folderName
                                                           andDeviceEntity:self.deviceEntity];
                }
                else{
                    DDLogError(@"no files to download from s3. response = %@", response);
                    if (self.isIOS8AndAbove) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                                 message:NSLocalizedString(SERVER_ERROR_MESSAGE, nil)
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction
                                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                       }];
                        UIAlertAction *retryAction = [UIAlertAction
                                                      actionWithTitle:BUTTON_TITLE_RETRY
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                                      {
                                                          [self startServerSync];
                                                      }];
                        
                        [alertController addAction:cancelAction];
                        [alertController addAction:retryAction];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                            message:NSLocalizedString(SERVER_ERROR_MESSAGE, nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                                  otherButtonTitles:BUTTON_TITLE_RETRY, nil];
                        
                        [alertView show];
                    }

                }

            } failure:^(NSError *error) {
                //[SVProgressHUD dismiss];
                
                DDLogError(@"server restore error - %@", error);
                if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
                    [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
                }
                else {
                    NSString *errorMessage = error.localizedDescription;
                    if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound) {
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
                     else{
                         errorMessage = SERVER_ERROR_MESSAGE;
                     }
                    if (self.isIOS8AndAbove) {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                                 message:NSLocalizedString(errorMessage, nil)
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction
                                                       actionWithTitle:BUTTON_TITLE_CANCEL
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                       }];
                        UIAlertAction *retryAction = [UIAlertAction
                                                      actionWithTitle:BUTTON_TITLE_RETRY
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                                      {
                                                          [self startServerSync];
                                                      }];
                        
                        [alertController addAction:cancelAction];
                        [alertController addAction:retryAction];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                            message:NSLocalizedString(errorMessage, nil)
                                                                           delegate:self
                                                                  cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                                  otherButtonTitles:BUTTON_TITLE_RETRY, nil];
                        
                        [alertView show];
                    }
                }
                
            }];
//        }
//        else{
//        [serverSyncManager restoreDeviceEntity:self.deviceEntity success:^{
//            //[SVProgressHUD showSuccessWithStatus:@"Restore from Server successful."];
//            //        NSDate *date                    = [NSDate date];
//            //        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
//            //        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
//            //        [userDefaults setObject:data forKey:self.deviceEntity.macAddress];
//            
//            [self initializeGoals];
//            [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
//        } failure:^(NSError *error) {
//            //[SVProgressHUD dismiss];
//            
//            DDLogError(@"server restore error - %@", error);
//            if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
//                [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
//            }
//            else {
//                NSString *errorMessage = error.localizedDescription;
//                if (error.code == 408 || error.code == 503 || error.code == 504) {
//                    errorMessage = SERVER_ERROR_MESSAGE;
//                }
//                else if ([errorMessage isEqualToString:LS_REQUEST_TIMEOUT] || [errorMessage rangeOfString:SERVER_ERROR_PARSE].location != NSNotFound) {
//                    errorMessage = SERVER_ERROR_MESSAGE;
//                }
//                else if ([errorMessage rangeOfString:SERVER_ERROR_COCOA].location != NSNotFound) {
//                    errorMessage = SERVER_ERROR_MESSAGE_COCOA;
//                }
//                else if ([errorMessage rangeOfString:NO_INTERNET_ERROR].location != NSNotFound){
//                    errorMessage = NO_INTERNET_ERROR_MESSAGE;
//                }
//               // else{
//               //     errorMessage = SERVER_ERROR_MESSAGE;
//               // }
//                if (self.isIOS8AndAbove) {
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
//                                                                                             message:NSLocalizedString(errorMessage, nil)
//                                                                                      preferredStyle:UIAlertControllerStyleAlert];
//                    
//                    UIAlertAction *cancelAction = [UIAlertAction
//                                                   actionWithTitle:BUTTON_TITLE_CANCEL
//                                                   style:UIAlertActionStyleDefault
//                                                   handler:^(UIAlertAction *action)
//                                                   {
//                                                       [self dismissViewControllerAnimated:YES completion:nil];
//                                                   }];
//                    UIAlertAction *retryAction = [UIAlertAction
//                                                  actionWithTitle:BUTTON_TITLE_RETRY
//                                                  style:UIAlertActionStyleDefault
//                                                  handler:^(UIAlertAction *action)
//                                                  {
//                                                      [self startServerSync];
//                                                  }];
//                    
//                    [alertController addAction:cancelAction];
//                    [alertController addAction:retryAction];
//                    
//                    [self presentViewController:alertController animated:YES completion:nil];
//                }
//                else{
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
//                                                                    message:NSLocalizedString(errorMessage, nil)
//                                                                   delegate:self
//                                                          cancelButtonTitle:BUTTON_TITLE_CANCEL
//                                                          otherButtonTitles:BUTTON_TITLE_RETRY, nil];
//                
//                [alertView show];
//                }
//            }
//            
//        }];
//        }
    }
    
	/*
    
	[serverSyncManager syncDeviceEntity:self.deviceEntity startDate:[NSDate UTCDateFromString:[self.deviceEntity.lastDateSynced getDateString] withFormat:API_DATE_FORMAT] endDate:[NSDate UTCDateFromString:[[NSDate date] getDateString] withFormat:API_DATE_FORMAT] withSuccess:^(NSString *macAddress) {
			//[SVProgressHUD showSuccessWithStatus:@"Restore from Server successful."];
			//        NSDate *date                    = [NSDate date];
			//        NSData *data                    = [NSKeyedArchiver archivedDataWithRootObject:date];
			//        NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
			//        [userDefaults setObject:data forKey:self.deviceEntity.macAddress];
		
		[self initializeGoals];
		[self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
	} failure:^(NSError *error) {
			//[SVProgressHUD dismiss];
		
		if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
			[self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
		}
		else {
			NSString *errorMessage = error.localizedDescription;
			if (error.code == 408) {
				errorMessage = SERVER_ERROR_MESSAGE;
			}
			else if ([error.localizedDescription isEqualToString:@"The request timed out."]) {
				errorMessage = SERVER_ERROR_MESSAGE;
			}
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
																message:errorMessage
															   delegate:self
													  cancelButtonTitle:BUTTON_TITLE_CANCEL
													  otherButtonTitles:BUTTON_TITLE_RETRY, nil];
			
			[alertView show];
		}
	}];
     */
}

- (void)initializeGoals
{
    NSUserDefaults *userDefaults    = [NSUserDefaults standardUserDefaults];
    JDACoreData *coreData           = [JDACoreData sharedManager];
    GoalsEntity *goal               = [SFAGoalsData goalsFromNearestDate:[NSDate date]
                                                              macAddress:self.deviceEntity.macAddress
                                                           managedObject:coreData.context];
    
    [userDefaults setObject:goal.steps forKey:STEP_GOAL];
    [userDefaults setObject:goal.distance forKey:DISTANCE_GOAL];
    [userDefaults setObject:goal.calories forKey:CALORIE_GOAL];
    [userDefaults setObject:goal.sleep forKey:SLEEP_GOAL];
}

#pragma mark - Lazy loading of properties

- (SFASessionExpiredErrorAlertView *)sessionExpiredAlertView
{
    if (!_sessionExpiredAlertView) {
        _sessionExpiredAlertView = [[SFASessionExpiredErrorAlertView alloc] init];
    }
    return _sessionExpiredAlertView;
}

#pragma mark - SFASessionExpiredErrorAlertView delegate methods

- (void)sessionExpiredAlertViewCancelButtonClicked:(SFASessionExpiredErrorAlertView *)errorAlertView
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)sessionExpiredAlertViewContinueButtonClicked:(SFASessionExpiredErrorAlertView *)errorAlertView
{
    SFAServerAccountManager *manager        = [SFAServerAccountManager sharedManager];
    [manager logOut];
    /*
    SFAIntroViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SFAIntroViewController"];

    [self presentViewController:viewController animated:YES completion:nil];
     */
    SFALoadingViewController *rootController=(SFALoadingViewController *)((SFASalutronFitnessAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    [rootController returnToRoot];
}


- (void)amazonServiceDownloadFinishedWithParameters:(NSDictionary *)parameters{
    //convert results
    [self initializeGoals];
    [self performSegueWithIdentifier:DASHBOARD_SEGUE_IDENTIFIER sender:self];
}

- (void)amazonServiceDownloadFailedWithError:(NSError *)error{
    DDLogError(@"server restore error - %@", error);
    if ([error.localizedDescription isEqualToString:API_ERROR_REFRESH_TOKEN_INVALID]){
        [self.sessionExpiredAlertView showAlertViewWithTitle:LS_SESSION_EXPIRED message:LS_SESSION_EXPIRED_MESSAGE delegate:self];
    }
    else {
        NSString *errorMessage = error.localizedDescription;
        if (error.code == 408 || error.code == 503 || error.code == 504 || [error.description rangeOfString:DEFAULT_SERVER_ERROR].location != NSNotFound) {
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
         else{
             errorMessage = SERVER_ERROR_MESSAGE;
         }
        if (self.isIOS8AndAbove) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ERROR_TITLE
                                                                                     message:NSLocalizedString(errorMessage, nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:BUTTON_TITLE_CANCEL
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           }];
            UIAlertAction *retryAction = [UIAlertAction
                                          actionWithTitle:BUTTON_TITLE_RETRY
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *action)
                                          {
                                              [self startServerSync];
                                          }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:retryAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ERROR_TITLE
                                                                message:NSLocalizedString(errorMessage, nil)
                                                               delegate:self
                                                      cancelButtonTitle:BUTTON_TITLE_CANCEL
                                                      otherButtonTitles:BUTTON_TITLE_RETRY, nil];
            
            [alertView show];
        }
    }
}

- (void)amazonServiceProgress:(int)progress{
    self.progress.text = [NSString stringWithFormat:@"%i%@", progress, @"%"];
}

@end
