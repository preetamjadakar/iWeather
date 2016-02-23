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
    static WebServiceCommunicator *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
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
            //success piece
            NSError *jsonExtractError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonExtractError];
            
            if (dataDic) {
                id responseCode = [dataDic valueForKey:@"cod"];
                
                
                if ( [responseCode intValue] == 200) {
                    //found city data
                    BOOL foundTodayData = NO;
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
                        //min max temperature
                        id min = [[dayWeather valueForKey:@"temp"] valueForKey:@"min"];
                        id max = [[dayWeather valueForKey:@"temp"] valueForKey:@"max"];
                        
                        //"day" temperature is displayed as current
                        id current = [[dayWeather valueForKey:@"temp"] valueForKey:@"day"];
                        
                        
                        //conversion
                        if (/* DISABLES CODE */ (1)) {
                            //supposed to be converted to celcious by default
                            
                            weather.minTemp = [min doubleValue] - 273.15;
                            weather.maxTemp = [max doubleValue] - 273.15;
                            weather.currentTemp = [current doubleValue] - 273.15;
                        }
                        else
                        {
                            //kelvin by default from API
                            
                            weather.minTemp = [min doubleValue];
                            weather.maxTemp = [max doubleValue];
                            weather.currentTemp = [current doubleValue];
                        }
                        
                        NSArray *weatherMainArray = [[dayWeather valueForKey:@"weather"] valueForKey:@"main"];
                        weather.weatherStatus = weatherMainArray.count?[weatherMainArray objectAtIndex:0]:@"NA";
                        NSArray *weatherDescArray = [[dayWeather valueForKey:@"weather"] valueForKey:@"description"];
                        weather.weatherDescription = weatherDescArray.count?[weatherDescArray objectAtIndex:0]:@"NA";
                        [dataArray addObject:weather];
                        
                        if (!foundTodayData) {
                            
                            //compairing dates excluding time
                            NSUInteger day1 = [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:forecastDate];
                            NSUInteger day2 = [[NSCalendar currentCalendar] ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:[NSDate date]];
                            if (day1 == day2) {
                                
                                foundTodayData = YES;
                                
                                cityObject.todayWeather = weather;
                            }
                        }
                    }
                    
                    cityObject.forecastArray = dataArray;
                    completionHandler(cityObject,nil);
                }
                else
                {
                    //service success with data failure, error shown as-is
                    NSMutableDictionary* details = [NSMutableDictionary dictionary];
                    [details setValue:[dataDic valueForKey:@"message"] forKey:NSLocalizedDescriptionKey];
                    NSError *error = [NSError errorWithDomain:@"iWeather" code:[responseCode intValue] userInfo:details];
                    
                    completionHandler(nil,error);
                }

            }
            else
            {
                //data parsing error
                
            }
        }
        else
        {
            //unexpected error
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Unexpected error occoured. Please try later." forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"iWeather" code:-50 userInfo:details];
            
            completionHandler(nil,error);

        }
        
    }];
}
@end
