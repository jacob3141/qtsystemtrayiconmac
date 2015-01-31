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

class QMacSystemTrayIconImpl : public QObject {
    Q_OBJECT
public:
    enum MacOSXTheme {
        MacOSXThemeDark,
        MacOSXThemeLight
    };

    QMacSystemTrayIconImpl(QObject *parent = 0, float width = 80.0);

    void setLightThemePixmap(QPixmap pixmap);
    void setDarkThemePixmap(QPixmap pixmap);
    void setText(QString text);
    MacOSXTheme macOSXTheme();

    QRect geometry() const;

    void triggerLeftMouseDown();
    void triggerRightMouseDown();

signals:
    void geometryChanged(QRect geometry);
    void activated(QSystemTrayIcon::ActivationReason);

private:

    void *_macSystemTrayIconObjc;
    QRect _geometry;
};
