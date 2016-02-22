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

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController ()
{

}
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
    // Do any additional setup after loading the view, typically from a nib.
    
    //collectionview set up
    
        [self.weatheCollectionView registerNib:[UINib nibWithNibName:@"WeatherCell" bundle:nil] forCellWithReuseIdentifier:kWeatherCellID];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.sectionInset = UIEdgeInsetsMake(PADDING, PADDING,PADDING*3, PADDING);
    layout.minimumInteritemSpacing = PADDING*2;
    [self.weatheCollectionView setCollectionViewLayout:layout];
    
    //fetch users current location
    [[WebServiceCommunicator sharedInstance] setDelegate:self];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if(IS_OS_8_OR_LATER){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // location manager config for iOS 8 or later.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [self.locationManager startUpdatingLocation];
}
#pragma mark Webservice Communicator Delegate Responses


-(void)didRecieveResponse:(City *)city
{
    [self.dataSource addObject:city];
    [self.weatheCollectionView reloadData];
    
    //move to recent weather demanded
    NSIndexPath *lastObjectIndexPath = [NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0];
    [self.weatheCollectionView scrollToItemAtIndexPath:lastObjectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    self.pageIndicator.numberOfPages = self.dataSource.count;
    self.pageIndicator.currentPage = self.dataSource.count-1;

    [self.activityIndicatorView hide:YES];
}
-(void)didRecieveReceiveError:(NSString*)errorMessage
{
    [self.activityIndicatorView hide:YES];

    [[[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
//    [[WebServiceCommunicator sharedInstance]fetchForcastForCity:@"pune"];
    [WebServiceCommunicator sharedInstance];
}
#pragma mark Location Manager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [manager location];
    // Configure the new event with information from the location
    if (location)
    {
        if ([[WebServiceCommunicator sharedInstance]isNetworkConnection]) {
            [self.activityIndicatorView show:YES];
            
            [[WebServiceCommunicator sharedInstance]fetchForcastForCity:location];
            
            [manager stopUpdatingLocation];
        }
        else
        {
            [[[UIAlertView alloc]
              initWithTitle:@"Error" message:kNetworkErrorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
       
    }
    float longitude=location.coordinate.longitude;
    float latitude=location.coordinate.latitude;
    
    NSLog(@"dLongitude : %f", longitude);
    NSLog(@"dLatitude : %f", latitude);

}
- (void)locationManager:(CLLocationManager *)manager did:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"dLongitude : %f", currentLocation.coordinate.longitude);
        NSLog(@"dLatitude : %f", currentLocation.coordinate.latitude);
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
   
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
                //...
            {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle:@"Error" message:@"Go to settings and turn on access" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings",nil];
                errorAlert.tag = 101;
                [errorAlert show];
            }
                break;
            case kCLErrorLocationUnknown:
                //...
            {
//                UIAlertView *errorAlert = [[UIAlertView alloc]
//                                           initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [errorAlert show];
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
   
    [self addSomeShadowToCell:cell];
    City *city = [self.dataSource objectAtIndex:indexPath.row];
    cell.cityName.text = city.cityName;
    cell.forecastDataArray = city.forecastArray;
    [cell.forecastTableView reloadData];
    return cell;
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect visibleRect = (CGRect){.origin = self.weatheCollectionView.contentOffset, .size = self.weatheCollectionView.bounds.size};
    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect), CGRectGetMidY(visibleRect));
    NSIndexPath *visibleIndexPath = [self.weatheCollectionView indexPathForItemAtPoint:visiblePoint];
    self.pageIndicator.currentPage = visibleIndexPath.item;

}
-(void)addSomeShadowToCell:(WeatherCell*)cell
{
    cell.layer.shadowColor = [UIColor grayColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(1, 1);
    cell.layer.shadowRadius = 1.0f;
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.masksToBounds = NO;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 //to do
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize collectionViewSize = self.weatheCollectionView.bounds.size;
    return CGSizeMake(collectionViewSize.width-20, collectionViewSize.height-40);
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
            
            UITextField *textInput = [alertView textFieldAtIndex:0];
            [textInput resignFirstResponder];
            [[WebServiceCommunicator sharedInstance]fetchForcastDataForCity:textInput.text andCompletionHandler:^(City *cityObject, NSError *error) {
             
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
                                                    message:@"Enter a name of the City"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 100;
    [alert show];
        
}
@end
