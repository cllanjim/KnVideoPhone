//
//  AVDecodeStream.cpp
//  KnVideoPhone
//
//  Created by cyh on 7/26/13.
//  Copyright (c) 2013 cyh. All rights reserved.
//

#include "AVDecodeStream.h"


AVDecodeStream::AVDecodeStream(uint8_t* pBuffer)
{
    buffer = pBuffer;
    len = 0;
    offset = 0;
}


AVDecodeStream::~AVDecodeStream()
{
    buffer = NULL;
}

void AVDecodeStream::reset()
{
    len = offset = 0;
}