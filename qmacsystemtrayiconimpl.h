
#include <QPixmap>
#include <QRect>

class QMacSystemTrayIconImpl : public QObject {
    Q_OBJECT
public:
    enum MacOSXTheme {
        MacOSXThemeDark,
        MacOSXThemeLight
    };

    QMacSystemTrayIconImpl(QObject *parent = 0);

    void setLightThemePixmap(QPixmap pixmap);
    void setDarkThemePixmap(QPixmap pixmap);

    void setText(QString text);

    MacOSXTheme macOSXTheme();

    void trayIconToggled(int x, int y, int w, int h);

signals:
    void trayIconToggled(QRect geometry);

private:

    void *_macSystemTrayIconObjc;
};
