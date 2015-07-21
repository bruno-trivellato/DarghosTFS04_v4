////////////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////
#include "otpch.h"
#if defined WINDOWS
#include <winerror.h>
#endif

#include "protocol.h"
#include "scheduler.h"

#include "connection.h"
#include "outputmessage.h"

#include "tools.h"
#include "rsa.h"

extern RSA g_RSA;

void Protocol::onSendMessage(OutputMessage_ptr msg)
{
	#ifdef __DEBUG_NET_DETAIL__
	std::clog << "Protocol::onSendMessage" << std::endl;
	#endif
	if(!m_rawMessages)
	{
		msg->writeMessageLength();
		if(m_encryptionEnabled)
		{
			#ifdef __DEBUG_NET_DETAIL__
			std::clog << "Protocol::onSendMessage - encrypt" << std::endl;
			#endif
			XTEA_encrypt(*msg);
		}

		if(m_checksumEnabled)
		{
			#ifdef __DEBUG_NET_DETAIL__
			std::clog << "Protocol::onSendMessage - crypto header" << std::endl;
			#endif
			msg->addCryptoHeader(m_checksumEnabled);
		}
	}

	if(msg == m_outputBuffer)
		m_outputBuffer.reset();
}

void Protocol::onRecvMessage(NetworkMessage& msg)
{
	#ifdef __DEBUG_NET_DETAIL__
	std::clog << "Protocol::onRecvMessage" << std::endl;
	#endif
	if(m_encryptionEnabled)
	{
		#ifdef __DEBUG_NET_DETAIL__
		std::clog << "Protocol::onRecvMessage - decrypt" << std::endl;
		#endif
		XTEA_decrypt(msg);
	}

	parsePacket(msg);
}

OutputMessage_ptr Protocol::getOutputBuffer(int32_t size)
{
    if (m_outputBuffer && NetworkMessage::max_protocol_body_length >= m_outputBuffer->getLength() + size) {
        return m_outputBuffer;
    } else if (m_connection) {
        m_outputBuffer = OutputMessagePool::getInstance()->getOutputMessage(this);
        return m_outputBuffer;
    }
    return OutputMessage_ptr();
}

void Protocol::releaseProtocol()
{
	if(m_refCount > 0)
        g_scheduler.addEvent(createSchedulerTask(SCHEDULER_MINTICKS, boost::bind(&Protocol::releaseProtocol, this)));
	else
		deleteProtocolTask();
}

void Protocol::deleteProtocolTask()
{
	//dispather thread
	assert(!m_refCount);
	setConnection(Connection_ptr());
	delete this;
}

void Protocol::XTEA_encrypt(OutputMessage& msg) const
{
    const uint32_t delta = 0x61C88647;

    // The message must be a multiple of 8
    size_t paddingBytes = msg.getLength() % 8;
    if (paddingBytes != 0) {
        msg.addPaddingBytes(8 - paddingBytes);
    }

    uint32_t* buffer = reinterpret_cast<uint32_t*>(msg.getOutputBuffer());
    const size_t messageLength = msg.getLength() / 4;
    size_t readPos = 0;
    const uint32_t k[] = {m_key[0], m_key[1], m_key[2], m_key[3]};
    while (readPos < messageLength) {
        uint32_t v0 = buffer[readPos], v1 = buffer[readPos + 1];
        uint32_t sum = 0;

        for (int32_t i = 32; --i >= 0;) {
            v0 += ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + k[sum & 3]);
            sum -= delta;
            v1 += ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + k[(sum >> 11) & 3]);
        }

        buffer[readPos++] = v0;
        buffer[readPos++] = v1;
    }
}

bool Protocol::XTEA_decrypt(NetworkMessage& msg) const
{
    if (((msg.getLength() - 6) & 7) != 0) {
        return false;
    }

    const uint32_t delta = 0x61C88647;

    uint32_t* buffer = reinterpret_cast<uint32_t*>(msg.getBuffer() + msg.getBufferPosition());
    const size_t messageLength = (msg.getLength() - 6) / 4;
    size_t readPos = 0;
    const uint32_t k[] = {m_key[0], m_key[1], m_key[2], m_key[3]};
    while (readPos < messageLength) {
        uint32_t v0 = buffer[readPos], v1 = buffer[readPos + 1];
        uint32_t sum = 0xC6EF3720;

        for (int32_t i = 32; --i >= 0;) {
            v1 -= ((v0 << 4 ^ v0 >> 5) + v0) ^ (sum + k[(sum >> 11) & 3]);
            sum += delta;
            v0 -= ((v1 << 4 ^ v1 >> 5) + v1) ^ (sum + k[sum & 3]);
        }

        buffer[readPos++] = v0;
        buffer[readPos++] = v1;
    }

    int innerLength = msg.get<uint16_t>();
    if (innerLength > msg.getLength() - 8) {
        return false;
    }

    msg.setLength(innerLength);
    return true;
}

bool Protocol::RSA_decrypt(NetworkMessage& msg)
{
    if ((msg.getLength() - msg.getBufferPosition()) < 128) {
        return false;
    }

    g_RSA.decrypt(reinterpret_cast<char*>(msg.getBuffer()) + msg.getBufferPosition());
    return msg.getByte() == 0;
}

uint32_t Protocol::getIP() const
{
	if(Connection_ptr connection = getConnection())
		return connection->getIP();

	return 0;
}
