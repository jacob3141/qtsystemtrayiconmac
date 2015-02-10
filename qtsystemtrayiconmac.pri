INCLUDEPATH += \
    $$PWD

LIBS += \
    -L../qtsystemtrayiconmac -lqtsystemtrayiconmac

mac {
    LIBS += -framework Cocoa
}
