
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
