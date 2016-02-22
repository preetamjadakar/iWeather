//
//  ForecastCell.h
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForecastCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dayLabel;
@property (strong, nonatomic) IBOutlet UILabel *weatherStatus;
@property (strong, nonatomic) IBOutlet UILabel *maxTemp;
@property (strong, nonatomic) IBOutlet UILabel *minTemp;
@end
