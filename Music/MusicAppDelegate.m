//
//  MusicAppDelegate.m
//  Music
//
//  Created by Dmitry Ratushnyy on 22/11/15.
//

#import "MusicAppDelegate.h"

@implementation MusicAppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    
    return YES;
}

@end
