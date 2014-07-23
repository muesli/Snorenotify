#include "osxnotificationcenter.h"
#include "core/plugins/snorebackend.h"

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import <QThread.h>
#import <QApplication.h>

Q_EXPORT_PLUGIN2(libsnore_backend_osxnotificationcenter, OSXNotificationCenter)

using namespace Snore;

// store some variables that are needed (since obj-c++ does not allow having obj-c classes as c++ members)
namespace {
    NSUserNotificationCenter *notification_center;

    NSString *NSStringFromQString(QString qstr) {
        return [NSString stringWithUTF8String: qstr.toUtf8().data()];
    }
}

// this category adds the __bundleIdentifier method to every NSBundle object
// see http://stackoverflow.com/a/14698543
@implementation NSBundle(snore)
- (NSString *)__bundleIdentifier {
    return appID;
}
@end


OSXNotificationCenter::OSXNotificationCenter() : SnoreBackend("OSX Notification Center", false, false, false)
{
}

OSXNotificationCenter::~OSXNotificationCenter()
{
}

bool OSXNotificationCenter::initialize(SnoreCore *snore)
{
    notification_center = [NSUserNotificationCenter defaultUserNotificationCenter];

    return SnoreBackend::initialize(snore);
}

void OSXNotificationCenter::slotNotify(Snore::Notification notification)
{
    NSUserNotification *osx_notification = [[NSUserNotification alloc] init];
    osx_notification.title = NSStringFromQString(Snore::toPlainText(notification.title()));
    osx_notification.informativeText = NSStringFromQString(Snore::toPlainText(notification.text()));

    [notification_center deliverNotification: osx_notification];

    [osx_notification release];
}

