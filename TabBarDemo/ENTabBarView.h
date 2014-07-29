//
//  ENTabBarView.h
//  TabBarDemo
//
//  Created by Aaron Elkins on 7/25/14.
//  Copyright (c) 2014 PixelEgg. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ENTabCell.h"

@interface ENTabBarView : NSView<NSMenuDelegate>{
    NSMutableArray *tabs;
    NSBezierPath *tabListControlPath;
    NSTrackingArea *trackingArea;
    NSMenu *menu;
    
    BOOL isDragging;
    NSInteger destinationIndex;
    NSInteger sourceIndex;
    ENTabCell *draggingTab;
}


@property (readwrite) NSFont *tabFont;
@property (readwrite) NSMutableArray *tabs;
@property (readwrite) ENTabCell *selectedTab;
@property (readwrite) NSColor *bgColor;
@property (readwrite) NSColor *tabBGColor;
@property (readwrite) NSColor *tabActivedBGColor;
@property (readwrite) NSColor *tabBorderColor;
@property (readwrite) NSColor *tabTitleColor;
@property (readwrite) NSColor *tabActivedTitleColor;
@property (readwrite) NSColor *smallControlColor;

- (id)addTabViewWithTitle:(NSString *)title;
- (void)redraw;
- (void)removeTabCell:(ENTabCell*)tabCell;
@end
