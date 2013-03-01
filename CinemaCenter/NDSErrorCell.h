//
//  NDSErrorCell.h
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/11/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDSErrorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (copy, nonatomic) NSString *errorMessage;

@end
