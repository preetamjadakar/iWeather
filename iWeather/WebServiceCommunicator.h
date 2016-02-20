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

@protocol webserviceCommunicatorDelegate
-(void)didRecieveResponse:(City *)city;
@end


@interface WebServiceCommunicator : NSObject

+ (WebServiceCommunicator *)sharedInstance;

-(void)fetchForcastForCity:(NSString*)cityName;
@property(weak,nonatomic) id<webserviceCommunicatorDelegate> delegate;

@end
