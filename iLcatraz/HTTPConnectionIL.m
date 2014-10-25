#import "HTTPConnectionIL.h"
#import "RESTResponse.h"
#import "HTTPFileResponse.h"
#import "ITunesService.h"
#import "HTTPMessage.h"
#import "DDLog.h"

//static const int ddLogLevel = LOG_LEVEL_VERBOSE;


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
        NSArray *components=[path componentsSeparatedByString:@"/"];
        
        //DDLogInfo(@"components=%@",components);
        if ([components count]<2)
            return [[RESTResponse alloc] initWithJSON:@"Invalid Request" andStatus:404];
        
        if ([[components objectAtIndex:1] isEqual:@"sources"]){
            if ([components count]==2){
                c=[service countOfSources];
                if ([method isEqualToString:@"GET"])
                    ret=[service jsonSources];
                else if ([method isEqualToString:@"HEAD"]){
                    ret=@"";
                }
            }else{
                NSString* pid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:2]];
                if ([components count]==3)
                    ret=[service jsonSourceWithID:pid];
                else{
                    if ([[components objectAtIndex:3] isEqual:@"playlists"]){
                        c=[service countOfPlaylistsOfSourceWithID:pid];
                        if ([method isEqualToString:@"GET"])
                            ret=[service jsonPlaylistsOfSourceWithID:pid];
                        else if ([method isEqualToString:@"HEAD"]){
                            ret=@"";
                        }
                    }else{
                        return [[RESTResponse alloc] initWithJSON:@"Invalid Source Request" andStatus:400];
                    }
                }
            }
        }else if ([[components objectAtIndex:1] isEqual:@"playlists"]){
            if ([components count]==2){
                c=[service countOfPlaylists];
                if ([method isEqualToString:@"GET"])
                    ret=[service jsonPlaylists];
                else if ([method isEqualToString:@"HEAD"]){
                    ret=@"";
                }
            }else{
                NSString* pid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:2]];
                if ([components count]==3)
                    ret=[service jsonPlaylistWithID:pid];
                else{
                    if ([[components objectAtIndex:3] isEqual:@"tracks"]){
                        c=[service countOfTracksOfPlaylistWithID:pid];
                        if ([method isEqualToString:@"GET"])
                            ret=[service jsonTracksOfPlaylistWithID:pid];
                        else if ([method isEqualToString:@"HEAD"]){
                            ret=@"";
                        }
                    }else{
                        return [[RESTResponse alloc] initWithJSON:@"Invalid Playlist Request" andStatus:400];
                    }
                }
                
            }
        }else if ([[components objectAtIndex:1] isEqual:@"tracks"]){
            if ([components count]<3)
                return [[RESTResponse alloc] initWithJSON:@"Track Request Must Have ID" andStatus:400];
            else{
                NSString* pid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:2]];
                if ([components count]==3)
                    ret=[service jsonTrackWithID:pid];
                else{
                    return [[RESTResponse alloc] initWithJSON:@"Invalid Track Request" andStatus:400];
                }
            }
        }else if ([[components objectAtIndex:1] isEqual:@"location"]){
            if ([components count]<3)
                return [[RESTResponse alloc] initWithJSON:@"Location of Filetrack Request Must Have ID" andStatus:400];
            else{
                NSString* pid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:2]];
                if ([components count]==3)
                    ret=[service locationForTrackWithID:pid];
                else{
                    return [[RESTResponse alloc] initWithJSON:@"Invalid Track Request" andStatus:400];
                }
            }
        }else if ([[components objectAtIndex:1] isEqual:@"filetrack"]){
            if ([components count]<3)
                return [[RESTResponse alloc] initWithJSON:@"Filetrack Request Must Have ID" andStatus:400];
            else{
                NSString* pid=[HTTPConnectionIL sanitizePID:[components objectAtIndex:2]];
                if ([components count]==3){
                    NSString *path=[service locationForTrackWithID:pid];
                    return [[HTTPFileResponse alloc] initWithFilePath:path forConnection:self];
                }else{
                    return [[RESTResponse alloc] initWithJSON:@"Invalid Track Request" andStatus:400];
                }
            }
        }else{
            return [[RESTResponse alloc] initWithJSON:@"Invalid Object Request" andStatus:404];
        }
        if (ret!=NULL)
        {
            if ([method isEqualToString:@"HEAD"] && c<0)
                return [[RESTResponse alloc] initWith405];
            if (c>=0)
                return [[RESTResponse alloc] initWithJSON:ret status:200 andCount:c];
            else
                return [[RESTResponse alloc] initWithJSON:ret andStatus:200];
        }else{
            return [[RESTResponse alloc] initWithJSON:@"Invalid Request" andStatus:404];
        }
    }
    @catch (NSException *exception) {
        return [[RESTResponse alloc] initWithText:[exception reason] andStatus:500];
    }
}
@end
