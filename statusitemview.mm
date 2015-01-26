#import "StatusItemView.h"
#include <QMacNativeWidget>
#include <QHBoxLayout>
#include <QPushButton>
#include <QLineEdit>

#define STATUS_ITEM_VIEW_WIDTH_WITH_TIME 60.0

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

- (id)initWithStatusItem:(NSStatusItem *)statusItem {
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];

    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
        self.target = self;
        self.action = @selector(togglePanel:);
    }
    return self;
}

- (IBAction)togglePanel:(id)sender {
    NSRect rect = [self statusRect];
    QWidget *widget = new QWidget();
    widget->setFixedSize(QSize(100, 100));

    widget->move(rect.origin.x, rect.origin.y);
    widget->show();
}

- (NSRect)statusRect {
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;

    StatusItemView *statusItemView = self;

    if (statusItemView) {
        statusRect = statusItemView.globalRect;
        // the next line converts apple's crazy coordinate system to Qt's
        statusRect.origin.y = screenRect.size.height - statusRect.origin.y;
    }
    return statusRect;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];

    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    icon = [self isDarkMode] ? self.alternateImage : icon;

    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = 5;
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);

    [icon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

    NSColor *textColor = self.isHighlighted ? [NSColor whiteColor] : [NSColor blackColor];
    textColor = [self isDarkMode] ? [NSColor whiteColor] : textColor,

    [self.title
            drawInRect:NSRectFromCGRect(CGRectMake(iconX + iconSize.width + 5, -1,
                                                   bounds.size.width - iconX - iconSize.width - 2, bounds.size.height))
        withAttributes:@{
                          NSFontAttributeName : [NSFont systemFontOfSize:14],
                          NSForegroundColorAttributeName : textColor
                       }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.statusItem.length = STATUS_ITEM_VIEW_WIDTH_WITH_TIME;

    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [NSApp sendAction:self.action to:self.target from:self];
}


- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag)
        return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}


- (void)setImage:(NSImage *)newImage {
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage {
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

- (NSRect)globalRect {
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

- (BOOL)isDarkMode {
    return [[[NSAppearance currentAppearance] name] hasPrefix:@"NSAppearanceNameVibrantDark"];
}

@end

