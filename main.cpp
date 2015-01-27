#include <QApplication>

#include "qmacsystemtrayiconimpl.h"
#include "widget.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    Widget *w = new Widget();
    w->show();

    QMacSystemTrayIconImpl systemTrayIcon;
    systemTrayIcon.setLightThemePixmap(QPixmap(":/images/menubar.png"));
    systemTrayIcon.setDarkThemePixmap(QPixmap(":/images/menubar_active.png"));

    QObject::connect(&systemTrayIcon, SIGNAL(trayIconToggled(QRect)), w, SLOT(toggeld(QRect)));

    return app.exec();
}



