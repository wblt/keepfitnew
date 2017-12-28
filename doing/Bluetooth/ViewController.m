#import "AppDelegate.h"
#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize connectedPeripheral;
@synthesize transparentPage;
@synthesize userInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (transparentPage == nil)
        {
            transparentPage = [[DataTransparentViewController alloc] init];
        }
        
        transparentPage.connectedPeripheral = connectedPeripheral;
        transparentPage.connectedPeripheral.transDataDelegate = transparentPage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.title = @"Back";
    self.navigationItem.backBarButtonItem = backButton;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 28, 57, 57)];
    [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Icon_old"]]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];//aaa
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    self.navigationItem.leftBarButtonItem = disconnectButton;
    transparentPage = nil;
    
    //2013-10-24
    [self enterTransparentPage:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"[viewController] viewDidAppear");
    [[self navigationController] setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
 //   NSLog(@"ViewController viewDidUnLoad");
}

- (void) dealloc
{
    //NSLog(@"[viewController] dealloc");
    if (transparentPage)
    {
        [transparentPage release];
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    //NSLog(@"[viewContrller] didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}


- (IBAction)enterTransparentPage:(id)sender
{
    //NSLog(@"[viewContrller] enterTransparentPage");
    if (transparentPage == nil)
    {
        transparentPage = [[DataTransparentViewController alloc] init];
    }
    transparentPage.connectedPeripheral = connectedPeripheral;
    transparentPage.connectedPeripheral.transDataDelegate = transparentPage;
    transparentPage.userInfo=self.userInfo;
    [[self navigationController] pushViewController:transparentPage animated:YES];
}

@end
