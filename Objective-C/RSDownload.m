//
//  RSDownload.m
//  RevS
//
//  Created by Zebang Liu on 13-8-1.
//  Copyright (c) 2013年 Zebang Liu. All rights reserved.
//  Contact: the.great.lzbdd@gmail.com
/*
 This file is part of RevS.
 
 RevS is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 RevS is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with RevS.  If not, see <http://www.gnu.org/licenses/>.
 */


#import "RevS.h"

@interface RSDownload () <RSListenerDelegate>

@property (nonatomic,strong) NSMutableArray *delegates;
@property (nonatomic,strong) RSMessenger *messenger;

@end

@implementation RSDownload

@synthesize delegates,messenger;

+ (RSDownload *)sharedInstance
{
    static RSDownload *sharedInstance;
    if (!sharedInstance) {
        sharedInstance = [[RSDownload alloc]init];
        sharedInstance.delegates = [NSMutableArray array];
        sharedInstance.messenger = [RSMessenger messengerWithPort:DOWNLOAD_PORT];
        [sharedInstance.messenger addDelegate:[RSListener sharedListener]];
        [RSListener addDelegate:sharedInstance];
    }
    return sharedInstance;
}

+ (void)downloadFile:(NSString *)fileName;
{
    NSArray *contactList = [RSUtilities contactListWithKValue:K];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@:gotAHit",fileName]];
    //Send search query
    for (NSString *ipAddress in contactList) {
        NSString *messageString = [RSMessenger messageWithIdentifier:@"S" arguments:@[[RSUtilities getLocalIPAddress],[RSUtilities getLocalIPAddress],fileName,[NSString stringWithFormat:@"%ld",(unsigned long)TTL]]];
        [[RSDownload sharedInstance].messenger sendTcpMessage:messageString toHost:ipAddress tag:0];
    }
}

+ (void)downloadFile:(NSString *)fileName fromIP:(NSString *)ipAddress
{
    [[RSDownload sharedInstance].messenger sendTcpMessage:[RSMessenger messageWithIdentifier:@"DFILE" arguments:@[fileName,[RSUtilities getLocalIPAddress]]] toHost:ipAddress tag:0];
}

+ (void)addDelegate:(id <RSDownloadDelegate>)delegate
{
    if (![[RSDownload sharedInstance].delegates containsObject:delegate]) {
        [[RSDownload sharedInstance].delegates addObject:delegate];
    }
}

#pragma mark - RSListenerDelegate

- (void)didSaveFile:(NSString *)fileName
{
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didDownloadFile:)]) {
            [delegate didDownloadFile:fileName];
        }
    }
}

@end