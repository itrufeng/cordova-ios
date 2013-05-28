//
//  ApplicationInfo.m
//  ApplicationInfo
//
//  Created by jing zhao on 5/27/13.
//  Copyright (c) 2013 youdao. All rights reserved.
//

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

@property (unsafe_unretained, nonatomic)ApplicationInfoBlock m_block;

@end

@implementation ApplicationInfo 

- (id)init
{
    self =[super init];
    
    if (self){}
    
    return self;
}

-(void)setBlock:(ApplicationInfoBlock)block
{
    self.m_block = block;
    
    [self getProvider];
    [self getVersion];
    
    [self getLocation];
    
}

/**************************************************************************************/

#pragma mark -
#pragma mark 私有 版本信息
#pragma mark -

/**************************************************************************************/

-(void)getVersion
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *nowcurrentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    
    currentVersion = nowcurrentVersion;
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

-(void)getProvider
{
    CTTelephonyNetworkInfo * netInfo = [[ CTTelephonyNetworkInfo alloc]init];
    
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    
    NSString *nowProviderName = [carrier carrierName];
    
    providerName = nowProviderName;
}

/**************************************************************************************/

#pragma mark -
#pragma mark CLLocationManagerDelegate
#pragma mark -

/**************************************************************************************/

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    
    longtitude = [NSString stringWithFormat:@"%+1.2f",location.coordinate.longitude];
    
    latitude  = [NSString stringWithFormat:@"%+1.2f",location.coordinate.latitude];
    
    //    NSDate* eventDate = location.timestamp;
    //    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //    if (abs(howRecent) < 15.0)
    //    {
    //       NSLog(@"latitude %+.6f, longitude %+.6f\n",
    //          location.coordinate.latitude,
    //          location.coordinate.longitude);
    //    }
    
    NSArray *array = [NSArray arrayWithObjects:currentVersion,providerName,longtitude,latitude,nil];
    
    self.m_block(array);
    
    [locationManager stopUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
    NSArray *array = [NSArray arrayWithObjects:currentVersion,providerName,nil];
    
    self.m_block(array);
}


@end
