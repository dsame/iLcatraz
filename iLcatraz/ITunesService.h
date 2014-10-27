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

//v1
/*
- (NSString*) jsonSources;
- (NSInteger) countOfSources;
- (NSString*) jsonSourceWithID:(NSString*) pid;
- (NSString*) jsonPlaylistsOfSourceWithID:(NSString*) pid;
- (NSInteger) countOfPlaylistsOfSourceWithID:(NSString*) pid;
- (NSString*) jsonPlaylists;
- (NSInteger) countOfPlaylists;
- (NSString*) jsonPlaylistWithID:(NSString*) pid;
- (NSString*) jsonTrackWithID:(NSString*) pid;
- (NSString*) locationForTrackWithID:(NSString*) pid;
 */
//v2
- (NSInteger) countOfMediaPlaylists;
- (NSString*) jsonMediaPlaylists;
- (NSString*) jsonMediaPlaylistWithID:(NSString*)pid;
- (NSInteger) countOfTracksOfPlaylistWithID:(NSString*) pid;
- (NSString*) jsonTracksOfPlaylistWithID:(NSString*) pid;
- (NSString*) jsonPlaylitsOfFolderWithID:(NSString*) pid;
- (NSString*) jsonTrackWithID:(NSString*)tid ofPlaysitWithID:(NSString*)pid;
- (NSString*) pathForTrackWithID:(NSString*)tid ofPlaysitWithID:(NSString*)pid;
- (NSString*) locationForTrackPath:(NSString*)path;

@end
