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
// along with this program. If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////

#ifndef __NETWORKMESSAGE__
#define __NETWORKMESSAGE__
#include "otsystem.h"
#include "const.h"
#include "fileloader.h"

class Item;
class Creature;
class Player;
struct Position;
class RSA;

class NetworkMessage
{
    public:
        enum { header_length = 2 };
        enum { crypto_length = 4 };
        enum { xtea_multiple = 8 };
        enum { max_body_length = NETWORKMESSAGE_MAXSIZE - header_length - crypto_length - xtea_multiple };
        enum { max_protocol_body_length = max_body_length - 10 };

        // constructor
        NetworkMessage() {
            reset();
        }

        void reset() {
            overrun = false;
            length = 0;
            position = 8;
        }

        // simply read functions for incoming message
        uint8_t getByte() {
            if (!canRead(1)) {
                return 0;
            }

            return buffer[position++];
        }

        uint8_t getPreviousByte() {
            return buffer[--position];
        }

        template<typename T>
        T get() {
            if (!canRead(sizeof(T))) {
                return 0;
            }

            T v = *reinterpret_cast<T*>(buffer + position);
            position += sizeof(T);
            return v;
        }

        std::string getString(uint16_t stringLen = 0);
        Position getPosition();

        // skips count unknown/unused bytes in an incoming message
        void skipBytes(int count) {
            position += count;
        }

        // simply write functions for outgoing message
        void addByte(uint8_t value) {
            if (!canAdd(1)) {
                return;
            }

            buffer[position++] = value;
            length++;
        }

        template<typename T>
        void add(T value) {
            if (!canAdd(sizeof(T))) {
                return;
            }

            *reinterpret_cast<T*>(buffer + position) = value;
            position += sizeof(T);
            length += sizeof(T);
        }

        void addBytes(const char* bytes, size_t size);
        void addPaddingBytes(size_t n);

        void addString(const std::string& value);
        void addString(const char* value);

        void addDouble(double value, uint8_t precision = 2);

        // write functions for complex types
        void addPosition(const Position& pos);
        void addItem(uint16_t id, uint8_t count);
        void addItem(const Item* item);
        void addItemId(uint16_t itemId);

        int32_t getLength() const {
            return length;
        }

        void setLength(int32_t newLength) {
            length = newLength;
        }

        int32_t getBufferPosition() const {
            return position;
        }

        void setBufferPosition(int32_t pos) {
            position = pos;
        }

        int32_t decodeHeader();

        bool isOverrun() const {
            return overrun;
        }

        uint8_t* getBuffer() {
            return buffer;
        }

        const uint8_t* getBuffer() const {
            return buffer;
        }

        uint8_t* getBodyBuffer() {
            position = 2;
            return buffer + header_length;
        }

        void serializeBuffer(char* msg) {

            int32_t oldPos = position;
            uint32_t pos = 0;
            while(canRead(1)){
                msg[pos] = buffer[position++];
                pos++;
            }

            overrun = false;
            position = oldPos;
        }

    protected:
        inline bool canAdd(size_t size) const {
            return (size + position) < max_body_length;
        }

        inline bool canRead(int32_t size) {
            if ((position + size) > (length + 8) || size >= (NETWORKMESSAGE_MAXSIZE - position)) {
                overrun = true;
                return false;
            }
            return true;
        }

        int32_t length;
        int32_t position;
        bool overrun;

        uint8_t buffer[NETWORKMESSAGE_MAXSIZE];
};

#endif
