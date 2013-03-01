//
//  NDSMapViewController.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NDSMapAnnotation.h"

@interface NDSMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
