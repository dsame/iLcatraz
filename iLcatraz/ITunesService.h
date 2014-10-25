//
//  ITunesService.h
//  iLcatraz
//
//  Created by Macmini on 22.10.14.
//
//

#import <Foundation/Foundation.h>

@interface ITunesService : NSObject
+ (ITunesService*) service;

- (NSString*) jsonSources;
- (NSInteger) countOfSources;
- (NSString*) jsonSourceWithID:(NSString*) pid;
- (NSString*) jsonPlaylistsOfSourceWithID:(NSString*) pid;
- (NSInteger) countOfPlaylistsOfSourceWithID:(NSString*) pid;
- (NSString*) jsonPlaylists;
- (NSInteger) countOfPlaylists;
- (NSString*) jsonPlaylistWithID:(NSString*) pid;
- (NSInteger) countOfTracksOfPlaylistWithID:(NSString*) pid;
- (NSString*) jsonTracksOfPlaylistWithID:(NSString*) pid;
- (NSString*) jsonTrackWithID:(NSString*) pid;
- (NSString*) locationForTrackWithID:(NSString*) pid;
@end
