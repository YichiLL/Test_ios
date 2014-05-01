//
//  WeatherPrototypeViewController.m
//  TripGo
//
//  Created by Tom Hsu on 5/1/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "WeatherPrototypeViewController.h"

@interface WeatherPrototypeViewController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSDictionary *data;
@end

@implementation WeatherPrototypeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",40.80936333333333, -73.96116666666667];
    NSURL *url = [NSURL URLWithString:urlString];
    [self fetchJSONFromURL:url];
}

- (NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }

    return _session;
}

- (void)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);

    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (! error) {
            NSError *jsonError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (!jsonError) {
                NSLog(@"Json parsed = %@", json);
                self.data = json;
            }
            else {
                NSLog(@"Json cannot be parsed = %@", jsonError);
            }
        }
        else {
            NSLog(@"Error in sending request = %@", error);
        }
    }];

    [dataTask resume];
}

#define WTHR_RESULT_WEATHERS                @"weather"
#define WTHR_RESULT_WEATHER_DESCRIPTIONS    @"weather.description"
#define WTHR_RESULT_WEATHER_CATEGORIES      @"weather.main"
#define WTHR_RESULT_TEMPERATURE             @"main.temp"
#define WTHR_RESULT_HUMIDITY                @"main.humidity"
#define WTHR_RESULT_CLOUDS                  @"clouds.all"
#define WTHR_RESULT_WIND_SPEED              @"wind.speed"

- (void)setData:(NSDictionary *)data
{
    _data = data;

    NSArray *weathers = [data valueForKeyPath:WTHR_RESULT_WEATHERS];
    NSLog(@"weathers = %@", weathers);
    id descriptions = [data valueForKeyPath:WTHR_RESULT_WEATHER_DESCRIPTIONS];
    NSLog(@"descriptions = %@", descriptions);
    id categories = [data valueForKeyPath:WTHR_RESULT_WEATHER_CATEGORIES];
    NSLog(@"categories = %@", categories);
    id temp = [data valueForKeyPath:WTHR_RESULT_TEMPERATURE];
    NSLog(@"temprature = %@", temp);
    id humidity = [data valueForKeyPath:WTHR_RESULT_HUMIDITY];
    NSLog(@"humidity = %@", humidity);
    id clouds = [data valueForKeyPath:WTHR_RESULT_CLOUDS];
    NSLog(@"clouds = %@", clouds);
    id wind_speed = [data valueForKeyPath:WTHR_RESULT_WIND_SPEED];
    NSLog(@"wind_speed = %@", wind_speed);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
