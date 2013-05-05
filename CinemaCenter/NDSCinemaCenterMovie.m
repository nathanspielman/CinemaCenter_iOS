//
//  NDSCinemaCenterMovie.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 5/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSCinemaCenterMovie.h"
#import "NDSCinemaCenterApi.h"
#import "NDSCinemaCenterApiKeys.h"

@implementation NDSCinemaCenterMovie

#pragma mark - Class methods
+ (NSArray *)arrayFromJsonArray:(NSArray *) jsonArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *mov in jsonArray)
    {
        NDSCinemaCenterMovie *movie = [[NDSCinemaCenterMovie alloc] initWithAttributes:mov];
        
        if (movie.poster != nil) {
            [array addObject:movie];
        }
    }
    
    return [array copy];
}

+ (void)getAllOnSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure path:(NSString *)path
{
    NSDictionary *options = @{};
    [[NDSCinemaCenterApi sharedInstance] getPath:path parameters:options success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *movies = [NDSCinemaCenterMovie arrayFromJsonArray:responseObject];
        success(movies);
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
        _title = [attributes valueForKey:kTitle];
        _description = [attributes valueForKey:kDescription];
        
        _poster = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[attributes valueForKey:kPoster]]]];
        _status = [attributes valueForKey:kStatus];
        _position = [[attributes valueForKey:kPosition] integerValue];
    }
    
    return self;
}

@end
