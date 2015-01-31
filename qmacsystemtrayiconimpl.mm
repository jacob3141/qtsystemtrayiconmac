////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// This file is part of QMacSystemTrayIconImpl.                               //
// Copyright (c) 2014 Jacob Dawid <jacob@omg-it.works>                        //
//                                                                            //
// QMacSystemTrayIconImpl is free software: you can redistribute it and/or    //
// modify it under the terms of the GNU Affero General Public License as      //
// published by the Free Software Foundation, either version 3 of the         //
// License, or (at your option) any later version.                            //
//                                                                            //
// QMacSystemTrayIconImpl is distributed in the hope that it will be useful,  //
// but WITHOUT ANY WARRANTY; without even the implied warranty of             //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              //
// GNU Affero General Public License for more details.                        //
//                                                                            //
// You should have received a copy of the GNU Affero General Public           //
// License along with QMacSystemTrayIconImpl.                                 //
// If not, see <http://www.gnu.org/licenses/>.                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

#import "qmacsystemtrayiconimpl.h"
#import "cocoaimagehelper.h"

#include <QWidget>

// Objective C

// Interface declaration
#import <AppKit/AppKit.h>

@interface QMacSystemTrayIconObjc : NSView {
  @private
    NSImage *               _lightThemeImage;
    NSImage *               _darkThemeImage;
    NSStatusItem *          _statusItem;
    BOOL                    _isHighlighted;
    SEL                     _action;
    __unsafe_unretained id  _target;

    QMacSystemTrayIconImpl * _impl;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property(nonatomic, strong, readonly) NSStatusItem *   statusItem;
@property(nonatomic, strong) NSImage *                  lightThemeImage;
@property(nonatomic, strong) NSImage *                  darkThemeImage;
@property(nonatomic, copy) NSString *                   title;
@property(nonatomic, setter=setHighlighted :) BOOL      isHighlighted;
@property(nonatomic, readonly) NSRect                   globalRect;
@property(nonatomic) SEL                                action;
@property(nonatomic, unsafe_unretained) id              target;

@property QMacSystemTrayIconImpl *                      impl;

@end

// Objective-C implementation
@implementation QMacSystemTrayIconObjc

@synthesize statusItem      = _statusItem;
@synthesize lightThemeImage = _lightThemeImage;
@synthesize darkThemeImage  = _darkThemeImage;
@synthesize isHighlighted   = _isHighlighted;
@synthesize action          = _action;
@synthesize target          = _target;
@synthesize impl            = _impl;

- (id)initWithStatusItem:(NSStatusItem *)statusItem width:(CGFloat)width {
    NSRect itemRect = NSMakeRect(0.0, 0.0, width, [[NSStatusBar systemStatusBar] thickness]);
    self = [super initWithFrame:itemRect];

    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
        self.target = self;
        self.action = @selector(togglePanel:);
    }
    return self;
}

- (NSRect)geometry {
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;

    QMacSystemTrayIconObjc *statusItemView = self;
    if (statusItemView) {
        statusRect = statusItemView.globalRect;
        // the next line converts apple's crazy coordinate system to Qt's
        statusRect.origin.y = screenRect.size.height - statusRect.origin.y;
    }
    return statusRect;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];

    NSImage *icon = self.isHighlighted ? self.darkThemeImage : self.lightThemeImage;
    icon = [self isDarkMode] ? self.darkThemeImage : icon;

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
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    _impl->triggerLeftMouseDown();
}

- (void)rightMouseDown:(NSEvent *)event {
    _impl->triggerRightMouseDown();
}

- (void)setHighlighted:(BOOL)newFlag {
    if (_isHighlighted == newFlag)
        return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

- (void)setDarkThemeImage:(NSImage *)image {
    if (_darkThemeImage != image) {
        _darkThemeImage = image;
        [self setNeedsDisplay:YES];
    }
}

- (void)setLightThemeImage:(NSImage *)image {
    if (_lightThemeImage != image) {
        _lightThemeImage = image;
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

// C++
QMacSystemTrayIconImpl::QMacSystemTrayIconImpl(QObject *parent, float width)
    : QObject(parent) {
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _macSystemTrayIconObjc = [[QMacSystemTrayIconObjc alloc] initWithStatusItem:statusItem width:width];
    [_macSystemTrayIconObjc setImpl:this];
}

void QMacSystemTrayIconImpl::setLightThemePixmap(QPixmap pixmap) {
    static_cast<QMacSystemTrayIconObjc*>(_macSystemTrayIconObjc).lightThemeImage = pixmapToNSImage(pixmap);
}

void QMacSystemTrayIconImpl::setDarkThemePixmap(QPixmap pixmap) {
    static_cast<QMacSystemTrayIconObjc*>(_macSystemTrayIconObjc).darkThemeImage = pixmapToNSImage(pixmap);
}

void QMacSystemTrayIconImpl::setText(QString text) {
    [_macSystemTrayIconObjc setTitle:text.toNSString()];
}

QMacSystemTrayIconImpl::MacOSXTheme QMacSystemTrayIconImpl::macOSXTheme() {
    if([_macSystemTrayIconObjc isDarkMode]) {
        return QMacSystemTrayIconImpl::MacOSXThemeDark;
    } else {
        return QMacSystemTrayIconImpl::MacOSXThemeLight;
    }
}

void QMacSystemTrayIconImpl::triggerLeftMouseDown() {
    emit geometryChanged(geometry());
    emit activated(QSystemTrayIcon::Trigger);
}

void QMacSystemTrayIconImpl::triggerRightMouseDown() {
    emit geometryChanged(geometry());
    emit activated(QSystemTrayIcon::Context);
}

QRect QMacSystemTrayIconImpl::geometry() const {
    NSRect rect = [_macSystemTrayIconObjc geometry];
    return QRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}



