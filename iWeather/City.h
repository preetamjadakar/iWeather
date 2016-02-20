//
//  City.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject
@property(nonatomic)NSString *cityName;

//array to hold weather forcast objects
@property(nonatomic)NSArray *forecastArray;

@end
