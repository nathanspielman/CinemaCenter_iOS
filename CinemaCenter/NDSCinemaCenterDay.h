//
//  NDSDay.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 5/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDSCinemaCenterDay : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic, copy) NSString *showtimes;

+ (void)getAllOnSuccess:(void (^)(NSArray *days))success failure:(void (^)(NSError *error))failure;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
