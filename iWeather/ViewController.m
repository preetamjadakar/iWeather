//
//  ViewController.m
//  iWeather
//
//  Created by Preetam Jadakar on 20/02/16.
//  Copyright © 2016 Preetam Jadakar. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "WeatherCell.h"
#import "WebServiceCommunicator.h"
#import "MBProgressHUD.h"


@interface ViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *weatheCollectionView;
@property (strong, nonatomic)MBProgressHUD *activityIndicatorView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicatorView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.navigationController.view addSubview:self.activityIndicatorView];
    self.activityIndicatorView.opacity = 0.5;
    
    
    self.dataSource = [NSMutableArray new];
    
    //collectionview set up
    self.weatheCollectionView.backgroundColor = [UIColor clearColor];

    [self.weatheCollectionView registerNib:[UINib nibWithNibName:@"WeatherCell" bundle:nil] forCellWithReuseIdentifier:kWeatherCellID];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.sectionInset = UIEdgeInsetsMake(PADDING, PADDING,PADDING*3, PADDING);
    layout.minimumInteritemSpacing = PADDING*2;
    [self.weatheCollectionView setCollectionViewLayout:layout];
    
    //fetch users current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if(IS_OS_8_OR_LATER){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // location manager config for iOS 8 or later.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Location Manager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [manager location];
    if (location)
    {
        //if valid location found
        if ([[WebServiceCommunicator sharedInstance]isNetworkConnection]) {
            [manager stopUpdatingLocation];
            self.locationManager = nil;

            [self.activityIndicatorView show:YES];
            [self.activityIndicatorView setLabelText:@"fetching current weather..."];
            
            //can use cityname(rever geocoding) but lat long is user for the more accurate location result
            [self fetchData:location];
            
        }
        else
        {
            [[[UIAlertView alloc]
              initWithTitle:@"Error" message:kNetworkErrorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {

            case kCLErrorDenied:
                //access denied when user asked by iOS
            {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Error" message:@"Looks like you denied location access. Please go to settings and turn on access." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings",nil];
                errorAlert.tag = 101;
                [errorAlert show];
            }
                break;
            case kCLErrorLocationUnknown:
                //...
            {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Error" message:@"Failed to get your location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
            }
                break;
            default:
                //...
                break;
        }
    } else {
        // We handle all non-CoreLocation errors here
    }
}

#pragma mark - UICollectionViewDataDelegates
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeatherCell *cell =
    (WeatherCell *)[self.weatheCollectionView dequeueReusableCellWithReuseIdentifier:kWeatherCellID
                                                                        forIndexPath:indexPath];
    
    [self addSomeBorderToCell:cell];
    City *city = [self.dataSource objectAtIndex:indexPath.row];
    cell.cityName.text = city.cityName;
    cell.weatherDiscription.text = city.todayWeather.weatherDescription;
    cell.minTemp.text = [NSString stringWithFormat:@"%d%@",city.todayWeather.minTemp, kDegreeUC];
    cell.maxTemp.text = [NSString stringWithFormat:@"%d%@",city.todayWeather.maxTemp, kDegreeUC];
    cell.currentTemp.text = [NSString stringWithFormat:@"%d%@",city.todayWeather.minTemp, kDegreeUC];
    
    cell.forecastDataArray = city.forecastArray;
    [cell.forecastTableView reloadData];
    return cell;
    
}
-(void)addSomeBorderToCell:(WeatherCell*)cell
{
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = .50;
    cell.layer.masksToBounds = NO;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize collectionViewSize = self.weatheCollectionView.bounds.size;
    return CGSizeMake(collectionViewSize.width-2*PADDING, collectionViewSize.height-40);
}
#pragma mark UIScrollview  Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect visibleRect = (CGRect){.origin = self.weatheCollectionView.contentOffset, .size = self.weatheCollectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.weatheCollectionView indexPathForItemAtPoint:visiblePoint];
    self.pageIndicator.currentPage = visibleIndexPath.item;
    
}


#pragma mark - UIAlertViewDataDelegates
-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag==101) {
        return YES;
    }
    UITextField *textInput = [alertView textFieldAtIndex:0];
    if (textInput.text.length>1) {
        return YES;
    }
    return NO;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==101) {
        if (buttonIndex==1) {
            
            //done
            if(IS_OS_8_OR_LATER)
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            else
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
            
            
        }
        else
        {
            //cancel
        }
        
    }
    else   if (alertView.tag==100) {
        if (buttonIndex==1) {
            //done
            
            if ([[WebServiceCommunicator sharedInstance]isNetworkConnection]) {
                [self.activityIndicatorView show:YES];
                [self.activityIndicatorView setLabelText:nil];

                UITextField *textInput = [alertView textFieldAtIndex:0];
                [self fetchData:textInput.text];
                
            }
            else
            {
                [[[UIAlertView alloc]
                  initWithTitle:@"Error" message:kNetworkErrorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            
            
        }
        else
        {
            //cancel
        }
    }
}
- (IBAction)addCity:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Please enter City name."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
    
}

#pragma mark Webservice Communicator Delegate Responses

//just to avaid code redundency, made it reusable
-(void)fetchData:(id)cityNameOrCLLocation
{
    [[WebServiceCommunicator sharedInstance]fetchForcastDataForCity:cityNameOrCLLocation andCompletionHandler:^(City *cityObject, NSError *error) {
        
        if (error == nil) {
            
            [self.dataSource addObject:cityObject];
            [self.weatheCollectionView reloadData];
            
            //move to recent weather demanded
            NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0];
            [self.weatheCollectionView scrollToItemAtIndexPath:lastObjectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            self.pageIndicator.numberOfPages = self.dataSource.count;
            self.pageIndicator.currentPage = self.dataSource.count-1;
            [self.activityIndicatorView hide:YES];
            
        }
        else
        {
            [self.activityIndicatorView hide:YES];
            
            [[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
            
        }
        
    }];
    
}
@end
