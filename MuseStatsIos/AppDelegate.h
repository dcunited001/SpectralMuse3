//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>
#import "Muse.h"
//#import "MuseStatsIos-Swift.h"

@protocol MuseListenerCtrlDelegate
@optional
- (void)receivedMuseData:(IXNMuseDataPacket *)packet;
- (void)receivedMuseArtifact:(IXNMuseArtifactPacket *)packet;
- (void)receivedMuseConnection:(IXNMuseConnectionPacket *)pacsket;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<IXNMuse> muse;

- (void)sayHi;
- (void)reconnectToMuse;

@end

