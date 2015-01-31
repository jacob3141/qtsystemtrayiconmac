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

#ifndef COCOAIMAGEHELPER_H
#define COCOAIMAGEHELPER_H

#include <QPixmap>

#import <Cocoa/Cocoa.h>

NSImage* pixmapToNSImage(const QPixmap &pm);

#endif // COCOAIMAGEHELPER_H
