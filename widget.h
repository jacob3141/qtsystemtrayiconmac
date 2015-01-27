#ifndef WIDGET_H
#define WIDGET_H

#include <QWidget>

class Widget : public QWidget {
    Q_OBJECT
public:
    Widget(QWidget *parent = 0)
        : QWidget(parent) {
        setFixedSize(300, 300);
    }

public slots:
    void toggeld(QRect rect) {
        move(rect.x() - width() / 2, rect.y());
    }
};

#endif // WIDGET_H
