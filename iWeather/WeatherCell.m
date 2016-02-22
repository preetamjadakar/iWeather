//
//  WeatherCell.m
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import "WeatherCell.h"
#import "ForecastCell.h"
#import "City.h"
#import "Weather.h"

@implementation WeatherCell
- (void)awakeFromNib {
    // Initialization code
    self.forecastDataArray = [[NSArray alloc]init];


}
# pragma mark - UITableViewControllerDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.forecastDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
        ForecastCell *cell = [tableView dequeueReusableCellWithIdentifier:kForecastCellID];
        
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ForecastCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
     Weather *weather = [self.forecastDataArray objectAtIndex:indexPath.row];
    

            cell.dayLabel.text = weather.forecastDate;
    cell.weatherStatus.text = weather.weatherStatus;
    


    //conversion
    if (/* DISABLES CODE */ (1)) {
        //supposed to be converted to celcious by default
        int celciousMin = weather.minTemp - 273.15;
        int celciousMax = weather.maxTemp - 273.15;
        cell.minTemp.text = [NSString stringWithFormat:@"%d%@",celciousMin, @"\u00B0"];
        cell.maxTemp.text = [NSString stringWithFormat:@"%d%@",celciousMax, @"\u00B0"];

    }
    else
    {
        //kelvin by default from API
        cell.minTemp.text = [NSString stringWithFormat:@"%d%@",(int)weather.minTemp, @"\u00B0"];
        cell.maxTemp.text = [NSString stringWithFormat:@"%d%@",(int)weather.maxTemp, @"\u00B0"];
  
    }
        return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}
@end
