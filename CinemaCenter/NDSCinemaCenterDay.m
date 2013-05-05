//
//  NDSDay.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 5/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSCinemaCenterDay.h"
#import "NDSCinemaCenterApi.h"
#import "NDSCinemaCenterApiKeys.h"

@implementation NDSCinemaCenterDay

#pragma mark - Class methods
+ (NSArray *)arrayFromJsonArray:(NSArray *) jsonArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *da in jsonArray)
    {
        NDSCinemaCenterDay *day = [[NDSCinemaCenterDay alloc] initWithAttributes:da];
        [array addObject:day];
    }
    
    return [array copy];
}

+ (void)getAllOnSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure
{
    NSDictionary *options = @{};
    [[NDSCinemaCenterApi sharedInstance] getPath:kScheduleUrl parameters:options success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *days = [NDSCinemaCenterDay arrayFromJsonArray:responseObject];
        success(days);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

#pragma mark - Instance methods
- (id)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (self)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        _date = [df dateFromString:[attributes valueForKey:kDate]];
        _showtimes = [attributes valueForKey:kShowtimes];
    }
    
    return self;
}

@end
