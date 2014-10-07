//
//  AppDelegate.m
//  ProcessingAutoLaunch
//
//  Created by chrisallick on 10/6/14.
//  Copyright (c) 2014 chrisallick. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:NO];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:YES];
    
    // Display the dialog. If the OK button was pressed,
    // process the files.
    NSString* url;
    if ( [openDlg runModal] == NSOKButton ) {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* urls = [openDlg URLs];
        // Loop through all the files and process them.
        for(int i = 0; i < [urls count]; i++ ) {
            url = [[urls objectAtIndex:i] path];
            NSLog(@"Url: %@", url);
        }
    }

    NSString *file_folder = [NSString stringWithFormat:@"%@/.runAtStartup/", url];
    [[NSFileManager defaultManager] createDirectoryAtPath:file_folder withIntermediateDirectories:NO attributes:nil error:nil];
    
    NSString *file_path = [NSString stringWithFormat:@"%@/cool.command", file_folder];
    [[NSFileManager defaultManager] createFileAtPath:file_path contents:nil attributes:@{NSFilePosixPermissions: @0744}];

    NSString *base = @"#!/usr/bin/env bash";
    NSString *command = [NSString stringWithFormat:@"processing-java --sketch=\"%@/\" --present --output=\"%@\" --force", url, file_folder];
    NSString *str = [NSString stringWithFormat:@"%@\n\n%@\n", base, command];

    [str writeToFile:file_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSAppleScript *script;
    NSDictionary *errorDict;
    NSAppleEventDescriptor *returnValue;
    NSString *scriptText = [NSString stringWithFormat:@"tell application \"System Events\" to make login item at end with properties {path:\"%@\", hidden:false, name:\"Processing App\"}", file_path];
    script = [[NSAppleScript alloc] initWithSource:scriptText];
    returnValue = [script executeAndReturnError:&errorDict];
    if (returnValue) {
        NSLog(@"success");
        exit(0);
    } else {
        NSLog(@"failure");
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
