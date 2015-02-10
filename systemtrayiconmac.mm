////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// This file is part of QtSystemTrayIconMac.                                  //
// Copyright (c) 2014 Jacob Dawid <jacob@omg-it.works>                        //
//                                                                            //
// QtSystemTrayIconMac is free software: you can redistribute it and/or       //
// modify it under the terms of the GNU Affero General Public License as      //
// published by the Free Software Foundation, either version 3 of the         //
// License, or (at your option) any later version.                            //
//                                                                            //
// QtSystemTrayIconMac is distributed in the hope that it will be useful,     //
// but WITHOUT ANY WARRANTY; without even the implied warranty of             //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              //
// GNU Affero General Public License for more details.                        //
//                                                                            //
// You should have received a copy of the GNU Affero General Public           //
// License along with QtSystemTrayIconMac.                                    //
// If not, see <http://www.gnu.org/licenses/>.                                //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

// Own includes
#import "systemtrayiconmac.h"

// Qt includes
#include <QWidget>
#include <qmacfunctions.h>

#import <AppKit/AppKit.h>

@interface StatusItemListener : NSObject
@property SystemTrayIconMac* trayIcon;
@end

@implementation StatusItemListener

- (void)configureForTrayIcon:(SystemTrayIconMac*)trayIcon {
    self.trayIcon = trayIcon;
}

- (void)triggered:(NSObject *)sender {
    self.trayIcon->trigger();
}

@end

SystemTrayIconMac::SystemTrayIconMac(QObject *parent)
    : QObject(parent) {
    initialize();
}

SystemTrayIconMac::SystemTrayIconMac(const QIcon &icon, QObject *parent)
    : QObject(parent) {
    initialize();
    setIcon(icon);
}

void SystemTrayIconMac::initialize() {
    _statusItem = (void*)[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem retain];

    _statusItemListener = (void*)[[StatusItemListener alloc] init];
    [_statusItemListener retain];

    [[(NSStatusItem*)_statusItem button] setTarget:(StatusItemListener*)_statusItemListener];
    [[(NSStatusItem*)_statusItem button] setAction:@selector(triggered:)];

    [(StatusItemListener*)_statusItemListener configureForTrayIcon:this];
}

void SystemTrayIconMac::show() {
}

QIcon SystemTrayIconMac::icon() const {
    return _icon;
}

void SystemTrayIconMac::setIcon(QIcon icon, unsigned int margin) {
    _icon = icon;

    // Retrieve the thickness of the system status bar in logical pixels.
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];

    // Calculate a view size (in logical pixels). MacOSX will center it
    // automatically, so we need to provide a margin if our icon is smaller
    // than the system status bar.
    NSSize s;
    s.width = s.height = thickness - margin;

    // In order to display retina graphics correctly we stretch the texture,
    // but create an NSImage with smaller size. QtMac::toNSImage does not work,
    // because it implicitly assumes that the size in pixels is equal to the
    // logical pixels. On "2x retina screens" the physical pixels are twice the
    // width and height of a physical pixel. This is confusing, because in order
    // to get a sharply rendered icon, we need to provide a 44x44 pixel image
    // (physical pixels) for a 22x22 icon (logical pixels).
    [(NSStatusItem *)_statusItem setImage: [[NSImage alloc]initWithCGImage: QtMac::toCGImageRef(icon.pixmap(QSize(s.width*4, s.width*4))) size: s]];
}

void SystemTrayIconMac::setText(QString text) {
    [(NSStatusItem *)_statusItem setTitle:text.toNSString()];
}

SystemTrayIconMac::MacOSXTheme SystemTrayIconMac::macOSXTheme() {
    if([[[NSAppearance currentAppearance] name] hasPrefix:@"NSAppearanceNameVibrantDark"]) {
        return SystemTrayIconMac::MacOSXThemeDark;
    } else {
        return SystemTrayIconMac::MacOSXThemeLight;
    }
}

void SystemTrayIconMac::trigger() {
    emit geometryChanged(geometry());
    emit activated(QSystemTrayIcon::Trigger);
}

QString SystemTrayIconMac::toolTip() const {
    return _toolTip;
}

void SystemTrayIconMac::setToolTip(const QString &tip) {
    _toolTip = tip;
}

QRect SystemTrayIconMac::geometry() const {
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSButton *trayIconButton = [(NSStatusItem*)_statusItem button];

    NSRect frame = [trayIconButton frame];
    frame.origin = [trayIconButton.window convertBaseToScreen:frame.origin];

    // the next line converts apple's crazy coordinate system to Qt's
    frame.origin.y = screenRect.size.height - frame.origin.y;

    return QRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

bool SystemTrayIconMac::isVisible() const {
    // Always visible
    return true;
}



