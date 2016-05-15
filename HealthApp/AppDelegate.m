//
//  AppDelegate.m
//  HealthApp
//
//  Created by adverto on 03/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import <GoogleMaps/GoogleMaps.h>
#import "NeediatorAPIKey.h"
#import "LogSignViewController.h"
#import "Appirater.h"
#import "UIColor+HexString.h"
#import "ListingTableViewController.h"
#import "FavouritesViewController.h"
#import "QRCodeViewController.h"
#import "MyAccountViewController.h"



@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"didFinishLaunchingWithOptions");
    [NSThread sleepForTimeInterval:2.0];
    
    
    // Initialize Reachability
    self.googleReach = [Reachability reachabilityWithHostName:@"www.google.com"];
    
    // Start Monitoring
    [self.googleReach startNotifier];
    
    [self checkCurrentVersion];
    
    
    /* Appirater 1073622324*/
    
    [Appirater setAppId:kAPP_ID];
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    
    
    
    
    
    // To avoid lag of textfield
    UITextField *lagFreeField = [[UITextField alloc] init];
    [self.window addSubview:lagFreeField];
    [lagFreeField becomeFirstResponder];
    [lagFreeField resignFirstResponder];
    [lagFreeField removeFromSuperview];
    
    
    
    
    NSLog(@"%@",[self applicationDocumentsDirectory]);
    
    
    
    // UITabBar appearance
//    [[UIView appearanceWhenContainedIn:[UITabBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor yellowColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar"]];
    
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor blackColor], NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:@"AvenirNext-DemiBold" size:19.f], NSFontAttributeName , nil]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:235/255.f green:235/255.f blue:240/255.f alpha:1.0]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    
    
    
    // Google Maps
    [GMSServices provideAPIKey:kGoogleAPIKey];
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    //gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    
    /* Migration of Realm */
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 2;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        
        [migration enumerateObjects:MainCategoryRealm.className block:^(RLMObject * _Nullable oldObject, RLMObject * _Nullable newObject) {
            if (oldSchemaVersion < 1) {
                // do nothing.
            }
            
            if (oldSchemaVersion < 2) {
                // do nothing.
            }
        }];
    };
    
    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
    
    
    return YES;
    
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"openURL");
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    
    
    NSLog(@"%@", [tabController selectedViewController]);
    UINavigationController *navigationController = [tabController selectedViewController];
    
    if ([url.scheme isEqualToString:@"neediator"]) {
        if ([url.host isEqualToString:@"chemist"]) {
            
            
            
            ListingTableViewController *listingVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
            listingVC.root                       = @"Chemist";
            listingVC.category_id                 = @"1";
            listingVC.subcategory_id              = @"";
            
            [navigationController pushViewController:listingVC animated:YES];
        }
        else if ([url.host isEqualToString:@"myaccount"]) {
            UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
            
            [tabBarController setSelectedIndex:2];
        }
        else if ([url.host isEqualToString:@"search"]) {
            UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
            
            [tabBarController setSelectedIndex:1];
        }
        else if ([url.host isEqualToString:@"qrcode"]) {
            QRCodeViewController *QRCodeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"qrCodeVC"];
            [navigationController pushViewController:QRCodeVC animated:YES];
        }
        else if ([url.host isEqualToString:@"myFavourites"]) {
            FavouritesViewController *favouritesVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"favouritesVC"];
            [navigationController pushViewController:favouritesVC animated:YES];
        }
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"applicationWillResignActive");
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    NSLog(@"applicationDidEnterBackground");
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"applicationDidBecomeActive");
    
    
    
    
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self saveContext];
}


-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"3D Touch");
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    
    
    NSLog(@"%@", [tabController selectedViewController]);
    UINavigationController *navigationController = [tabController selectedViewController];
    
    if([shortcutItem.type isEqualToString:@"com.neediator.search"]) {
        UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
        
        [tabBarController setSelectedIndex:1];
    }
    else if ([shortcutItem.type isEqualToString:@"com.neediator.favourites"]) {
        
        FavouritesViewController *favouritesVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"favouritesVC"];
        [navigationController pushViewController:favouritesVC animated:YES];
    }
    else if ([shortcutItem.type isEqualToString:@"com.neediator.cart"]) {
        
        UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
        
        [tabBarController setSelectedIndex:3];
    }
    else if ([shortcutItem.type isEqualToString:@"com.neediator.scanqr"]) {
        QRCodeViewController *QRCodeVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"qrCodeVC"];
        [navigationController pushViewController:QRCodeVC animated:YES];
    }
        
    
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.advertotechnology.coredatatest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Cart" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Cart.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            [self.managedObjectContext rollback];
        }
    }
}


#pragma mark - UITabBarController Delegate 

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
     if ([viewController isEqual:[LogSignViewController class]]) {
        NSLog(@"log clicked");
    }
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"clicked");
}



#pragma mark - Get Current Orders

-(void)checkCurrentVersion {
    
    NSString *lookupString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",kAPP_ID];
    
    [[NAPIManager sharedManager] GET:lookupString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"Version Check %@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *appMetaData    = (NSDictionary *)responseObject;
        
        NSArray *resultsArray = (appMetaData)?[appMetaData objectForKey:@"results"]:nil;
        NSDictionary *resultsDic = [resultsArray firstObject];
        if (resultsDic) {
            // compare version with your apps local version
            NSString *iTunesVersion = [resultsDic objectForKey:@"version"];
            NSString *releaseNotes  = [resultsDic objectForKey:@"releaseNotes"];
            
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)@"CFBundleShortVersionString"];
            if (iTunesVersion && [appVersion compare:iTunesVersion] != NSOrderedSame) { // new version exists
                // inform user new version exists, give option that links to the app store to update your app - see
                
                NSString *title = [NSString stringWithFormat:@"New Version %@ Available", iTunesVersion];
                NSString *message = [NSString stringWithFormat:@"New in this version:\n %@", releaseNotes];
                
                UIAlertController *alertVersion = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *not_now = [UIAlertAction actionWithTitle:@"Not Now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSLog(@"Dismissed Version Alert");
                    
                    [alertVersion dismissViewControllerAnimated:YES completion:nil];
                }];
                
                
                UIAlertAction *update = [UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
//                    NSString *iTunesLink = [NSString stringWithFormat:@"itms://itunes.apple.com/us/app/apple-store/id%@?mt=8",kAPP_ID];
                    NSString *iTunesLink = kAPP_URL_STRING;
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];

                }];
                
                [alertVersion addAction:not_now];
                [alertVersion addAction:update];
                
                [self.window.rootViewController presentViewController:alertVersion animated:YES completion:nil];
                
            }
        }
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error in Version Check : %@",error.localizedDescription);
    }];
    
    
    
}


@end
