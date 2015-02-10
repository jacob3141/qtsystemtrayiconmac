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

#include <QPixmap>
#include <QRect>
#include <QSystemTrayIcon>

class SystemTrayIconMac : public QObject {
    Q_OBJECT
public:
    // MacOSX specific.
    // Please keep in mind to ifdef these in your code when not on MacOSX.
    enum MacOSXTheme {
        MacOSXThemeDark,
        MacOSXThemeLight
    };

    void setText(QString text);

    MacOSXTheme macOSXTheme();

    // QSystemTrayIcon compatible.
    SystemTrayIconMac(QObject *parent = 0);
    SystemTrayIconMac(const QIcon &icon, QObject *parent = 0);

    /**
     * Doesn't do anything, just for compatibiliy with QSystemTrayIcon.
     */
    void show();

    QIcon icon() const;
    void setIcon(QIcon icon, unsigned int margin = 0);

    QString toolTip() const;
    void setToolTip(const QString &tip);

    QRect geometry() const;
    bool isVisible() const;

    // Do not use this. This is called internal to trigger a click.
    void trigger();

signals:
    void geometryChanged(QRect geometry);
    void activated(QSystemTrayIcon::ActivationReason);

private:
    void initialize();

    QIcon _icon;
    QString _toolTip;

    void *_statusItem;
    void *_statusItemListener;
};
