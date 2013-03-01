//
//  NDSMapViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/7/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMapViewController.h"

@interface NDSMapViewController ()

@property (nonatomic) BOOL loaded;

@property (strong, nonatomic) NDSMapAnnotation *ccAnnotation;

@end

@implementation NDSMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.loaded = NO;
    
    self.ccAnnotation = [[NDSMapAnnotation alloc]init];
    
    CLLocationCoordinate2D ccCoordinate;
    
    ccCoordinate.latitude = 41.080645;
    ccCoordinate.longitude = -85.133357;
    
    self.ccAnnotation.coordinate = ccCoordinate;
    self.ccAnnotation.title = @"Cinema Center";
    self.ccAnnotation.subtitle =@"437 E. Berry St. Fort Wayne, IN 46802";
    
    [self.mapView addAnnotation: self.ccAnnotation];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    //if (!self.loaded) {
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.ccAnnotation.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:NO];
        [self.mapView selectAnnotation:self.ccAnnotation animated:NO];
        
        self.loaded = YES;
    //}
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
