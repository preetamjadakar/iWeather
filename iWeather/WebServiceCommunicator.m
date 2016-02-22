//
//  WebServiceCommunicator.m
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import "WebServiceCommunicator.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@implementation WebServiceCommunicator
+ (WebServiceCommunicator *)sharedInstance
{
    // 1
    static WebServiceCommunicator *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[WebServiceCommunicator alloc] init];
    });
    return _sharedInstance;
}
-(BOOL)isNetworkConnection
{
    if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
        
        return NO;
    }else
        return YES;
}
-(void)fetchForcastForCity:(id)cityNameOrCLLocation
{
    
    NSString *apiString = nil;
    if ([cityNameOrCLLocation isKindOfClass:[NSString class]]) {
        apiString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=14&APPID=%@",cityNameOrCLLocation,API_KEY];
    }
    else if ([cityNameOrCLLocation isKindOfClass:[CLLocation class]]) {
        CLLocation *location = cityNameOrCLLocation;
        
        apiString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=14&APPID=%@",location.coordinate.latitude,location.coordinate.longitude,API_KEY];
    }
    
    
    NSURL *URL = [NSURL URLWithString:apiString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (data && !connectionError) {
            
            NSError *jsonExtractError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonExtractError];
            
            if (dataDic) {
                id responseCode = [dataDic valueForKey:@"cod"];
                if ( [responseCode intValue] == 200) {
                    City *cityObject =[City new];
                    NSMutableArray *dataArray = [NSMutableArray new];
                    
                    NSArray *list = [dataDic valueForKey:@"list"];
                    cityObject.cityName = [[dataDic valueForKey:@"city"] valueForKey:@"name"];
                    
                    for (NSDictionary *dayWeather in list) {
                        Weather *weather = [[Weather alloc]init];
                        NSString * dateSeconds = [dayWeather valueForKey:@"dt"];
                        NSDate *forecastDate = [NSDate dateWithTimeIntervalSince1970:dateSeconds.floatValue];
                        NSDateFormatter *dt = [[NSDateFormatter alloc]init];
                        [dt setDateFormat:@"EE dd MMM"];
                        
                        weather.forecastDate = [dt stringFromDate:forecastDate];
                        id min = [[dayWeather valueForKey:@"temp"] valueForKey:@"min"];
                        id max = [[dayWeather valueForKey:@"temp"] valueForKey:@"max"];
                        
                        weather.minTemp = [min doubleValue];
                        weather.maxTemp = [max doubleValue];
                        NSArray *weatherArray = [[dayWeather valueForKey:@"weather"] valueForKey:@"main"];
                        weather.weatherStatus = weatherArray.count?[weatherArray objectAtIndex:0]:@"NA";
                        
                        [dataArray addObject:weather];
                    }
                    cityObject.forecastArray = dataArray;
                    
                    //                    dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.delegate didRecieveResponse:cityObject];
                    //                    });
                    
                }
                
                else  {
                    
                    //                    dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [self.delegate didRecieveReceiveError:[dataDic valueForKey:@"message"]];
                    //                    });
                    
                }
                
                
            }
        }
        
    }];
    
    
}

-(void)fetchForcastDataForCity:(id)cityNameOrCLLocation andCompletionHandler:(void (^)(City *, NSError *))completionHandler
{
    NSString *apiString = nil;
    if ([cityNameOrCLLocation isKindOfClass:[NSString class]]) {
        apiString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=14&APPID=%@",cityNameOrCLLocation,API_KEY];
    }
    else if ([cityNameOrCLLocation isKindOfClass:[CLLocation class]]) {
        CLLocation *location = cityNameOrCLLocation;
        
        apiString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=14&APPID=%@",location.coordinate.latitude,location.coordinate.longitude,API_KEY];
    }
    
    
    NSURL *URL = [NSURL URLWithString:apiString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (data && !connectionError) {
            
            NSError *jsonExtractError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonExtractError];
            
            if (dataDic) {
                id responseCode = [dataDic valueForKey:@"cod"];
           

                if ( [responseCode intValue] == 200) {
                    City *cityObject =[City new];
                    NSMutableArray *dataArray = [NSMutableArray new];
                    
                    NSArray *list = [dataDic valueForKey:@"list"];
                    cityObject.cityName = [[dataDic valueForKey:@"city"] valueForKey:@"name"];
                    
                    for (NSDictionary *dayWeather in list) {
                        Weather *weather = [[Weather alloc]init];
                        NSString * dateSeconds = [dayWeather valueForKey:@"dt"];
                        NSDate *forecastDate = [NSDate dateWithTimeIntervalSince1970:dateSeconds.floatValue];
                        NSDateFormatter *dt = [[NSDateFormatter alloc]init];
                        [dt setDateFormat:@"EE dd MMM"];
                        
                        weather.forecastDate = [dt stringFromDate:forecastDate];
                        id min = [[dayWeather valueForKey:@"temp"] valueForKey:@"min"];
                        id max = [[dayWeather valueForKey:@"temp"] valueForKey:@"max"];
                        
                        weather.minTemp = [min doubleValue];
                        weather.maxTemp = [max doubleValue];
                        NSArray *weatherArray = [[dayWeather valueForKey:@"weather"] valueForKey:@"main"];
                        weather.weatherStatus = weatherArray.count?[weatherArray objectAtIndex:0]:@"NA";
                        
                        [dataArray addObject:weather];
                    }
                    cityObject.forecastArray = dataArray;
                    completionHandler(cityObject,nil);
                }
                else
                {
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:[dataDic valueForKey:@"message"] forKey:NSLocalizedDescriptionKey];
                        NSError *error = [NSError errorWithDomain:@"iWeather" code:[responseCode intValue] userInfo:details];
                    
                    completionHandler(nil,error);
                }
                
                
                
                
            }
        }
        
    }];
}
@end
