//
//  NDSXMLParser.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 3/4/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSXMLParser.h"

@interface NDSXMLParser ()

@property (strong, nonatomic) NSXMLParser *parser;
@property (strong, nonatomic) NSMutableString *currentNodeContent;

@end

@implementation NDSXMLParser

-(id) loadXMLByURL:(NSString *)urlString
{
	NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
	self.parser = [[NSXMLParser alloc] initWithData:data];
	self.parser.delegate = self;
	[self.parser parse];
    
	return self;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    NSLog(@"%@", elementname);
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{

}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	self.currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //NSLog(@"%@", self.currentNodeContent);
}

@end
