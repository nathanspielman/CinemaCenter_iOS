//
//  NDSXMLParser.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 3/4/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDSXMLParser : NSObject <NSXMLParserDelegate>

- (id)loadXMLByURL:(NSString *)urlString;

@end
