TEMPLATE = app

OBJECTIVE_SOURCES += main.mm \
    cocoaimagehelper.mm \
    qmacsystemtrayiconimpl.mm
LIBS += -framework Cocoa

QT += gui widgets macextras
QT += widgets-private gui-private core-private

HEADERS += \
    cocoaimagehelper.h \
    qmacsystemtrayiconimpl.h

SOURCES +=

RESOURCES += \
    resources.qrc
