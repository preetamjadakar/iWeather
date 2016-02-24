//
//  WeatherCell.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

//forward declaration of current class
@class WeatherCell;

//protocol to handle button click of current cell
@protocol WeatherCellProtocol <NSObject>
@required
-(void)removeButtonClicked:(WeatherCell*)cell;
@end

//used to show City data in Collectionview
@interface WeatherCell : UICollectionViewCell<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *forecastTableView;

//to hold list of weather forcast data
@property (nonatomic)NSArray* forecastDataArray;

@property (strong, nonatomic) IBOutlet UILabel *cityName;
@property (strong, nonatomic) IBOutlet UILabel *maxTemp;
@property (strong, nonatomic) IBOutlet UILabel *minTemp;
@property (strong, nonatomic) IBOutlet UILabel *currentTemp;
@property (strong, nonatomic) IBOutlet UILabel *weatherDiscription;

//close button action
- (IBAction)removeCell:(id)sender;

//protocol's delegate
@property(weak)id<WeatherCellProtocol>delegate;
@end
