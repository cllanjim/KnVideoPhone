//
//  AVDecodeStream.cpp
//  KnVideoPhone
//
//  Created by cyh on 7/26/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#include "AVDecodeStream.h"


AVDecodeStream::AVDecodeStream(unsigned char* pBuffer)
{
    buffer = pBuffer;
    len = 0;
    offset = 0;
}


AVDecodeStream::~AVDecodeStream()
{
    buffer = 0;
}

void AVDecodeStream::reset()
{
    len = offset = 0;
}