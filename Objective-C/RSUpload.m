//
//  RSUpload.m
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

@interface RSUpload () <RSListenerDelegate>

@property (nonatomic,strong) NSMutableArray *delegates;

@end

@implementation RSUpload

@synthesize delegates;

+ (RSUpload *)sharedInstance
{
    static RSUpload *sharedInstance;
    if (!sharedInstance) {
        sharedInstance = [[RSUpload alloc]init];
        sharedInstance.delegates = [NSMutableArray array];
        [[RSListener sharedListener]addDelegate:sharedInstance];
    }
    return sharedInstance;
}

+ (void)uploadFile:(NSString *)fileName
{
    NSArray *contactList = [RSUtilities onlineNeighbours];
    
    for (NSUInteger i = 0; i < K_NEIGHBOUR; i++) {
        if (i < contactList.count) {
            NSString *messageString = [NSString stringWithFormat:@"UFILE_%@;%@;%ld",fileName,[RSUtilities getLocalIPAddress],(unsigned long)TTL];
            RSMessager *message = [RSMessager messagerWithPort:UPLOAD_PORT];
            [message addDelegate:[RSListener sharedListener]];
            [message sendTcpMessage:messageString toHost:[contactList objectAtIndex:i] tag:0];
        }
    }
}

+ (void)uploadFile:(NSString *)fileName toHost:(NSString *)host
{
    NSString *messageString = [NSString stringWithFormat:@"SENDFILE_%@;%@;%d;%@",fileName,[NSData dataWithContentsOfFile:[STORED_DATA_DIRECTORY stringByAppendingString:fileName]],0,[RSUtilities getLocalIPAddress]];
    RSMessager *message = [RSMessager messagerWithPort:UPLOAD_PORT];
    [message addDelegate:[RSListener sharedListener]];
    [message sendTcpMessage:messageString toHost:host tag:0];
}

- (void)addDelegate:(id <RSUploadDelegate>)delegate
{
    if (![delegates containsObject:delegate]) {
        [delegates addObject:delegate];
    }
}

#pragma mark - RSListenerDelegate

- (void)didUploadFile:(NSString *)fileName
{
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:@selector(didUploadFile:)]) {
            [delegate didUploadFile:fileName];
        }
    }
}

@end