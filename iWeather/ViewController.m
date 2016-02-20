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
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView *weatheCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray new];
    // Do any additional setup after loading the view, typically from a nib.
    
    //collectionview set up
    
        [self.weatheCollectionView registerNib:[UINib nibWithNibName:@"WeatherCell" bundle:nil] forCellWithReuseIdentifier:kWeatherCellID];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.weatheCollectionView setCollectionViewLayout:layout];
    [[WebServiceCommunicator sharedInstance] setDelegate:self];
}
-(void)didRecieveResponse:(City *)city
{
    [self.dataSource addObject:city];
    [self.weatheCollectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[WebServiceCommunicator sharedInstance]fetchForcastForCity:@"pune"];
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
    City *city = [self.dataSource objectAtIndex:indexPath.row];
    cell.cityName.text = city.cityName;
    cell.forecastDataArray = city.forecastArray;
    
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 //to do
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize collectionViewSize = self.weatheCollectionView.bounds.size;
    return collectionViewSize;
}
- (IBAction)addCity:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a name of City"
                                                    message:@"Enter a name of City"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];


}
#pragma mark - UICollectionViewDataDelegates
-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textInput = [alertView textFieldAtIndex:0];
    if (textInput.text.length>1) {
        return YES;
    }
    return NO;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        
        //done
        UITextField *textInput = [alertView textFieldAtIndex:0];
        [[WebServiceCommunicator sharedInstance]fetchForcastForCity:textInput.text];

    }
    else
    {
        //cancel
    }
}

@end
