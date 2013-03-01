//
//  NDSMovieDescriptionViewController.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/10/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSMovieDescriptionViewController.h"

@interface NDSMovieDescriptionViewController ()

@end

@implementation NDSMovieDescriptionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.movieLabel.text = self.movieTitle;
    
    self.movieDescriptionTextView.text = self.movieDescription;
}

@end
