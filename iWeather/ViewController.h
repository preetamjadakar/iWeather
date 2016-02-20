//
//  ViewController.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceCommunicator.h"
@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,webserviceCommunicatorDelegate,UIAlertViewDelegate>

@property (nonatomic)NSMutableArray* dataSource;
- (IBAction)addCity:(id)sender;

@end

