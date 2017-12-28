#import "DeviceInfo.h"

@implementation DeviceInfo

@synthesize myPeripheral;
@synthesize mainViewController;
@synthesize userInfo;

- (id)init
{
    self = [super init];
    if (self)
    {
        mainViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        mainViewController.userInfo=self.userInfo;
    }
    return self;
}

- (void)dealloc
{
    [mainViewController release];
    [myPeripheral release];
    [super dealloc];
}

@end
