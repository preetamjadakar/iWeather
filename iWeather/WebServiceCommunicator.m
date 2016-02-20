//
//  WebServiceCommunicator.m
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import "WebServiceCommunicator.h"
#import "Constants.h"

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
-(void)fetchForcastForCity:(NSString*)cityName
{
    NSString *apiString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&cnt=14&APPID=%@",cityName,API_KEY];
    
    NSURL *URL = [NSURL URLWithString:apiString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if (data && !error) {
                                     
                                      NSError *jsonExtractError;
                                      NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonExtractError];
                                      
                                      if (dataDic) {
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
                                              
                                              [dataArray addObject:weather];
                                          }
                                          cityObject.forecastArray = dataArray;
                                          
                                          dispatch_sync(dispatch_get_main_queue(), ^{
                                              
                                              //                                          if (_delegate && [_delegate respondsToSelector:@selector(didRecieveResponse:)]){
                                              [self.delegate didRecieveResponse:cityObject];
                                              //                                          }
                                          });


                                      }
                                      }
                                  }];
    
    [task resume];
}


@end
