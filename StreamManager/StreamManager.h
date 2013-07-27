#ifndef __STREAM_MANAGER_H__
#define __STREAM_MANAGER_H__
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <stdlib.h>
//#include <malloc.h>
#include <pthread.h>
//#include <jni.h>
///#include <android/log.h>
#include "AVDecodeStream.h"
#include "AVWritePacket.h"

//#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "ffmpeg", __VA_ARGS__);
#define SERVER_PORT 6000


#define STREAM_COMMAND  0
#define STREAM_RESPONSE 1
#define STREAM_VIDEO 2
#define STREAM_VOICE 3
#define STREAM_AUDIO 4
#define MAX_STREAM_NUM 5

#define MAX_VIDEO_BUFFER_SIZE 200000
#define MAX_AUDIO_BUFFER_SIZE 4000

#define PACKET_NOT_FINISH 	-1
#define PACKET_PARSE_ERROR 	-2
#define SOCKET_DISCONNECT	-3
class StreamManager {
//public :
//	JavaVM *jvm;
//	JNIEnv *mEnv;
public :
    int mServerSocketFD, mClientSocketFD;
	// server side
	struct sockaddr_in mServerSockAddr;
	struct sockaddr_in mClientSockAddr;
    unsigned char prefixBuffer[4];
    AVDecodeStream *decodeStream[MAX_STREAM_NUM];
    AVDecodeStream *currentStream;

    AVWritePacket writeCommandPacket;
    AVWritePacket writeResponsePacket;
    AVWritePacket writeVideoPacket;
    AVWritePacket writeVoicePacket;
	int readOffset, readSize, prefix_len, payload_len, stream_id;
	int endOfStream;

	// client side
	struct sockaddr_in mSocketAddr;
    int mSocketFile;

    unsigned char *writeBuffer;
    int mStreamID;

    pthread_mutex_t mWriteLock;
	int writeOffset;
	int writeLen;
	int writeSize;

public:
    StreamManager();
	virtual ~StreamManager();

    
	int createServer(int port);
	int waitingClient();
	int closeServer();

	int connectToServer(const char *ipaddress, int port);
	int readFrame();
	int getFrameLength(int stream_id);
	void resetFrame(int stream_id);
	int writeCommand(char *inputbuffer, int length);
	int writeResponse(char *inputbuffer, int length);
	int writeVideoFrame(int streamid, unsigned char *inputbuffer, int length);
	int writeVoiceFrame(int streamid, unsigned char *inputbuffer, int length);
	int write(AVWritePacket *packet) ;
	int disconnect();

	void registerDecodeStream(int stream_type, unsigned char *pBuffer);
	void sendConnectCommand();
	void sendCreateVideoStream(int codecid, int width, int height, int samplerate, int orientation, unsigned char* metadata, int meta_len);
	void sendCreateAudioStream(int codecid, int samplerate, int channels, unsigned char* metadata, int meta_len);
	void sendCreateVoiceStream(int codecid, int samplerate, int channels, unsigned char* metadata, int meta_len);

	void sendRemoveVideoStream();
	void sendRemoveAudioStream();
	void sendRemoveVoiceStream();
};

#endif
