//
//  ITCTableViewDelegate.m
//  SDKSample
//
//  Copyright 2014 Intercom
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "ITCTableViewDelegate.h"
#import "ITCUtils.h"
#import "ITCUserAuthenticationManager.h"
#import "ITCEmailAlertViewDelegate.h"
#import "ITCUserIdAlertViewDelegate.h"
#import "ITCSDKHandler.h"
#import "ITCIntercomSettings.h"

@interface ITCTableViewDelegate ()
@property (nonatomic, weak)   UITableView *tableView;
@property (nonatomic, strong) ITCEmailAlertViewDelegate *emailAlertViewDelegate;
@property (nonatomic, strong) ITCUserIdAlertViewDelegate *userIdAlertViewDelegate;
@property (nonatomic, strong) ITCSDKHandler *intercomSDKManager;
@end


@implementation ITCTableViewDelegate

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ITCCellType type = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    
    if (!self.intercomSDKManager) {
        self.intercomSDKManager = [[ITCSDKHandler alloc] init];
    }

    if (![ITCUserAuthenticationManager sharedAuthenticationManager].isUserAuthenticated) {
        self.tableView = tableView;
        
        if (type == ITCCellTypeBeginSessionEmail) {
            [self promptForUserEmailWithSDKManager:self.intercomSDKManager];
            
        } else if (type == ITCCellTypeBeginSessionUserId) {
            [self promptForUserIdWithSDKManager:self.intercomSDKManager];
            
        }
        
    } else if (![ITCUserAuthenticationManager sharedAuthenticationManager].isIntercomSessionOpen) {
        // no action required - tring to establish a session with Intercom

    } else {
        
        if (type == ITCCellTypeUpdateUser) {
            [self.intercomSDKManager handleUpdateUser];
            
        } else if (type == ITCCellTypeUpdateCompany) {
            [self.intercomSDKManager handleUpdateCompany];
            
        } else if (type == ITCCellTypeUpdateCustomAttributes) {
            [self.intercomSDKManager handleUpdateCustomAttributes];
            
        } else if (type == ITCCellTypeSubmitEvent) {
            [self.intercomSDKManager handleSubmitEvent];
            
        } else if (type == ITCCellTypeSubmitEventWithMetaData) {
            [self.intercomSDKManager handleSubmitEventWithMetaData];
            
        } else if (type == ITCCellTypePresentMessageComposer) {
            // add a dispatch_async here to avoid the following warning in the console: +[CATransaction synchronize] called within transaction
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.intercomSDKManager handlePresentMessageComposer];
            });
            
        } else if (type == ITCCellTypePresentConversationList) {
            // add a dispatch_async here to avoid the following warning in the console: +[CATransaction synchronize] called within transaction
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.intercomSDKManager handlePresentConversationList];
            });
            
        } else if (type == ITCCellTypeEndSession) {
            [[ITCUserAuthenticationManager sharedAuthenticationManager] setUserAuthenticated:NO];
            [self.intercomSDKManager handleEndSession];    // reloading will hide all cells except the 'Begin Session' one
        }
    }
}

#pragma mark - Private methods

- (void)promptForUserEmailWithSDKManager:(ITCSDKHandler *)intercomSDKManager {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Email"
                                                        message:@"Accept default email or enter new one"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Log In", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].text = [ITCUserAuthenticationManager sharedAuthenticationManager].email ? : kIntercomSampleUserEmail;
    self.emailAlertViewDelegate = [[ITCEmailAlertViewDelegate alloc] initWithDelegate:intercomSDKManager];
    alertView.delegate = self.emailAlertViewDelegate;
    [alertView show];
}

- (void)promptForUserIdWithSDKManager:(ITCSDKHandler *)intercomSDKManager {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Id"
                                                        message:@"Accept default userId or enter new one"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Log In", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].text = [ITCUserAuthenticationManager sharedAuthenticationManager].userId ? : kIntercomSampleUserId;
    self.userIdAlertViewDelegate = [[ITCUserIdAlertViewDelegate alloc] initWithDelegate:intercomSDKManager];
    alertView.delegate = self.userIdAlertViewDelegate;
    [alertView show];
}

#pragma mark - Designated Initializer

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end