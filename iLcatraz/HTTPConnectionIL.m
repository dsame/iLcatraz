#import "HTTPConnectionIL.h"
#import "RESTResponse.h"
#import "FileResponse.h"
#import "ITunesService.h"
#import "HTTPMessage.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;


@implementation HTTPConnectionIL

+ (NSString*) sanitizePID:(NSString*) pid{
    NSArray *components=[pid componentsSeparatedByString:@" "];
    if ([components count]>1){
        pid=[components objectAtIndex:2];
    }
    components=[pid componentsSeparatedByString:@";"];
    if ([components count]>1){
        pid=[components objectAtIndex:2];
    }
    components=[pid componentsSeparatedByString:@"\n"];
    if ([components count]>1){
        pid=[components objectAtIndex:2];
    }
    components=[pid componentsSeparatedByString:@"\""];
    if ([components count]>1){
        pid=[components objectAtIndex:2];
    }
    components=[pid componentsSeparatedByString:@"\\"];
    if ([components count]>1){
        pid=[components objectAtIndex:2];
    }
    return pid;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    ITunesService* service=[ITunesService service];
    
    @try {
        NSString *ret=NULL;
        NSInteger c=-1;
        NSString *trackLocation=NULL;
        NSArray *components=[path componentsSeparatedByString:@"/"];
        
        /*
         /
         */
        if ([components count]<2){
            return [[RESTResponse alloc] initWithJSON:@"Invalid Request" andStatus:404];
        }
        /*
         /component1
         */
        if ([[components objectAtIndex:1] isEqualTo:@"help"]){
            NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"help.html"];
            
            DDLogInfo(@"WebPath=%@",webPath);
            return [[HTTPFileResponse alloc] initWithFilePath:webPath forConnection:self];
        }
        
        if (![[components objectAtIndex:1] isEqual:@"media"]){
            return [[RESTResponse alloc] initWithJSON:@"Only help and media resources are available now" andStatus:404];
        }
        /*
         /media/component2/...
         */
        
        if ([components count]<3){
            return [[RESTResponse alloc] initWithJSON:@"Media require \"playlists\" resources request" andStatus:400];
        }
        
        if ([[components objectAtIndex:2] isEqual:@"playlists"]){
            /*
             /media/playlists/...
             */
            if ([components count]==3){
                /*
                 /media/playlists
                 */
                c=[service countOfMediaPlaylists];
                if ([method isEqualToString:@"GET"])
                    ret=[service jsonMediaPlaylists];
                else if ([method isEqualToString:@"HEAD"]){
                    ret=@"";
                }
            }else{
                /*
                 /media/playlists/...
                 */
                NSString* pid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:3]];
                if ([components count]==4){
                /*
                 /media/playlists/ID
                 */
                    ret=[service jsonMediaPlaylistWithID:pid];
                }else{
                    /*
                     /media/playlists/ID/...
                     */
                    if ([[components objectAtIndex:4] isEqual:@"tracks"]){
                        /*
                         /media/playlists/ID/tracks/...
                         */
                        if ([components count]==5){
                            /*
                             /media/playlists/ID/tracks
                             */
                            c=[service countOfTracksOfPlaylistWithID:pid];
                            if ([method isEqualToString:@"GET"]){
                                if (c==0)
                                    ret=@"[]";
                                else
                                    ret=[service jsonTracksOfPlaylistWithID:pid];
                            } else if ([method isEqualToString:@"HEAD"]){
                                ret=@"";
                            }
                        }else{
                            /*
                             /media/playlists/ID/tracks...
                             */
                            NSString* tid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:5]];
                            if ([components count]==6){
                                /*
                                 /media/playlists/ID/tracks/ID
                                 */
                                NSString *trackPath=[service pathForTrackWithID:tid  ofPlaysitWithID:pid];
                                trackLocation=[service locationForTrackPath:trackPath];
                                ret=[service jsonTrackWithID:tid ofPlaysitWithID:pid];
                            }else{
                                /*
                                 /media/playlists/ID/tracks/ID/...
                                 */
                                NSString* trackAttr=[HTTPConnectionIL sanitizePID:[components objectAtIndex:6]];
                                if ([trackAttr isEqualToString:@"file"] && [components count]==7){
                                    NSString *trackPath=[service pathForTrackWithID:tid  ofPlaysitWithID:pid];
                                    trackLocation=[service locationForTrackPath:trackPath];
                                    if ([method isEqualToString:@"GET"])
                                        return [[FileResponse alloc] initWithFilePath:trackPath andLocation:trackLocation forConnection:self];
                                    else if ([method isEqualToString:@"HEAD"]){
                                        ret=@"";
                                    }
                                }else{
                                    return [[RESTResponse alloc] initWithJSON:[NSString stringWithFormat:@"\"%@\" is not known resource of a resource. \"file\" expected.",[components objectAtIndex:6]] andStatus:404];
                                }
                            }
                            
                        }
                    }else{
                        if ([[components objectAtIndex:4] isEqual:@"playlists"]){
                            /*
                             /media/playlists/ID/playlists
                             */
                            if ([components count]==5){
                                /*
                                 /media/playlists/ID/playlists
                                 */
                                ret=[service jsonPlaylitsOfFolderWithID:pid];
                            }else{
                                return [[RESTResponse alloc] initWithJSON:@"Use /mdeia/playlists API to get specific playlist" andStatus:400];
                            }
                        }else{
                        /*
                         /media/playlists/ID/<bad>
                         */
                        return [[RESTResponse alloc] initWithJSON:[NSString stringWithFormat:@"\"%@\" is not known resource of a playlist. \"tracks\" or \"playlists\" expected",[components objectAtIndex:4]] andStatus:404];
                        }
                    }
                }
            }
        } else if ([[components objectAtIndex:2] isEqual:@"tracks"]){
            if ([components count]>3){
                /*
                 /media/tracks/ID...
                 */
                NSString* tid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:3]];
                if ([components count]==4){
                    /*
                     /media/tracks/ID
                     */
                    if ([method isEqualToString:@"PATCH"]){
                        NSData *data = [request body];
                        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        
                        NSArray *fields=[str componentsSeparatedByString:@"&"];
                        
                        int updatec=0;
                        NSString *field;
                        NSEnumerator *fi=[fields objectEnumerator];
                        
                        while (field = [fi nextObject]){
                            NSArray *pair=[field componentsSeparatedByString:@"="];
                            if ([pair count]!=2){
                                return [[RESTResponse alloc]
                                        initWithJSON:@"PATCH must be in form param1=value&param2=value2&..." andStatus:400];
                            }
                            NSString *param=[pair objectAtIndex:0];
                            NSString *value=[pair objectAtIndex:1];
                            if ([@"rating" isEqualToString:param]){
                                updatec++;
                                [service setRatingOfTrackWithID:tid to:value];
                            }
                        }
                        if (updatec==0){
                            return [[RESTResponse alloc]
                                    initWithJSON:@"No parameters" andStatus:400];
                        }
                    }
                    
                    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"PATCH"]) {
                        NSString *trackPath=[service pathForTrackWithID:tid];
                        trackLocation=[service locationForTrackPath:trackPath];
                        ret=[service jsonTrackWithID:tid];
                    }else {
                        return [[RESTResponse alloc] initWithJSON:@"Only GET and PATCH methods are allowed to this resource" andStatus:400];
                    }
                }else{
                    /*
                     /media/tracks/ID/...
                     */
                    NSString* trackAttr=[HTTPConnectionIL sanitizePID:[components objectAtIndex:4]];
                    if ([trackAttr isEqualToString:@"file"] && [components count]==5    ){
                        NSString *trackPath=[service pathForTrackWithID:tid];
                        trackLocation=[service locationForTrackPath:trackPath];
                        if ([method isEqualToString:@"GET"])
                            return [[FileResponse alloc] initWithFilePath:trackPath andLocation:trackLocation forConnection:self];
                        else if ([method isEqualToString:@"HEAD"]){
                            ret=@"";
                        }
                    }else{
                        return [[RESTResponse alloc] initWithJSON:[NSString stringWithFormat:@"\"%@\" is not known resource of a track. \"file\" expected.",[components objectAtIndex:4]] andStatus:404];
                    }
                }
            }else{
                 return [[RESTResponse alloc] initWithJSON:@"ID must follow \"tracks\" resources request" andStatus:400];
            }
        }else{
            /*
             /media/<bad>
             */
            
            return [[RESTResponse alloc] initWithJSON:[NSString stringWithFormat:@"\"%@\" is not known resource of the media library. \"playlists\" or \"tracks\" expected.",[components objectAtIndex:2]] andStatus:404];
        }
        
        if (ret!=NULL)
        {
            if (c>=0)
                return [[RESTResponse alloc] initWithJSON:ret status:200 andCount:c];
            if (trackLocation!=NULL)
                return [[RESTResponse alloc] initWithJSON:ret status:200 andLocation:trackLocation];
            if ([method isEqualToString:@"HEAD"]) {
                return [[RESTResponse alloc] initWith405];
            }
            return [[RESTResponse alloc] initWithJSON:ret andStatus:200];
        }else{
            return [[RESTResponse alloc] initWithJSON:@"Invalid Request" andStatus:400];
        }
    }
    @catch (NSException *exception) {
        return [[RESTResponse alloc] initWithText:[exception reason] andStatus:500];
    }
}
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    if ([method isEqualToString:@"PATCH"])
        return YES;
    
    return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    if ([method isEqualToString:@"PATCH"] && [path rangeOfString:@"/media/tracks/"].location == 0)
        return YES;
    return [super supportsMethod:method atPath:path];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    [request setBody:postDataChunk];
}
@end
