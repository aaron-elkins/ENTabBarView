//
//  ENTabBarView.m
//  TabBarDemo
//
//  Created by Aaron Elkins on 7/25/14.
//  Copyright (c) 2014 PixelEgg. All rights reserved.
//

#import "ENTabBarView.h"

#define kTabBarViewHeight 32
#define kWidthOfTabList 24
#define kHeightOfTabList 28
#define kMaxTabCellWidth 168
#define kTabCellHeight 28

@interface ENTabBarView (Expose)
- (NSRect)tabRectFromIndex:(NSUInteger)index;
- (NSRect)rectForTabListControl;
- (BOOL)isBlankAreaOfTabBarViewInPoint:(NSPoint)p;
+ (NSMenu *)defaultMenu;
@end

@implementation ENTabBarView (Expose)
- (NSRect)tabRectFromIndex:(NSUInteger)index{
    CGFloat x = kWidthOfTabList + (index * kMaxTabCellWidth);
    CGFloat y = 0;
    CGFloat width = kMaxTabCellWidth;
    CGFloat height = kTabCellHeight;
    
    NSRect rect = NSMakeRect(x, y, width, height);
    return rect;
}

// Rect for left most tab list control
- (NSRect)rectForTabListControl{
    NSRect rect = NSMakeRect(0, 0, kWidthOfTabList, kHeightOfTabList);
    rect = CGRectInset(rect, 6, 10);
    return rect;
}

- (BOOL)isBlankAreaOfTabBarViewInPoint:(NSPoint)p{
    // Check tab list control
    NSRect rect = [self rectForTabListControl];
    if (NSPointInRect(p, rect)) {
        return NO;
    }
    
    // Check all tabs path
    NSUInteger index = 0;
    for (index = 0; index < [tabs count]; ++index){
        ENTabCell *tab = [tabs objectAtIndex:index];
        NSBezierPath *path = [tab path];
        if ([path containsPoint:p]) {
            return NO;
        }
    }
    
    // Else return YES
    return YES;
}

+ (NSMenu *)defaultMenu {
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    [theMenu insertItemWithTitle:@"Beep" action:@selector(popupMenuDidChoosed) keyEquivalent:@"" atIndex:0];
    [theMenu insertItemWithTitle:@"Honk" action:@selector(popupMenuDidChoosed) keyEquivalent:@"" atIndex:1];
    return theMenu;
}
@end

@implementation ENTabBarView

@synthesize tabs;
@synthesize bgColor;
@synthesize tabBGColor;
@synthesize tabActivedBGColor;
@synthesize tabBorderColor;
@synthesize tabTitleColor;
@synthesize tabActivedTitleColor;
@synthesize smallControlColor;
@synthesize tabFont;

#pragma mark - - - - - - - - -
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        tabs = [NSMutableArray array];
        
        // Give all colors a default value if none given
        bgColor = [NSColor colorWithCalibratedRed: 0.6 green:0.6 blue:0.6 alpha:1.0];
        tabBGColor = [NSColor colorWithCalibratedRed: 0.68 green: 0.68 blue: 0.68 alpha:1.0];
        tabActivedBGColor = [NSColor whiteColor];
        tabBorderColor = [NSColor colorWithCalibratedRed: 0.53 green:0.53 blue:0.53 alpha:1.0];
        tabTitleColor = [NSColor blackColor];
        tabActivedTitleColor = [NSColor blackColor];
        smallControlColor = [NSColor colorWithCalibratedRed:0.53 green:0.53 blue:0.53 alpha:1.0];
        oldSmallControlColor = smallControlColor;
        
        // Font
        tabFont = [NSFont fontWithName:@"Lucida Grande" size:11];
    }
    return self;
}


-(void)awakeFromNib{
    tabs = [NSMutableArray array];
}

/* Overriding this method fix the setFrame issue as well */
/*- (void)resizeSubviewsWithOldSize:(NSSize)oldSize{
    NSRect rect = [[self superview] bounds];
    rect.origin = NSMakePoint(0, rect.size.height - kTabBarViewHeight);
    rect.size.height = kTabBarViewHeight;
    [self setFrame:rect];
    [self setNeedsDisplay:YES];
    NSLog(@"[*]%@", NSStringFromRect(rect));
    [self setNeedsLayout:YES];
}*/

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize{
    NSRect rect = [[self superview] bounds];
    rect.origin = NSMakePoint(0, rect.size.height - kTabBarViewHeight);
    rect.size.height = kTabBarViewHeight;
    [self setFrame:rect];
    [self setNeedsDisplay:YES];
    [self setNeedsLayout:YES];
}

- (void)redraw{
    [self setNeedsDisplay:YES];
    
    /* Call this method here, and we don't need to setup layout in Interface Builder
     * And we need to call [tabBarView redraw] after launch to keep layout, so that this method 
     * would be called here.
     */
    [self resizeWithOldSuperviewSize:NSZeroSize];
}

- (void)mouseUp:(NSEvent*)event {
    if (event.clickCount == 2) { // We capture user double click on tabbar view
        NSPoint p =[event locationInWindow];
        p = [self convertPoint:p fromView:[[self window] contentView]];
        if ([self isBlankAreaOfTabBarViewInPoint:p]) {
            ENTabCell *tab = [self addTabViewWithTitle:@"Untitled"];
            [tab setAsActiveTab];
            [self redraw];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    // Drawing background color of Tab bar view.
    [bgColor set];
    NSRect rect = [self frame];
    rect.origin = NSZeroPoint;
    NSRectFill(rect);

    
    // Draw tab list control
    tabListControlPath = [NSBezierPath bezierPath];
    NSRect tabListRect = [self rectForTabListControl];
    tabListRect = NSIntegralRect(tabListRect);
    int maxY = NSMaxY(tabListRect);
    int minY = NSMinY(tabListRect);
    int minX = NSMinX(tabListRect);
    int maxX = NSMaxX(tabListRect);
    int midX = NSMidX(tabListRect);
    
    NSPoint p1 = NSMakePoint(midX, minY);
    NSPoint p2 = NSMakePoint(minX, maxY);
    NSPoint p3 = NSMakePoint(maxX, maxY);
    
    [tabListControlPath moveToPoint:p1];
    [tabListControlPath lineToPoint:p2];
    [tabListControlPath lineToPoint:p3];
    [tabListControlPath lineToPoint:p1];
    //[[self smallControlColor] set];
    // Use tab active back ground color to set tab list triangle
    [[self tabActivedBGColor] set];
    [tabListControlPath fill];
    
    // Drawing bottom border line
    NSPoint start = NSMakePoint(0, 1);
    NSPoint end = NSMakePoint(NSMaxX(rect), 1);
    [NSBezierPath setDefaultLineWidth:2.0];
    [tabBorderColor set];
    [NSBezierPath strokeLineFromPoint:start toPoint:end];
    
    /*
     * Draw all tab cells
     * (*) All are not subclass of NSView, but NSObject
     */
    // Reset all tool tips
    [self removeAllToolTips];
    NSUInteger index = 0;
    for(index = 0; index < [tabs count]; ++ index){
        NSRect rect = [self tabRectFromIndex:index];
        ENTabCell *tab = [tabs objectAtIndex:index];
        [tab setFrame:rect];
        [self setToolTip:[tab title]];
        [self addToolTipRect:[tab frame] owner:[tab title] userData:nil];
        [tab draw];
    }
}

- (id)addTabViewWithTitle:(NSString *)title;{
    ENTabCell *tab = [ENTabCell tabCellWithTabBarView:self title:title];
    [tabs addObject:tab];
    return tab;
}

- (void)mouseDown:(NSEvent *)theEvent{
    NSPoint p = [theEvent locationInWindow];
    p = [self convertPoint:p fromView:[[self window] contentView]];
    
    /* Check if tabs list control clicked */
    if (NSPointInRect(p, [self rectForTabListControl])) {
        NSLog(@"Tab listing...");
        // 3. Pop up menu
        [NSMenu popUpContextMenu:[[self class] defaultMenu] withEvent:theEvent forView:[self.window contentView]];
    }
    
    
    /* Switch active tab */
    NSUInteger index = 0;
    for(index = 0; index < [tabs count]; ++ index){
        ENTabCell *tab = [tabs objectAtIndex:index];
        if([[tab path] containsPoint:p]){
            [tab setAsActiveTab];
        }
    };
    
    [[self selectedTab] setAsActiveTab];
    [self redraw];
}

- (void)mouseMoved:(NSEvent *)theEvent{
    NSPoint p = [theEvent locationInWindow];
    p = [self convertPoint:p fromView:[[self window] contentView]];

    /* Check if tabs list control clicked */
    if (NSPointInRect(p, [self rectForTabListControl])) {
        //self.smallControlColor = [self tabActivedBGColor];
    }else{
        //self.smallControlColor = [self tabActivedBGColor]; //oldSmallControlColor;
    }
    [self redraw];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self removeTrackingArea:trackingArea];
    
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved); trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame] options:options owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)setBounds:(NSRect)bounds {
    [super setBounds:bounds];
    [self removeTrackingArea:trackingArea];
    
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved); trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
}

#pragma mark - Call back seletor -
- (void)popupMenuDidChoosed{
    NSLog(@"Call back from Menu");
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    return YES;
}
@end
