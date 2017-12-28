#import "ISError.h"

@implementation ISError
- (id)init
{
    self = [super init];
    if (self)
    {
        errorDescription = nil;
    }
    return self;
}

- (void) setErrorDescription:(NSString *)str
{
    errorDescription = [[NSString alloc] initWithString:str];
}

- (NSString *) localizedDescription
{
    return errorDescription;
}

@end