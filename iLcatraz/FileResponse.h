//
//  FileResponse.h
//  iLcatraz
//
//  Created by Macmini on 26.10.14.
//  Copyright (c) 2014 dsa. All rights reserved.
//

#import "HTTPFileResponse.h"

@interface FileResponse : HTTPFileResponse{
    NSDictionary *headers;
}
- (id)initWithFilePath:(NSString *)filePath andLocation:(NSString*)location forConnection:(HTTPConnection *)connection;

@end
