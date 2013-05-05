//
//  NDSCinemaCenterMovie.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 5/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDSCinemaCenterMovie : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, strong) UIImage *poster;
@property (nonatomic, copy) NSString *status;
@property (nonatomic) NSInteger position;

+ (void)getAllOnSuccess:(void (^)(NSArray *movies))success failure:(void (^)(NSError *error))failure path:(NSString *)path;

- (id)initWithAttributes:(NSDictionary *)attributes;

@end
