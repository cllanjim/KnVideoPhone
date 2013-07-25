#ifndef __AV_WRITE_PACKET_H__
#define __AV_WRITE_PACKET_H__

#define MAX_PACKET_SIZE 1420

class AVWritePacket {
public:
	int length;
	unsigned char header[4];
	unsigned char *buffer;

	AVWritePacket();
	~AVWritePacket();
	void setType(int id);
	void setMid();
	void setEnd(int len);
};

#endif
