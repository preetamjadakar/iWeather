//
//  WebServiceCommunicator.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Weather.h"
#import "City.h"
#import "Reachability.h"


@interface WebServiceCommunicator : NSObject

// This class is intended to be used as a singleton.
+ (WebServiceCommunicator *)sharedInstance;

//to check if internet connection is available
-(BOOL)isNetworkConnection;

//method with completion handle to fetch weather data asynchronously
-(void)fetchForcastDataForCity:(id)cityNameOrCLLocation andCompletionHandler:(void(^)(City* cityObject, NSError *error))completionHandler;

@end
