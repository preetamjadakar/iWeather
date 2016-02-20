//
//  WeatherCell.m
//  iWeather
//
//  Created by Pramath Bakliwal's iMac-2 on 20/02/16.
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
    CGRect tableViewFrame = self.forecastTableView.frame;
    self.forecastTableView.frame = CGRectMake(tableViewFrame.origin.x, tableViewFrame.origin.y, tableViewFrame.size.width, 15*44);
    [self.forecastTableView setNeedsDisplay];
    [self layoutIfNeeded];

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
    
    
        return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.;
}
@end
