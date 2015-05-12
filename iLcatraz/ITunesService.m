#import "ITunesService.h"
#import "DDLog.h"
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

static ITunesService *service=NULL;
static NSDateFormatter* dateFormatter=NULL;

@interface ITunesService()

{
    NSAppleScript* script;
}
@end

@implementation ITunesService
+(void) initialize
{
    dateFormatter=[[NSDateFormatter alloc] init];
    //2012-04-23T18:25:43.511Z
    [dateFormatter setDateFormat:@"\"yyyy-MM-dd'T'HH:mm:SSS'Z'Z\""];
}

+ (ITunesService*) service{
    if (service==NULL){
        service=[[ITunesService alloc] init];
    }
    return service;
}

+ (NSMutableString*)item2json:(NSAppleEventDescriptor*) descriptor
{
    NSAppleEventDescriptor* d;
    NSString* v;
    NSMutableString* ret=[[NSMutableString alloc] init ];
    
    d=[descriptor descriptorForKeyword:'ID  '];
    if (d!=NULL){
        v=[ITunesService descriptor2json:d];
        [ret appendString:@"\"id\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pidx'];
    if (d!=NULL){
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"index\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pnam'];
    if (d!=NULL){
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"name\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pPIS'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"persistent ID\":"];
        [ret appendString:v];
    }
    
    return ret;
}

+ (NSMutableString*)playlist2json:(NSAppleEventDescriptor*) descriptor
{
    NSMutableString* ret=[ITunesService item2json:descriptor];
    NSAppleEventDescriptor* d;
    NSString* v;
    
    d=[descriptor descriptorForKeyword:'pDur'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"duration\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pSiz'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"size\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pTim'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"time\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pvis'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"visible\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pShf'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"shuffle\":"];
        [ret appendString:v];
    }
    
    d=[descriptor descriptorForKeyword:'pRpt'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"song repeat\":"];
        [ret appendString:v];
    }
    d=[descriptor descriptorForKeyword:'pSpK'];
    if (d!=NULL) {
        v=[ITunesService descriptor2json:d];
        [ret appendString:@",\"special kind\":"];
        [ret appendString:v];
    }
    return ret;
}

+ (NSString*)descriptor2json:(NSAppleEventDescriptor*) descriptor
{
    
    NSInteger type=[descriptor descriptorType];
    
    //    NSMutableString* ret=NULL;
    
    switch (type){
        case kAENullEvent:return NULL;
        case cAEList:{
            NSMutableString* ret=NULL;
            long n=[descriptor numberOfItems];
            for (long i=1;i<=n;i++){
                NSString *item=[self descriptor2json:[descriptor descriptorAtIndex:i]];
                if (item!=NULL){
                    if (ret==NULL){
                        ret=[[NSMutableString alloc] init ];
                    }else{
                        [ret appendString:@","];
                    }
                    [ret appendString:item];
                }
            }
            if (ret==NULL) return @"[]";
            return [[@"[" stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"]"];
        }
        case 'cUsP': {
            NSMutableString* ret=[ITunesService playlist2json:descriptor];
            return [[@"{\"class\":\"user playlist\"," stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"}"];
        }
        case 'cLiP': {
            NSMutableString* ret=[ITunesService playlist2json:descriptor];
            return [[@"{\"class\":\"library playlist\"," stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"}"];
        }
        case 'cFoP': {
            NSMutableString* ret=[ITunesService playlist2json:descriptor];
            return [[@"{\"class\":\"folder playlist\"," stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"}"];
        }
        case 'cRTP': {
            NSMutableString* ret=[ITunesService playlist2json:descriptor];
            return [[@"{\"class\":\"radio tuner playlist\"," stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"}"];
        }
        case 'cFlT': {
            NSMutableString* ret=[ITunesService item2json:descriptor];
            NSAppleEventDescriptor* d;
            NSString* v;
            
            d=[descriptor descriptorForKeyword:'pDID'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"database ID\":"];
                [ret appendString:v];
            }
            
            d=[descriptor descriptorForKeyword:'pAdd'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"date added\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pDur'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"duration\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pTim'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"time\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pArt'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"artist\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pAlA'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"album artist\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pCmp'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"composer\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pAlb'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"album\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pGen'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"genre\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pBRt'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"bit rate\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSRt'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sample rate\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pTrC'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"track count\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pTrN'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"track number\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pDsC'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"disc count\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pDsN'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"disc number\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSiz'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"size\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pAdj'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"volume adjustment\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pYr '];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"year\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pCmt'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"comment\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pEQp'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"EQ\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pKnd'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"kind\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pVdK'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"video kind\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'asmo'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"modification date\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'enbl'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"enabled\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pStr'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"start\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pStp'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"finish\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pPlC'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"played count\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pPlD'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"played date\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSkC'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"skipped count\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSkD'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"skipped date\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pAnt'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"compilation\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pGpl'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"gapless\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pRte'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"rating\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pBPM'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"bpm\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pGrp'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"grouping\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pTPc'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"podcast\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pTIU'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"iTunesU\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pBkm'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"bookmarkable\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pBkt'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"bookmark\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSfa'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"shufflable\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pLyr'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"lyrics\":"];
                [ret appendString:[[v stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"]];
            }
            d=[descriptor descriptorForKeyword:'pCat'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"category\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pDes'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"description\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pLds'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"long description\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pShw'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"show\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSeN'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"season number\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pEpD'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"episode ID\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pEpN'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"episode number\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pUnp'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"unplayed\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSNm'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sort name\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSAl'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sort album\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSAr'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sort artist\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSCm'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sort composer\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSAA'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sort album artist\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pSSN'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"sort show\":"];
                [ret appendString:v];
            }
            d=[descriptor descriptorForKeyword:'pRlD'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"release date\":"];
                [ret appendString:v];
            }
            
            
            return [[@"{\"class\":\"file track\"," stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"}"];
        }
        case 'cSrc': {
            
            NSMutableString* ret=[ITunesService item2json:descriptor];
            NSAppleEventDescriptor* d;
            NSString* v;
            
            d=[descriptor descriptorForKeyword:'pKnd'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"special kind\":"];
                [ret appendString:v];
            }
            //        DDLogCVerbose(@"=====>: 0x%lx %@",(long)[d descriptorType],d);
            
            d=[descriptor descriptorForKeyword:'capa'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",capacity:"];
                [ret appendString:v];
            }
            
            d=[descriptor descriptorForKeyword:'frsp'];
            if (d!=NULL) {
                v=[ITunesService descriptor2json:d];
                [ret appendString:@",\"free space\":"];
                [ret appendString:v];
            }
            return [[@"{\"class\":\"source\"," stringByAppendingString:[NSString stringWithString:ret]] stringByAppendingString:@"}"];
        }
        case 'type': {
            OSType v=[descriptor enumCodeValue];
            switch(v){
                case 'msng': return @"\"missing value\"";
                    
                    
                default: return  [NSString stringWithFormat:@"Type: 0x%lx %@",(long)v,descriptor];
            }
        }
        case 'enum': {
            OSType v=[descriptor enumCodeValue];
            switch(v){
                case 'kLib': return @"\"library\"";
                case 'kTun': return @"\"radio tuner\"";
                    
                case 'kRpO': return @"\"off\"";
                    
                case 'kNon': return @"\"none\"";
                case 'kSpL': return @"\"Library\"";
                case 'kSpZ': return @"\"Music\"";
                case 'kSpI': return @"\"Movies\"";
                case 'kSpT': return @"\"TV Shows\"";
                case 'kSpP': return @"\"Podcasts\"";
                case 'kSpU': return @"\"iTunes U\"";
                case 'kSpA': return @"\"Books\"";
                case 'kSpM': return @"\"Purchased Music\"";
                case 'kSpF': return @"\"folder\"";
                    
                case 'kVdM': return @"\"movie\"";
                case 'kVdV': return @"\"music video\"";
                case 'kVdT': return @"\"TV show\"";
                    
                default: return  [NSString stringWithFormat:@"Enum: 0x%lx %@",(long)v,descriptor];
            }
        }
        case'doub':{
            double aDouble;
            [[[descriptor coerceToDescriptorType:typeIEEE64BitFloatingPoint]
              data] getBytes:&aDouble];
            
            return [NSString stringWithFormat:@"%e",aDouble];
        }
        case 'fals':
            return @"false";
        case 'true':
            return @"true";
        case 'long':
            return [NSString stringWithFormat:@"%d",[descriptor int32Value]];
        case 'utxt':
            return [[@"\""
                     stringByAppendingString:[[[[[descriptor stringValue] stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                                              stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"]]
                    stringByAppendingString:@"\""];            
            
        case 'ldt ': //typeLongDateTime
        {
            NSDate *resultDate = nil;
            OSStatus status;
            CFAbsoluteTime absoluteTime;
            LongDateTime longDateTime;
            
            [[descriptor data] getBytes:&longDateTime length:sizeof(longDateTime)];
            status = UCConvertLongDateTimeToCFAbsoluteTime(longDateTime, &absoluteTime);
            if (status == noErr) {
                resultDate = (NSDate *)CFBridgingRelease(CFDateCreate(NULL, absoluteTime));
            }else{
                [NSException raise:@"longDateTime" format:@"Can't convert longDateTime %@",descriptor];
            }
            return [dateFormatter stringFromDate:resultDate];
        }
        default:
            return [NSString stringWithFormat:@"Unknown type=0x%lx %@",(long)type,descriptor];
    }
    
}

- (id)init
{
	if((self = [super init]))
	{
    }
	return self;
}


- (NSAppleEventDescriptor*) resultForCode:(NSString *)code
{
    NSDictionary* errorDict;
    NSAppleEventDescriptor* returnDescriptor = NULL;
    
    DDLogCVerbose(@"Code: %@",code);
    script = [[NSAppleScript alloc] initWithSource: code];
    returnDescriptor = [script executeAndReturnError: &errorDict];
    
    if (returnDescriptor != NULL)
    {
        return returnDescriptor;
    }
    
    NSString* msg=[errorDict objectForKey:@"NSAppleScriptErrorMessage"];
    /*
     short e=[[errorDict objectForKey:@"NSAppleScriptErrorNumber"] shortValue];
     if (e==-1728){
     //NOT found
     }
     */
    if (msg==NULL)
        msg=@"Unknown Error";
    [NSException raise:@"iTunesError" format:@"iTunes error: %@",msg];
    return NULL;
}

- (NSString*) jsonForCode:(NSString *)code
{
    NSAppleEventDescriptor* returnDescriptor = [self resultForCode:code];
    return [ITunesService descriptor2json:returnDescriptor];
}

- (NSInteger) resultAsCount:(NSString *)code
{
    NSAppleEventDescriptor* returnDescriptor = [self resultForCode:code];
    return (NSInteger)[returnDescriptor int32Value];
}
- (NSString*) copyResultAsString:(NSString *)code
{
    NSAppleEventDescriptor* descriptor=[self resultForCode:code];
    CFStringRef posixPath = NULL;
    
    NSInteger type=[descriptor descriptorType];
    if (type!='alis') [NSException raise:@"Not path" format:@"Given Descriptor does not seem to be a path name"];
    
    NSAppleEventDescriptor *urlDesc = [descriptor
                                       coerceToDescriptorType:typeFileURL];
    NSString *hfsPath = [urlDesc stringValue];
    
    // make CFURL from HFS path
    BOOL isHFSDirectoryPath = [hfsPath hasSuffix:@":"];
    CFURLRef myURLRef = CFURLCreateWithFileSystemPath
    ( kCFAllocatorDefault,
     (CFStringRef)
     hfsPath ,
     
     kCFURLHFSPathStyle,
     
     isHFSDirectoryPath );
    if (NULL != myURLRef) {
        
        // make POSIX path from CFURL
        posixPath = CFURLCopyFileSystemPath( myURLRef,
                                            kCFURLPOSIXPathStyle );
        CFRelease( myURLRef );
    }
    //TODO: Memory leak, i do not know how to avoid
    return (__bridge NSString *)posixPath;
}

- (NSString*) jsonSources{
    return [self jsonForCode:@"tell application \"iTunes\"\n properties of sources\n end tell"];
}
- (NSInteger) countOfSources{
    return [self resultAsCount:@"tell application \"iTunes\"\n count of sources\n end tell"];
}
- (NSString*) jsonSourceWithID:(NSString*) pid {
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of first item of (sources whose persistent ID is \"%@\")\n end tell",pid]];
};
- (NSInteger) countOfPlaylistsOfSourceWithID:(NSString*) pid{
    return [self resultAsCount:[NSString stringWithFormat:@"tell application \"iTunes\"\n count of playlists of first item of (sources whose persistent ID is \"%@\")\n end tell",pid]];
}
- (NSString*) jsonPlaylistsOfSourceWithID:(NSString*) pid {
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of playlists of first item of (sources whose persistent ID is \"%@\")\n end tell",pid]];
};
- (NSString*) jsonPlaylists{
    return [self jsonForCode:@"tell application \"iTunes\"\n properties of playlists\n end tell"];
}
- (NSInteger) countOfPlaylists{
    return [self resultAsCount:@"tell application \"iTunes\"\n count of playlists\n end tell"];
}
- (NSString*) jsonPlaylistWithID:(NSString*) pid {
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of first item of (playlists whose persistent ID is \"%@\")\n end tell",pid]];
};
- (NSString*) jsonTracksOfPlaylistWithID:(NSString*) pid {
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of tracks of first item of (playlists whose persistent ID is \"%@\")\n end tell",pid]];
};
- (NSInteger) countOfTracksOfPlaylistWithID:(NSString*) pid;
{
    return [self resultAsCount:[NSString stringWithFormat:@"tell application \"iTunes\"\n count of tracks of first item of (playlists whose persistent ID is \"%@\")\n end tell",pid]];
};

- (NSString*) setRatingOfTrackWithID:(NSString*) pid to:(NSString*)rating {
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n set the rating of first item of (tracks whose persistent ID is \"%@\") to %@\n end tell",pid,rating]];
}

- (NSString*) jsonTrackWithID:(NSString*) pid {
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of first item of (tracks whose persistent ID is \"%@\")\n end tell",pid]];
}
- (NSString*) pathForTrackWithID:(NSString*) pid{
    return [self copyResultAsString:[NSString stringWithFormat:@"tell application \"iTunes\"\n location of first item of (tracks whose persistent ID is \"%@\")\n end tell",pid]];
}

//v2
- (NSInteger) countOfMediaPlaylists{
    return [self resultAsCount:@"tell application \"iTunes\"\n count of playlists\n end tell"];
};
- (NSString*) jsonMediaPlaylists {
    return [self jsonForCode:@"tell application \"iTunes\"\n properties of playlists\n end tell"];
}
- (NSString*) jsonMediaPlaylistWithID:(NSString*)pid{
        return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of first item of (playlists whose persistent ID is \"%@\")\n end tell",pid]];
};

- (NSString*) jsonTrackWithID:(NSString*)tid ofPlaysitWithID:(NSString*)pid{
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n properties of first item of (tracks of (first item  of (playlists whose persistent ID is \"%@\")) whose  persistent ID is \"%@\")\n end tell",pid,tid]];
};
- (NSString*) pathForTrackWithID:(NSString*)tid ofPlaysitWithID:(NSString*)pid{
    return [self copyResultAsString:[NSString stringWithFormat:@"tell application \"iTunes\"\n location of first item of (tracks of (first item  of (playlists whose persistent ID is \"%@\")) whose  persistent ID is \"%@\")\n end tell",pid,tid]];
};
- (NSString*) locationForTrackPath:(NSString*)path{
     NSArray *components=[path componentsSeparatedByString:@"iTunes Media/"];
    if ([components count]<2)
        return path;
    else
        return [components objectAtIndex:1];
};
- (NSString*) jsonPlaylitsOfFolderWithID:(NSString*) pid{
    return [self jsonForCode:[NSString stringWithFormat:@"tell application \"iTunes\"\n set f to first item of (playlists whose persistent ID is \"%@\")\n set results to {}\n repeat with p in playlists\n try\n if p's parent = f then set end of results to p's properties\n end try\n end repeat\n results\n end tell",pid]];
};


@end
