
#include "cocoaimagehelper.h"
#include <QtCore>
#include <QtGui>


#ifndef QT_NO_WIDGETS
#include <QtWidgets/QWidget>
#endif

static CGColorSpaceRef m_genericColorSpace = 0;
static QHash<CGDirectDisplayID, CGColorSpaceRef> m_displayColorSpaceHash;
static bool m_postRoutineRegistered = false;

/*
    Helper class that automates refernce counting for CFtypes.
    After constructing the QCFType object, it can be copied like a
    value-based type.

    Note that you must own the object you are wrapping.
    This is typically the case if you get the object from a Core
    Foundation function with the word "Create" or "Copy" in it. If
    you got the object from a "Get" function, either retain it or use
    constructFromGet(). One exception to this rule is the
    HIThemeGet*Shape functions, which in reality are "Copy" functions.
*/
template <typename T>
class Q_CORE_EXPORT QCFType
{
public:
    inline QCFType(const T &t = 0) : type(t) {}
    inline QCFType(const QCFType &helper) : type(helper.type) { if (type) CFRetain(type); }
    inline ~QCFType() { if (type) CFRelease(type); }
    inline operator T() { return type; }
    inline QCFType operator =(const QCFType &helper)
    {
        if (helper.type)
            CFRetain(helper.type);
        CFTypeRef type2 = type;
        type = helper.type;
        if (type2)
            CFRelease(type2);
        return *this;
    }
    inline T *operator&() { return &type; }
    template <typename X> X as() const { return reinterpret_cast<X>(type); }
    static QCFType constructFromGet(const T &t)
    {
        CFRetain(t);
        return QCFType<T>(t);
    }
protected:
    T type;
};

static void drawImageReleaseData (void *info, const void *, size_t)
{
    delete static_cast<QImage *>(info);
}

void qt_mac_cleanUpMacColorSpaces()
{
    if (m_genericColorSpace) {
        CFRelease(m_genericColorSpace);
        m_genericColorSpace = 0;
    }
    QHash<CGDirectDisplayID, CGColorSpaceRef>::const_iterator it = m_displayColorSpaceHash.constBegin();
    while (it != m_displayColorSpaceHash.constEnd()) {
        if (it.value())
            CFRelease(it.value());
        ++it;
    }
    m_displayColorSpaceHash.clear();
}

/*
    Ideally, we should pass the widget in here, and use CGGetDisplaysWithRect() etc.
    to support multiple displays correctly.
*/
CGColorSpaceRef qt_mac_displayColorSpace(const QWidget *widget)
{
    CGColorSpaceRef colorSpace;

    CGDirectDisplayID displayID;
    CMProfileRef displayProfile = 0;
    if (widget == 0) {
        displayID = CGMainDisplayID();
    } else {
        displayID = CGMainDisplayID();
        /*
        ### get correct display
        const QRect &qrect = widget->window()->geometry();
        CGRect rect = CGRectMake(qrect.x(), qrect.y(), qrect.width(), qrect.height());
        CGDisplayCount throwAway;
        CGDisplayErr dErr = CGGetDisplaysWithRect(rect, 1, &displayID, &throwAway);
        if (dErr != kCGErrorSuccess)
            return macDisplayColorSpace(0); // fall back on main display
        */
    }
    if ((colorSpace = m_displayColorSpaceHash.value(displayID)))
        return colorSpace;

    CMError err = CMGetProfileByAVID((CMDisplayIDType)displayID, &displayProfile);
    if (err == noErr) {
        colorSpace = CGColorSpaceCreateWithPlatformColorSpace(displayProfile);
    } else if (widget) {
        return qt_mac_displayColorSpace(0); // fall back on main display
    }

    if (colorSpace == 0)
        colorSpace = CGColorSpaceCreateDeviceRGB();

    m_displayColorSpaceHash.insert(displayID, colorSpace);
    CMCloseProfile(displayProfile);
    if (!m_postRoutineRegistered) {
        m_postRoutineRegistered = true;
        void qt_mac_cleanUpMacColorSpaces();
        qAddPostRoutine(qt_mac_cleanUpMacColorSpaces);
    }
    return colorSpace;
}


CGColorSpaceRef qt_mac_genericColorSpace()
{
    // Just return the main display colorspace for the moment.
    return qt_mac_displayColorSpace(0);
}

CGImageRef qt_mac_image_to_cgimage(const QImage &img)
{
    if (img.width() <= 0 || img.height() <= 0) {
        qWarning() << Q_FUNC_INFO <<
            "trying to set" << img.width() << "x" << img.height() << "size for CGImage";
        return 0;
    }

    QImage *image;
    if (img.depth() != 32)
        image = new QImage(img.convertToFormat(QImage::Format_ARGB32_Premultiplied));
    else
        image = new QImage(img);

    uint cgflags = kCGImageAlphaNone;
    switch (image->format()) {
    case QImage::Format_ARGB32_Premultiplied:
        cgflags = kCGImageAlphaPremultipliedFirst;
        break;
    case QImage::Format_ARGB32:
        cgflags = kCGImageAlphaFirst;
        break;
    case QImage::Format_RGB32:
        cgflags = kCGImageAlphaNoneSkipFirst;
    default:
        break;
    }
    cgflags |= kCGBitmapByteOrder32Host;
    QCFType<CGDataProviderRef> dataProvider = CGDataProviderCreateWithData(image,
                                                          static_cast<const QImage *>(image)->bits(),
                                                          image->byteCount(),
                                                          drawImageReleaseData);

    return CGImageCreate(image->width(), image->height(), 8, 32,
                                        image->bytesPerLine(),
                                        qt_mac_genericColorSpace(),
                                        cgflags, dataProvider, 0, false, kCGRenderingIntentDefault);

}


NSImage *qt_mac_cgimage_to_nsimage(CGImageRef image)
{
    NSImage *newImage = 0;
    NSRect imageRect = NSMakeRect(0.0, 0.0, CGImageGetWidth(image), CGImageGetHeight(image));
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    {
        CGContextRef imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    }
    [newImage unlockFocus];
    return newImage;
}

NSImage* pixmapToNSImage(const QPixmap &pm)
{
   if (pm.isNull())
        return 0;
    QImage image = pm.toImage();
    CGImageRef cgImage = qt_mac_image_to_cgimage(image);
    NSImage *nsImage = qt_mac_cgimage_to_nsimage(cgImage);
    CGImageRelease(cgImage);
    return nsImage;
}

