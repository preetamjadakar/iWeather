//
//  WeatherCell.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface WeatherCell : UICollectionViewCell<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *forecastTableView;

@property (nonatomic)NSArray* forecastDataArray;
@property (strong, nonatomic) IBOutlet UILabel *cityName;


@end
