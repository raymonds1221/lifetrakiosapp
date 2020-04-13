//
//  SFAAmazonServiceManager.m
//  SalutronFitnessApp
//
//  Created by Christine Alcachupas on 10/6/15.
//  Copyright © 2015 Raymond Sarmiento. All rights reserved.
//

#import "SFAAmazonServiceManager.h"
#import <AWSS3/AWSS3.h>
#import "ZipArchive.h"
#import "SFAServerAccountManager.h"
#import "SFAServerSyncManager.h"

@interface SFAAmazonServiceManager ()

@property (strong, nonatomic) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (strong, nonatomic) AWSS3TransferManagerDownloadRequest *downloadRequest;
@property (nonatomic) NSInteger fileURLIndex;
@property (nonatomic) NSInteger retryCounter;
@property (strong, nonatomic) NSMutableArray *jsonFileURLs;
@property (strong, nonatomic) NSMutableArray *fileNamesForDownload;
@property (strong, nonatomic) DeviceEntity *deviceEntity;
@property (nonatomic) int totalNumberOfFiles;
@property (nonatomic) int currentNumberOfFiles;


@end

@implementation SFAAmazonServiceManager

#pragma mark - Singleton Instance

+ (SFAAmazonServiceManager *)sharedManager
{
    static SFAAmazonServiceManager *instance = nil;
    
    @synchronized(self) {
        if (!instance) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

- (void)uploadDataToS3:(NSString *)stringData{
    
    SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSString *uniqueString = serverAccountManager.accessToken;
    
    //Create a temporary directory
    NSError *error;
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:uniqueString] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    //Create a temporary file path
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:@"LifeTrakData.json"];
    
    
    //Write string data to a txt file
    NSError *error2;
    [stringData writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error2];
    
    //Get txt file
    //NSArray *paths = NSSearchPathForDirectoriesInDomains
    //(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *fileName = [NSString stringWithFormat:@"%@/LifeTrakData.txt", documentsDirectory];
    
    //Add txt file to zip
    NSString *zipFilename = @"LifeTrakData.zip";
    //NSString *dirPath = [paths objectAtIndex:0];
    //NSString *zipFile = [dirPath stringByAppendingPathComponent:zipFilename];
    
    NSURL *zipFileURL = [directoryURL URLByAppendingPathComponent:zipFilename];
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    [zipArchive CreateZipFile2:zipFileURL.relativePath];
    [zipArchive addFileToZip:fileURL.relativePath newname:@"LifetrakData.json"];
    [zipArchive CloseZipFile2];
    
    
    //Set up transfer manager upload request
    self.uploadRequest = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest.bucket = @"lifetrak-bulk-data";
    self.uploadRequest.key = [NSString stringWithFormat:@"%@/LifetraData.zip", uniqueString];//@"samplegeneratedid/LifeTrakData.zip";
    self.uploadRequest.body = zipFileURL;
    
    //Setup and execute transfer manager
    AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"USWest2S3TransferManager"];
    AWSTask *awsTaskResponse = [[transferManager upload:self.uploadRequest]
                                continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                withBlock:^id(AWSTask *task) {
                                    if (task.error) {
                                        if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                            switch (task.error.code) {
                                                case AWSS3TransferManagerErrorCancelled:
                                                case AWSS3TransferManagerErrorPaused:
                                                    break;
                                                    
                                                default:
                                                    DDLogInfo(@"Error: %@", task.error);
                                                    break;
                                            }
                                        } else {
                                            // Unknown error.
                                            DDLogInfo(@"Error: %@", task.error);
                                        }
                                        [self.delegate amazonServiceUploadFailedWithError:task.error];
                                    }
                                    
                                    if (task.result) {
                                        DDLogInfo(@"File upload successful. %@", task);
                                        [self.delegate amazonServiceUploadFinishedWithParameters:@{
                                            @"bucket"               : @"lifetrak-bulk-data",
                                            @"folder"               : uniqueString,
                                            @"path"                 : @"LifetrakData.zip",
                                            API_OAUTH_ACCESS_TOKEN  : uniqueString}];
                                        
                                    }
                                    //Delete zip file
                                    NSError *error = nil;
                                    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
                                    NSError *error2 = nil;
                                    [[NSFileManager defaultManager] removeItemAtURL:zipFileURL error:&error2];
                                    return nil;
                                }];
    
    DDLogInfo(@"response = %@", awsTaskResponse);
    //Track progress of upload
    self.uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress.
            DDLogInfo(@"%f, %f/%f (MB)", (float)bytesSent/1000000, (float)totalBytesSent/1000000, (float)totalBytesExpectedToSend/1000000);
            DDLogInfo(@"%f percent", ((float)totalBytesSent/1000000 / (float)totalBytesExpectedToSend/1000000) * 100);
        });
    };
#warning handle cancelled request
}


- (void)uploadArrayOfDataToS3:(NSArray *)dataArray{
    
    //SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
    NSString *uniqueString = [[NSUUID UUID] UUIDString];;//serverAccountManager.accessToken;
    
    //Create a temporary directory
    NSError *error;
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:uniqueString] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    //Create a temporary file path
    
    self.jsonFileURLs = [[NSMutableArray alloc] init];
    for (NSDictionary *dictionary in dataArray){
        NSString *stringData = dictionary[@"stringData"];
        NSString *dateOfData = [NSString stringWithFormat:@"%@", dictionary[@"date"]];
        NSString *macAddress = dictionary[@"macAddress"];
        NSString *jsonFileName = [NSString stringWithFormat:@"LifeTrakData%@.json", dateOfData];
        
        NSURL *jsonFileURL = [directoryURL URLByAppendingPathComponent:jsonFileName];
        NSDictionary *fileNameDetails = @{@"jsonFileURL" : jsonFileURL,
                                          @"date"        : dateOfData,
                                          @"uniqueString": uniqueString,
                                          @"macAddress": macAddress};
        if (![self.jsonFileURLs containsObject:fileNameDetails]) {
            [self.jsonFileURLs addObject:fileNameDetails];
            
            //Write string data to a txt file
            NSError *error2;
            [stringData writeToURL:jsonFileURL atomically:YES encoding:NSUTF8StringEncoding error:&error2];
            DDLogError(@"writeToURL - %@", error);
        }
//        [self.jsonFileURLs addObject:@{@"jsonFileURL" : jsonFileURL,
//                                  @"date"        : dateOfData,
//                                  @"uniqueString": uniqueString,
//                                    @"macAddress": macAddress}];
//        
//        //Write string data to a txt file
//        NSError *error2;
//        [stringData writeToURL:jsonFileURL atomically:YES encoding:NSUTF8StringEncoding error:&error2];
        
//        [self.jsonFileURLs addObject:@{@"jsonFileURL" : fileName,
//                                       @"date"        : dateOfData,
//                                       @"uniqueString": uniqueString}];
        
        /*
        //Get txt file
        //NSArray *paths = NSSearchPathForDirectoriesInDomains
        //(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString *documentsDirectory = [paths objectAtIndex:0];
        //NSString *fileName = [NSString stringWithFormat:@"%@/LifeTrakData.txt", documentsDirectory];
        
        //Add txt file to zip
        NSString *zipFilename = @"LifeTrakData.zip";
        //NSString *dirPath = [paths objectAtIndex:0];
        //NSString *zipFile = [dirPath stringByAppendingPathComponent:zipFilename];
        
        NSURL *zipFileURL = [directoryURL URLByAppendingPathComponent:zipFilename];
        
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        [zipArchive CreateZipFile2:zipFileURL.relativePath];
        [zipArchive addFileToZip:fileURL.relativePath newname:@"LifetrakData.json"];
        [zipArchive CloseZipFile2];
        */
        
    }
    self.fileURLIndex = 0;
    self.retryCounter = 0;
    [self uploadDataToS3ByDate:self.jsonFileURLs[self.fileURLIndex]];
}

- (void)uploadDataToS3ByDate:(NSDictionary *)jsonFileURL{
    NSURL *jsonURL = jsonFileURL[@"jsonFileURL"];
    NSString *dateOfData = jsonFileURL[@"date"];
    NSString *uniqueString = jsonFileURL[@"uniqueString"];
    NSString *macAddress = jsonFileURL[@"macAddress"];
    //Set up transfer manager upload request
    self.uploadRequest = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest.bucket = S3_BUCKET_NAME_STORE;
    self.uploadRequest.key = [NSString stringWithFormat:@"%@/LifetrakData%@.json", uniqueString, dateOfData];//@"samplegeneratedid/LifeTrakData.zip";
    self.uploadRequest.body = jsonURL;
    
    //Setup and execute transfer manager
    AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"USWest2S3TransferManager"];
    AWSTask *awsTaskResponse = [[transferManager upload:self.uploadRequest]
                                continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                withBlock:^id(AWSTask *task) {
                                    if (task.error) {
                                        if (self.retryCounter > 3) {
                                            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                switch (task.error.code) {
                                                    case AWSS3TransferManagerErrorCancelled:
                                                    case AWSS3TransferManagerErrorPaused:
                                                        break;
                                                        
                                                    default:
                                                        DDLogInfo(@"Error: %@", task.error);
                                                        break;
                                                }
                                            } else {
                                                // Unknown error.
                                                DDLogInfo(@"Error: %@", task.error);
                                            }
                                            [self.delegate amazonServiceUploadFailedWithError:task.error];
                                        }
                                        else{
                                            self.retryCounter++;
                                            [self uploadDataToS3ByDate:self.jsonFileURLs[self.fileURLIndex]];
                                        }
                                    }
                                    
                                    if (task.result) {
                                        self.fileURLIndex++;
                                        self.retryCounter = 0;
                                        DDLogInfo(@"File upload successful. %@", task);
                                        [self.delegate amazonServiceProgress:((float)self.fileURLIndex/(float)self.jsonFileURLs.count)*100];
                                        if (self.fileURLIndex >= self.jsonFileURLs.count) {
                                            
                                            DDLogInfo(@"Files uploaded to s3. %@", task);
                                            SFAServerAccountManager *serverAccountManager   = [SFAServerAccountManager sharedManager];
                                            NSString *accessToken = serverAccountManager.accessToken;
                                            [self.delegate amazonServiceUploadFinishedWithParameters:@{
                                                                                                       @"uuid"               : uniqueString,
                                                                                                API_OAUTH_ACCESS_TOKEN  : accessToken,
                                                                                                       @"mac_address" : macAddress}];
                                        } else{
                                            [self uploadDataToS3ByDate:self.jsonFileURLs[self.fileURLIndex]];
                                        }
                                        //Delete zip file
                                        NSError *error = nil;
                                        [[NSFileManager defaultManager] removeItemAtURL:jsonURL
                                                                                  error:&error];
                                        
                                        DDLogInfo(@"Removing file: %@", error);
                                    }
                                    return nil;
                                }];
    
    DDLogInfo(@"response = %@", awsTaskResponse);
    //Track progress of upload
    self.uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress.
            DDLogInfo(@"%f, %f/%f (MB)", (float)bytesSent/1000000, (float)totalBytesSent/1000000, (float)totalBytesExpectedToSend/1000000);
            DDLogInfo(@"%f percent", ((float)totalBytesSent/1000000 / (float)totalBytesExpectedToSend/1000000) * 100);
        });
    };
#warning handle cancelled request
}




- (void)cancelOperation{
    DDLogInfo(@"Upload Request Cancelled.");
    if(self.uploadRequest)
        [self.uploadRequest cancel];
    if (self.downloadRequest) {
        [self.downloadRequest cancel];
    }
}


- (void)downloadDataFromS3withBucketName:(NSString *)bucketName andFilesNames:(NSArray *)fileNames andFolderName:(NSString *)folderName andDeviceEntity:(DeviceEntity *)deviceEntity{
    self.deviceEntity = deviceEntity;
    self.fileNamesForDownload = [fileNames mutableCopy];
    self.retryCounter = 0;
    self.totalNumberOfFiles = self.fileNamesForDownload.count;
    self.currentNumberOfFiles = 0;
    [self getFileFromS3withFilename:self.fileNamesForDownload[0] andFolderName:folderName];
}


- (void)getFileFromS3withFilename:(NSString *)filename andFolderName:(NSString *)folderName{
    // Construct the NSURL for the download location.
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", folderName, filename]];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    // Construct the download request.
    self.downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    
    self.downloadRequest.bucket = S3_BUCKET_NAME_RESTORE;
    self.downloadRequest.key = [NSString stringWithFormat:@"%@/%@", folderName, filename];
    self.downloadRequest.downloadingFileURL = downloadingFileURL;
    
    // Download the file.
    AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"USWest2S3TransferManager"];
    AWSTask *awsTaskResponse =[[transferManager download:self.downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error){
                                                                   if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                                                                       switch (task.error.code) {
                                                                           case AWSS3TransferManagerErrorCancelled:
                                                                           case AWSS3TransferManagerErrorPaused:
                                                                               break;
                                                                               
                                                                           default:
                                                                               NSLog(@"Error: %@", task.error);
                                                                               break;
                                                                       }
                                                                   } else {
                                                                       // Unknown error.
                                                                       NSLog(@"Error: %@", task.error);
                                                                   }
                                                                   if (self.retryCounter < 3) {
                                                                       [self getFileFromS3withFilename:filename andFolderName:folderName];
                                                                       self.retryCounter++;
                                                                   }
                                                                   else{
                                                                       [self.delegate amazonServiceDownloadFailedWithError:task.error];
                                                                   }
                                                               }
                                                               
                                                               if (task.result) {
                                                                   self.currentNumberOfFiles++;
                                                                   [self.delegate amazonServiceProgress:((float)self.currentNumberOfFiles/(float)self.totalNumberOfFiles)*100];
                                                                   //convert results
                                                                   AWSS3TransferManagerDownloadOutput *downloadOutput = task.result;
                                                                   //File downloaded successfully.
                                                                   NSData *data = [NSData dataWithContentsOfFile:downloadingFilePath];
                                                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                                   
                                                                   NSError *error = nil;
                                                                   [[NSFileManager defaultManager] removeItemAtURL:downloadingFileURL
                                                                                                             error:&error];
                                                                   
                                                                   DDLogInfo(@"Removing file: %@", error);
                                                                   
                                                                   SFAServerSyncManager *serverSyncManager = [SFAServerSyncManager sharedManager];
                                                                   [serverSyncManager convertResultPerDay:json forDeviceEntity:self.deviceEntity isLastDay:self.fileNamesForDownload.count == 1];
                                                                   
                                                                   [self.fileNamesForDownload removeObjectAtIndex:0];
                                                                   if (self.fileNamesForDownload.count > 0) {
                                                                       [self getFileFromS3withFilename:self.fileNamesForDownload[0] andFolderName:folderName];
                                                                   }
                                                                   else{
                                                                       [self.delegate amazonServiceDownloadFinishedWithParameters:@{}];
                                                                   }
                                                               }
                                                               return nil;
                                                           }];
    DDLogInfo(@"response = %@", awsTaskResponse);
    //Track progress of upload
    self.downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update progress
            DDLogInfo(@"%f, %f/%f (MB)", (float)bytesWritten/1000000, (float)totalBytesWritten/1000000, (float)totalBytesExpectedToWrite/1000000);
            DDLogInfo(@"%f percent", ((float)totalBytesWritten / (float)totalBytesExpectedToWrite) * 100.0);
        });
    };
    
}

@end
