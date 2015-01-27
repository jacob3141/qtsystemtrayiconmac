TEMPLATE = app

OBJECTIVE_SOURCES += \
    cocoaimagehelper.mm \
    qmacsystemtrayiconimpl.mm
LIBS += -framework Cocoa

QT += gui widgets macextras
QT += widgets-private gui-private core-private

HEADERS += \
    cocoaimagehelper.h \
    qmacsystemtrayiconimpl.h \
    widget.h

SOURCES += \
    main.cpp

RESOURCES += \
    resources.qrc
