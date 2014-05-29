//
//  AppDelegate.m
//  Links
//
//  Created by Eoin Nolan on 17/12/2013.
//  Copyright (c) 2013 Nolaneo. All rights reserved.
//

#import "AppDelegate.h"
#import "Library.h"
#import "LibraryViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    if (url != nil && [url isFileURL]) {
        
        if ([[url pathExtension] isEqualToString:@"txt"]) {
            //NSString * content = [NSString stringWithContentsOfFile:url encoding:NSUTF8StringEncoding error:NULL];
            NSString * content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL];
            NSLog(@"URL:%@", [url absoluteString]);
            UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            LibraryViewController * libraryViewController = (LibraryViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"LibraryViewController"];
            [(UINavigationController *)self.window.rootViewController pushViewController:libraryViewController animated:NO];
            [libraryViewController addNewBookWithText:content title:[[[url path] lastPathComponent] stringByDeletingPathExtension]];
            
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [Library saveLibrary];
}


@end
