
#include <QApplication>
#include <Cocoa/Cocoa.h>

#include "qmacsystemtrayiconimpl.h"
#include "cocoaimagehelper.h"


int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QPixmap pixmap(":/images/menubar.png");
    NSImage *image = pixmapToNSImage(pixmap);
    QPixmap alternatePixmap(":/images/menubar_active.png");
    NSImage *alternateImage = pixmapToNSImage(alternatePixmap);

    QMacSystemTrayIconImpl *statusItemView;
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:25];
    statusItemView = [[QMacSystemTrayIconImpl alloc] initWithStatusItem:statusItem];
    statusItemView.image = image;
    statusItemView.alternateImage = alternateImage;

    return app.exec();
}



