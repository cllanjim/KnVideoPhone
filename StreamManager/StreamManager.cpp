#include "StreamManager.h"

StreamManager::StreamManager() {
    
    writeBuffer = new unsigned char[MAX_PACKET_SIZE+100];
    mStreamID = 0;
    mServerSocketFD = -1;
    mSocketFile = -1;

	for(int i=0;i<MAX_STREAM_NUM;i++)
		decodeStream[i] = NULL;

    pthread_mutexattr_t mAttr;
    pthread_mutexattr_settype(&mAttr, 3);
    pthread_mutex_init(&mWriteLock, &mAttr);
}

StreamManager::~StreamManager() {
	for(int i=0;i<MAX_STREAM_NUM;i++) {
		if(decodeStream[i]!=NULL)
			delete decodeStream[i];
	}
	delete writeBuffer;
	pthread_mutex_destroy (&mWriteLock);
}

int StreamManager::createServer(int port)
{
    try {

		if(mServerSocketFD!=-1)
			return 1;
        printf("try to create Server : %d\n", port);

		mServerSocketFD = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
		if (mServerSocketFD < 0) {
            printf("create server socket is failed\n");
			throw -1;
		}

	    int opt_val = 1, opt_len;
	    opt_len = sizeof(opt_val);
	    setsockopt(mClientSocketFD, SOL_SOCKET, SO_REUSEADDR, &opt_val, sizeof(opt_val));
	    setsockopt(mClientSocketFD, IPPROTO_TCP, TCP_NODELAY, (void*)&opt_val, sizeof(opt_val));
	    opt_val = 64000;
	    setsockopt(mClientSocketFD, SOL_SOCKET, SO_SNDBUF, &opt_val, opt_len);
	    setsockopt(mClientSocketFD, SOL_SOCKET, SO_RCVBUF, &opt_val, opt_len);

		mServerSockAddr.sin_family = AF_INET;
		mServerSockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
		mServerSockAddr.sin_port = htons(port);

		if (bind (mServerSocketFD, (struct sockaddr *) &mServerSockAddr, sizeof (mServerSockAddr)) < 0) {
            printf("fail to bind\n");
			close(mServerSocketFD);
			throw -1;
		}

        printf("success to bind server & listening...\n");
		if (listen (mServerSocketFD, 5) < 0) {
            printf("fail to listen\n");
            close(mServerSocketFD);
			throw -1;
		}
    }
    catch (int i) {
    	return 0;
    }
    return 1;
}

int StreamManager::waitingClient() {

	int addrlen = sizeof(mClientSockAddr);
    mClientSocketFD = accept(mServerSocketFD, (struct sockaddr *) &mClientSockAddr, (socklen_t *)&addrlen);

    
    int opt_val = 1, opt_len;
    opt_len = sizeof(opt_val);
    setsockopt(mClientSocketFD, SOL_SOCKET, SO_REUSEADDR, &opt_val, sizeof(opt_val));
    setsockopt(mClientSocketFD, IPPROTO_TCP, TCP_NODELAY, (void*)&opt_val, sizeof(opt_val));
    opt_val = 64000;
    setsockopt(mClientSocketFD, SOL_SOCKET, SO_SNDBUF, &opt_val, opt_len);
    setsockopt(mClientSocketFD, SOL_SOCKET, SO_RCVBUF, &opt_val, opt_len);

    printf("success to accept client\n");
    return mSocketFile;
}

int StreamManager::closeServer() {

    if(mServerSocketFD!=-1) {
    	close(mServerSocketFD);
    	mServerSocketFD = -1;
    }
    
    if(mClientSocketFD!=-1) {
    	close(mClientSocketFD);
    	mClientSocketFD =-1;
    }
    
    printf("close server\n");
    
    return 0;
}


int StreamManager::connectToServer(const char *ipaddress, int port)
{
    mClientSocketFD = socket(PF_INET,SOCK_STREAM,0);
    if (mClientSocketFD < 0) {
        printf("create server socket is failed\n");
        return -1;
    }

    mSocketAddr.sin_family = AF_INET;
    mSocketAddr.sin_port = htons(port);
    inet_aton(ipaddress, &mSocketAddr.sin_addr);

    printf("try to connectToServer : %s\n", ipaddress);
    if(connect(mClientSocketFD, (struct sockaddr *)&mSocketAddr, sizeof(mSocketAddr)) == -1) {
        printf("fail to connect : %s\n", ipaddress);
        return -1;
    }

    int opt_val = 1, opt_len;
    opt_len = sizeof(opt_val);
    setsockopt(mClientSocketFD, SOL_SOCKET, SO_REUSEADDR, &opt_val, sizeof(opt_val));
    setsockopt(mClientSocketFD, IPPROTO_TCP, TCP_NODELAY, (void*)&opt_val, sizeof(opt_val));
    opt_val = 64000;
    setsockopt(mClientSocketFD, SOL_SOCKET, SO_SNDBUF, &opt_val, opt_len);
    setsockopt(mClientSocketFD, SOL_SOCKET, SO_RCVBUF, &opt_val, opt_len);

    printf("success to connectToServer : %s\n", ipaddress);
    return mClientSocketFD;
}

void StreamManager::registerDecodeStream(int stream_id, unsigned char *pBuffer) {
	if(decodeStream[stream_id] == NULL) {
		decodeStream[stream_id]  = new AVDecodeStream(pBuffer);
        
        printf("registerDecodeStream : %d %p\n", stream_id, decodeStream[stream_id]);
	}
}

int StreamManager::readFrame() {
	prefix_len = 4;
	readOffset = 0;
	do{
		readSize = recv(mClientSocketFD, prefixBuffer+readOffset, prefix_len, 0);
		if(readSize>=0) {
			readOffset += readSize;
			prefix_len -= readSize;
		}
		else {
            printf("error : socket disconnect1\n");
			return SOCKET_DISCONNECT;
		}
	} while(prefix_len>0);
    
	if(prefixBuffer[0] != 0xFF) {
        printf("error : parse prefix 0 %x\n", prefixBuffer[0]);
		return PACKET_PARSE_ERROR;
	}

	endOfStream = prefixBuffer[2] & 0x80;
	stream_id = ((int)prefixBuffer[1]) & 0x0F;
	payload_len = (((int)prefixBuffer[2] & 0x7F) << 8) + (int)prefixBuffer[3];
	currentStream = decodeStream[stream_id];
	currentStream->len += payload_len;

	do{
		readSize = recv(mClientSocketFD, currentStream->buffer + currentStream->offset, payload_len, 0);
		if(readSize>=0) {
			currentStream->offset += readSize;
			payload_len -= readSize;
		}
		else {
            printf("error : socket disconnect2\n");
			return -3;
		}
	} while(payload_len>0);

	return (endOfStream)? stream_id : PACKET_NOT_FINISH;
}

int StreamManager::getFrameLength(int stream_id) {
//	if(decodeStream[stream_id]!=NULL) {
//		return decodeStream[stream_id]->len;
//	}
	return 0;
}
void StreamManager::resetFrame(int stream_id) {
	if(decodeStream[stream_id]!=NULL)
		decodeStream[stream_id]->reset();
}

int StreamManager::write(AVWritePacket *packet) {
	pthread_mutex_lock (&mWriteLock);
	writeOffset = 0;
	writeLen = 4;
	do {
		writeSize = send(mClientSocketFD, packet->header + writeOffset, writeLen, 0);
		if(writeSize>=0) {
			writeOffset +=writeSize;
			writeLen -= writeSize;
		}
		else {
			pthread_mutex_unlock (&mWriteLock);
			return SOCKET_DISCONNECT;
		}
	} while(writeLen>0);

	do {
		writeSize = send(mClientSocketFD, packet->buffer, packet->length, 0);
		if(writeSize>=0) {
			packet->buffer += writeSize;
			packet->length -= writeSize;
		}
		else {
			pthread_mutex_unlock (&mWriteLock);
			return SOCKET_DISCONNECT;
		}
	} while(packet->length>0);
	pthread_mutex_unlock (&mWriteLock);
	return 1;
}
int StreamManager::writeCommand(char* inputbuffer, int length) {
    writeCommandPacket.buffer = (unsigned char*)inputbuffer;
    writeCommandPacket.setType(STREAM_COMMAND);
    writeCommandPacket.setEnd(length);
	if(write(&writeCommandPacket)<0)
		return SOCKET_DISCONNECT;
	return 1;
}
int StreamManager::writeResponse(char* inputbuffer, int length) {
	writeResponsePacket.buffer = (unsigned char*)inputbuffer;
	writeResponsePacket.setType(STREAM_RESPONSE);
	writeResponsePacket.setEnd(length);
	if(write(&writeResponsePacket)<0)
		return SOCKET_DISCONNECT;
	return 1;
}
int StreamManager::writeVideoFrame(int streamid, unsigned char * inputbuffer, int length) {
    writeVideoPacket.buffer = (unsigned char*)inputbuffer;
    writeVideoPacket.setType(streamid);
	while(length > MAX_PACKET_SIZE) {
		writeVideoPacket.setMid();
		if(write(&writeVideoPacket)<0)
			return SOCKET_DISCONNECT;
		length -= MAX_PACKET_SIZE;
	}
	writeVideoPacket.setEnd(length);
	if(write(&writeVideoPacket)<0)
		return SOCKET_DISCONNECT;
	return 1;
}

int StreamManager::writeVoiceFrame(int streamid, unsigned char * inputbuffer, int length) {
    writeVoicePacket.buffer = (unsigned char*)inputbuffer;
    writeVoicePacket.setType(streamid);
	while(length > MAX_PACKET_SIZE) {
		writeVoicePacket.setMid();
		if(write(&writeVoicePacket)<0)
			return SOCKET_DISCONNECT;
		length -= MAX_PACKET_SIZE;
	}
	writeVoicePacket.setEnd(length);
	if(write(&writeVoicePacket)<0)
		return SOCKET_DISCONNECT;
	return 1;
}

int StreamManager::disconnect() {
	close(mSocketFile);
    return 0;
}

void StreamManager::sendConnectCommand() {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'c';
	writePacket.setEnd(pTemp - writeBuffer);
	write(&writePacket);
}

void StreamManager::sendCreateVideoStream(int codecid, int width, int height, int samplerate, int orientation, unsigned char* metadata = NULL, int meta_len = 0) {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'n';
	*(pTemp++) = STREAM_VIDEO;
	*(pTemp++) = codecid;
	*(pTemp++) = (width >> 8)&0xff;
	*(pTemp++) = (width & 0xff);
	*(pTemp++) = (height >> 8) & 0xff;
	*(pTemp++) = (height & 0xff);
	*(pTemp++) = samplerate/100000;
	*(pTemp++) = orientation;
	if(meta_len>0) {
		*(pTemp++) = meta_len;
		memcpy(pTemp, metadata, meta_len);
	    writePacket.buffer = writeBuffer;
	    writePacket.setType(STREAM_COMMAND);
		writePacket.setEnd(pTemp - writeBuffer + meta_len);
	}
	else {
		writePacket.setEnd(pTemp - writeBuffer);
	}

//	LOGI("sendCreateVideoStream %x ", writeBuffer[0]);
	write(&writePacket);
}
void StreamManager::sendCreateAudioStream(int codecid, int samplerate, int channels, unsigned char* metadata = NULL, int meta_len = 0) {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'n';
	*(pTemp++) = STREAM_AUDIO;
	*(pTemp++) = codecid;
	*(pTemp++) = (samplerate >> 8)&0xff;
	*(pTemp++) = (samplerate & 0xff);
	*(pTemp++) = channels;
	if(meta_len>0) {
		*(pTemp++) = meta_len;
		memcpy(pTemp, metadata, meta_len);
	    writePacket.buffer = writeBuffer;
	    writePacket.setType(STREAM_COMMAND);
		writePacket.setEnd(pTemp - writeBuffer + meta_len);
	}
	else {
	    writePacket.buffer = writeBuffer;
	    writePacket.setType(STREAM_COMMAND);
		writePacket.setEnd(pTemp - writeBuffer);
	}
//	LOGI("sendCreateAudioStream %x ", writeBuffer[0]);
	write(&writePacket);
}
void StreamManager::sendCreateVoiceStream(int codecid, int samplerate, int channels, unsigned char* metadata = NULL, int meta_len = 0) {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'n';
	*(pTemp++) = STREAM_VOICE;
	*(pTemp++) = codecid;
	*(pTemp++) = samplerate;
	*(pTemp++) = channels;
	if(meta_len>0) {
		*(pTemp++) = meta_len;
		memcpy(pTemp, metadata, meta_len);
	    writePacket.buffer = writeBuffer;
	    writePacket.setType(STREAM_COMMAND);
		writePacket.setEnd(pTemp - writeBuffer + meta_len);
	}
	else {
	    writePacket.buffer = writeBuffer;
	    writePacket.setType(STREAM_COMMAND);
		writePacket.setEnd(pTemp - writeBuffer);
	}
	write(&writePacket);
}

void StreamManager::sendRemoveVideoStream() {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'r';
	*(pTemp++) = STREAM_VIDEO;
    writePacket.buffer = writeBuffer;
    writePacket.setType(STREAM_COMMAND);
	writePacket.setEnd(pTemp - writeBuffer);
	write(&writePacket);
}
void StreamManager::sendRemoveAudioStream()  {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'r';
	*(pTemp++) = STREAM_AUDIO;
    writePacket.buffer = writeBuffer;
    writePacket.setType(STREAM_COMMAND);
	writePacket.setEnd(pTemp - writeBuffer);
	write(&writePacket);
}
void StreamManager::sendRemoveVoiceStream()  {
    AVWritePacket writePacket;
	unsigned char *pTemp = writeBuffer;

	*(pTemp++) = 'r';
	*(pTemp++) = STREAM_VOICE;
    writePacket.buffer = writeBuffer;
    writePacket.setType(STREAM_COMMAND);
	writePacket.setEnd(pTemp - writeBuffer);
	write(&writePacket);
}
