//
//  ViewController.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceCommunicator.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>

@property (nonatomic)NSMutableArray* dataSource;
- (IBAction)addCity:(id)sender;
@property (nonatomic)CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIPageControl *pageIndicator;
@end

