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
    

//    self.forecastTableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.forecastTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
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
    cell.minTemp.text = [NSString stringWithFormat:@"%d%@",weather.minTemp, kDegreeUC];
    cell.maxTemp.text = [NSString stringWithFormat:@"%d%@",weather.maxTemp, kDegreeUC];
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.cityName;
}
- (IBAction)removeCell:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(removeButtonClicked:)]) {
        [self.delegate removeButtonClicked:self];
    }
}
@end
