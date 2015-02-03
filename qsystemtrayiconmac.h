// Qt includes
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
