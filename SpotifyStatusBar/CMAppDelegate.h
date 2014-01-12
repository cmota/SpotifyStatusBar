//
//  CMAppDelegate.h
//  SpotifyStatusMenu
//
//  Created by Carlos Mota on 11/25/13.
//  Copyright (c) 2013 Carlos Mota. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CMAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
{
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
}

@property (weak) IBOutlet NSMenuItem *songName;
@property (weak) IBOutlet NSMenuItem *playState;

@property (assign) BOOL playingSong;

@end
