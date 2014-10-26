//
//  FileResponse.m
//  iLcatraz
//
//  Created by Macmini on 26.10.14.
//  Copyright (c) 2014 dsa. All rights reserved.
//

#import "FileResponse.h"

@implementation FileResponse
- (id)initWithFilePath:(NSString *)aFilePath andLocation:(NSString*)location forConnection:(HTTPConnection *)aConnection{
    if (self==[super initWithFilePath:aFilePath forConnection:aConnection]){
        headers = [NSDictionary dictionaryWithObjectsAndKeys:location,@"X-iTunes-Location",nil];
    };
    return self;
};
- (NSDictionary *)httpHeaders {
    return headers;
};
@end
