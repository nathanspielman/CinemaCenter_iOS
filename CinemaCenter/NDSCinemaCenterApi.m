//
//  NDSCinemaCenterAPI.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 5/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSCinemaCenterApi.h"
#import "NDSCinemaCenterApiKeys.h"

@implementation NDSCinemaCenterApi

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id __httpClient = nil;
    dispatch_once(&pred, ^{
        __httpClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
        [__httpClient setParameterEncoding:AFJSONParameterEncoding];
        [__httpClient setDefaultHeader:@"Accept" value:@"application/json"];
        [__httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    });
    
    return __httpClient;
}

@end
