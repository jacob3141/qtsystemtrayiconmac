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

// Own includes
#import "qsystemtrayiconmac.h"

// Qt includes
#include <QWidget>
#include <qmacfunctions.h>

#import <AppKit/AppKit.h>

@interface StatusItemListener : NSObject
@property QSystemTrayIconMac* trayIcon;
@end

@implementation StatusItemListener

- (void)configureForTrayIcon:(QSystemTrayIconMac*)trayIcon {
    self.trayIcon = trayIcon;
}

- (void)triggered:(NSObject *)sender {
    self.trayIcon->trigger();
}

@end

QSystemTrayIconMac::QSystemTrayIconMac(QObject *parent)
    : QObject(parent) {
    initialize();
}

QSystemTrayIconMac::QSystemTrayIconMac(const QIcon &icon, QObject *parent)
    : QObject(parent) {
    initialize();
    setIcon(icon);
}

void QSystemTrayIconMac::initialize() {
    _statusItem = (void*)[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem retain];

    _statusItemListener = (void*)[[StatusItemListener alloc] init];
    [_statusItemListener retain];

    [[(NSStatusItem*)_statusItem button] setTarget:(StatusItemListener*)_statusItemListener];
    [[(NSStatusItem*)_statusItem button] setAction:@selector(triggered:)];

    [(StatusItemListener*)_statusItemListener configureForTrayIcon:this];
}

void QSystemTrayIconMac::setIcon(QIcon icon) {
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    [(NSStatusItem *)_statusItem setImage:QtMac::toNSImage(icon.pixmap(QSize(thickness, thickness)))];
}

void QSystemTrayIconMac::setText(QString text) {
    [(NSStatusItem *)_statusItem setTitle:text.toNSString()];
}

QSystemTrayIconMac::MacOSXTheme QSystemTrayIconMac::macOSXTheme() {
    if([[[NSAppearance currentAppearance] name] hasPrefix:@"NSAppearanceNameVibrantDark"]) {
        return QSystemTrayIconMac::MacOSXThemeDark;
    } else {
        return QSystemTrayIconMac::MacOSXThemeLight;
    }
}

void QSystemTrayIconMac::trigger() {
    emit geometryChanged(geometry());
    emit activated(QSystemTrayIcon::Trigger);
}

QRect QSystemTrayIconMac::geometry() const {
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSButton *trayIconButton = [(NSStatusItem*)_statusItem button];

    NSRect frame = [trayIconButton frame];
    frame.origin = [trayIconButton.window convertBaseToScreen:frame.origin];

    // the next line converts apple's crazy coordinate system to Qt's
    frame.origin.y = screenRect.size.height - frame.origin.y;

    return QRect(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}



