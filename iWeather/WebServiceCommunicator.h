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
@protocol webserviceCommunicatorDelegate
-(void)didRecieveResponse:(City *)city;
-(void)didRecieveReceiveError:(NSString*)errorMessage;

@end


@interface WebServiceCommunicator : NSObject

// This class is intended to be used as a singleton.
+ (WebServiceCommunicator *)sharedInstance;

-(void)fetchForcastForCity:(id)cityNameOrCLLocation;
@property(weak,nonatomic) id<webserviceCommunicatorDelegate> delegate;
-(BOOL)isNetworkConnection;

-(void)fetchForcastDataForCity:(id)cityNameOrCLLocation andCompletionHandler:(void(^)(City* cityObject, NSError *error))completionHandler;

@end
