//
//  NDSScheduleFilmCell.m
//  CinemaCenter
//
//  Created by Nathan Spielman on 1/3/13.
//  Copyright (c) 2013 Nathan Spielman. All rights reserved.
//

#import "NDSScheduleFilmCell.h"

@implementation NDSScheduleFilmCell

- (void)centerText
{
    UITextView  *textView = self.showtimesTextView;
        
    CGFloat heightFix = ([textView bounds].size.height - [textView contentSize].height) / 2;
    CGFloat widthFix = ([textView bounds].size.width - [textView contentSize].width) / 2;
        
    textView.contentOffset = (CGPoint){.x = widthFix, .y = -heightFix};
}

@end
