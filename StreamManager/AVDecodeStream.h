//
//  AVDecodeStream.h
//  KnVideoPhone
//
//  Created by cyh on 7/26/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#ifndef __KnVideoPhone__AVDecodeStream__
#define __KnVideoPhone__AVDecodeStream__

//#include <iostream>

class AVDecodeStream {
public:
    unsigned char* buffer;
    int len;
    int offset;
    
public:
    AVDecodeStream(unsigned char* pBuffer);
    virtual ~AVDecodeStream();
    void reset();
    
};


#endif /* defined(__KnVideoPhone__AVDecodeStream__) */
