TEMPLATE = app

OBJECTIVE_SOURCES += main.mm \
    statusitemview.mm \
    cocoaimagehelper.mm
LIBS += -framework Cocoa

QT += gui widgets macextras
QT += widgets-private gui-private core-private

HEADERS += \
    statusitemview.h \
    cocoaimagehelper.h

SOURCES +=

RESOURCES += \
    resources.qrc
