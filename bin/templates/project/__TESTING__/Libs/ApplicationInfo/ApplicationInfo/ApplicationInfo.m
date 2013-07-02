#import "ApplicationInfo.h"

#import <CoreLocation/CoreLocation.h>

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


@interface  ApplicationInfo ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    NSString          *currentVersion;
    NSString          *providerName;
    NSString          *longtitude;
    NSString          *latitude;
}

//@property (strong, nonatomic)ApplicationInfoBlock m_block;
@property (unsafe_unretained,nonatomic)id<DelegateApplicationInfo>   delegateAppInfo;

@end

@implementation ApplicationInfo

- (id)init
{
    self =[super init];
    
    if (self){
        getLocationNums = 0;
    }
    
    return self;
}


-(void)setDelegate:(id<DelegateApplicationInfo>)delegate
{
    _delegateAppInfo = delegate;
    
    currentVersion = [self getVersion];
    
    providerName = [self getProvider];
    
    [self getLocation];
}



/**************************************************************************************/

#pragma mark -
#pragma mark 私有 版本信息
#pragma mark -

/**************************************************************************************/

-(NSString *)getVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *nowcurrentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    return nowcurrentVersion;
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark 私有 经纬度
#pragma mark -

/**************************************************************************************/

-(void)getLocation
{
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    [locationManager startUpdatingLocation];
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark 获取运营商信息
#pragma mark -

/**************************************************************************************/

-(NSString *)getProvider
{
    CTTelephonyNetworkInfo * netInfo = [[ CTTelephonyNetworkInfo alloc]init];
    
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    NSString *nowProviderName = [carrier carrierName];
    
    return nowProviderName;
}

/**************************************************************************************/

#pragma mark -
#pragma mark CLLocationManagerDelegate
#pragma mark -

/**************************************************************************************/

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];

    CLLocation* location = [locations lastObject];
    
    longtitude = [NSString stringWithFormat:@"%+1.6f",location.coordinate.longitude];
    
    latitude  = [NSString stringWithFormat:@"%+1.6f",location.coordinate.latitude];
    
    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:currentVersion,KVersions,
                             providerName,KOperator,
                             longtitude,KLongitude,
                             latitude,KLatitude,nil];
    
    [_delegateAppInfo delegateOnApplicationInfo:dicInfo];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:currentVersion,KVersions,
                             providerName,KOperator,nil];
    
    [_delegateAppInfo delegateOnApplicationInfo:dicInfo];
    //    self.m_block(dicInfo);
}


@end
