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

#include <QPixmap>
#include <QRect>
#include <QSystemTrayIcon>

class QSystemTrayIconMac : public QObject {
    Q_OBJECT
public:
    enum MacOSXTheme {
        MacOSXThemeDark,
        MacOSXThemeLight
    };

    QSystemTrayIconMac(QObject *parent = 0);
    QSystemTrayIconMac(const QIcon &icon, QObject *parent = 0);

    void setIcon(QIcon icon);

    void setText(QString text);

    MacOSXTheme macOSXTheme();

    QRect geometry() const;


    void trigger();

signals:
    void geometryChanged(QRect geometry);
    void activated(QSystemTrayIcon::ActivationReason);

private:
    void initialize();

    void *_statusItem;
    void *_statusItemListener;
};
