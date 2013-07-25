#include "AVWritePacket.h"

AVWritePacket::AVWritePacket() {
	header[0] = 0xff;
}

AVWritePacket::~AVWritePacket() {

}

void AVWritePacket::setType(int id) {
	header[1] = id | 0xF0;
}

void AVWritePacket::setMid() {
	header[2] = (MAX_PACKET_SIZE >> 8);
	header[3] = MAX_PACKET_SIZE & 0xFF;
	length = MAX_PACKET_SIZE;
}

void AVWritePacket::setEnd(int len) {
	header[2] = (len >> 8) | 0x80;
	header[3] = len & 0xFF;
	length = len;
}


