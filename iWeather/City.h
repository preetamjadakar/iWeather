//
//  City.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weather.h"
@interface City : NSObject
@property(nonatomic)NSString *cityName;

//array to hold weather forcast objects
@property(nonatomic)NSArray *forecastArray;

//for the city's today weather
@property(nonatomic)Weather *todayWeather;


@end
