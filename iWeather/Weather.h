//
//  Weather.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property(nonatomic)NSString *forecastDate;
@property(nonatomic)NSString *weatherStatus;
@property(nonatomic)NSString *weatherDescription;

@property(nonatomic)int minTemp;
@property(nonatomic)int maxTemp;
@property(nonatomic)int currentTemp;

@end
