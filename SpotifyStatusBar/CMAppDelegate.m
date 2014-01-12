//
//  CMAppDelegate.m
//  SpotifyStatusMenu
//
//  Created by Carlos Mota on 11/25/13.
//  Copyright (c) 2013 Carlos Mota. All rights reserved.
//

#import "CMAppDelegate.h"

@implementation CMAppDelegate

NSString *kEventSpotifyPlaybackChanged = @"com.spotify.client.PlaybackStateChanged";
NSString *kSpotifyEmbedArtwork = @"https://embed.spotify.com/oembed/?url=";

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(createPlayingNotification:) name:kEventSpotifyPlaybackChanged object:nil];
}

- (void)awakeFromNib
{
    statusMenu.delegate = self;
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[NSImage imageNamed:@"music_icon_status_bar"]];
    [statusItem setHighlightMode:YES];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    NSAppleScript *scriptArtist = [[NSAppleScript alloc] initWithSource: @"tell application \"Spotify\" to return artist of current track"];
    NSAppleScript *scriptTrack = [[NSAppleScript alloc] initWithSource: @"tell application \"Spotify\" to return name of current track"];
    NSAppleEventDescriptor *dataArtist = [scriptArtist executeAndReturnError:nil];
    NSAppleEventDescriptor *dataTrack = [scriptTrack executeAndReturnError:nil];
    NSLog(@"%@ - %@", [dataArtist stringValue], [dataTrack stringValue]);
    
    NSAppleScript *scriptPlaying = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to get player state"];
    NSAppleEventDescriptor *playerState = [scriptPlaying executeAndReturnError:nil];
    NSLog(@"state=%@", [playerState stringValue]);
    
    if([[playerState stringValue] isEqualToString:@"kPSp"]){
        self.playState.title = @"Play";
    } else if([[playerState stringValue] isEqualToString:@"kPSP"]) {
        self.playState.title = @"Pause";
    } else if([[playerState stringValue] isEqualToString:@"kPSS"]) {
        self.playState.title = @"Stopped";
    }
    
    self.songName.title = [NSString stringWithFormat:@"%@ - %@", [dataArtist stringValue], [dataTrack stringValue]];
}

- (IBAction)playAction:(id)sender
{
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to playpause"];
    [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
}

- (IBAction)nextAction:(id)sender
{
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to next track"];
    [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
}

- (IBAction)previousAction:(id)sender
{
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell application \"Spotify\" to previous track"];
    [script performSelectorOnMainThread:@selector(executeAndReturnError:) withObject:nil waitUntilDone:YES];
}

- (void)createPlayingNotification:(NSNotification *)notification
{
    // TODO: App implement its own preferences so the user could specify if they want the notifications to be visible
    
    NSDictionary *info = [notification userInfo];
    
    if(![[info objectForKey:@"Player State"] isEqualToString:@"Playing"])
    {
        return;
    }
    
    //NSLog(@"notification=%@", notification);
    
    NSUserNotification *playNotification = [[NSUserNotification alloc] init];
    [playNotification setTitle:[info objectForKey:@"Name"]];
    [playNotification setSubtitle:[info objectForKey:@"Album"]];
    [playNotification setInformativeText:[info objectForKey:@"Artist"]];

    #if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_9

        if([info objectForKey:@"Has Artwork"])
        {
            NSString *reqUrl = [kSpotifyEmbedArtwork stringByAppendingString:[info objectForKey:@"Track ID"]];

            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
            NSDictionary *outputData = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:NSJSONReadingMutableContainers
                                       error:nil];

            NSURL *reqImage = [NSURL URLWithString:[outputData objectForKey:@"thumbnail_url"]];
            NSData *artD = [NSData dataWithContentsOfURL:reqImage];
        
            [playNotification setContentImage:[[NSImage alloc] initWithData:artD]];
        }
    
    #else
        //Do nothing
    #endif
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center scheduleNotification:playNotification];
}

@end
