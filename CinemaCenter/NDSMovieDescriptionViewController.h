//
//  NDSMovieDescriptionViewController.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/10/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSMovieDescriptionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *movieLabel;
@property (weak, nonatomic) IBOutlet UITextView *movieDescriptionTextView;
@property (copy, nonatomic) NSString *movieTitle;
@property (copy, nonatomic) NSString *movieDescription;

@end
