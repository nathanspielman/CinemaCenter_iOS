//
//  NDSMapAnnotation.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/8/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NDSMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *title;

@end
