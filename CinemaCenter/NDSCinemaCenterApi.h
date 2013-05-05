//
//  NDSCinemaCenterAPI.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 5/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NDSCinemaCenterApi : AFHTTPClient

+ (id)sharedInstance;

@end
