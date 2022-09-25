//
//  NDSCartridge.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/9/22.
//

#ifndef NDSCartridge_h
#define NDSCartridge_h

/*!
    \brief the NDS file header format
    See gbatek for more info.
*/
typedef struct {
    char gameTitle[12];            //!< 12 characters for the game title.
    char gameCode[4];            //!< 4 characters for the game code.
    char makercode[2];            //!< identifies the (commercial) developer.
    uint8_t unitCode;                //!< identifies the required hardware.
    uint8_t deviceType;                //!< type of device in the game card
    uint8_t deviceSize;                //!< capacity of the device (1 << n Mbit)
    uint8_t reserved1[9];
    uint8_t romversion;                //!< version of the ROM.
    uint8_t flags;                    //!< bit 2: auto-boot flag.

    uint32_t arm9romOffset;            //!< offset of the arm9 binary in the nds file.
    uint32_t arm9executeAddress;        //!< adress that should be executed after the binary has been copied.
    uint32_t arm9destination;        //!< destination address to where the arm9 binary should be copied.
    uint32_t arm9binarySize;            //!< size of the arm9 binary.

    uint32_t arm7romOffset;            //!< offset of the arm7 binary in the nds file.
    uint32_t arm7executeAddress;        //!< adress that should be executed after the binary has been copied.
    uint32_t arm7destination;        //!< destination address to where the arm7 binary should be copied.
    uint32_t arm7binarySize;            //!< size of the arm7 binary.

    uint32_t filenameOffset;            //!< File Name Table (FNT) offset.
    uint32_t filenameSize;            //!< File Name Table (FNT) size.
    uint32_t fatOffset;                //!< File Allocation Table (FAT) offset.
    uint32_t fatSize;                //!< File Allocation Table (FAT) size.

    uint32_t arm9overlaySource;        //!< File arm9 overlay offset.
    uint32_t arm9overlaySize;        //!< File arm9 overlay size.
    uint32_t arm7overlaySource;        //!< File arm7 overlay offset.
    uint32_t arm7overlaySize;        //!< File arm7 overlay size.

    uint32_t cardControl13;            //!< Port 40001A4h setting for normal commands (used in modes 1 and 3)
    uint32_t cardControlBF;            //!< Port 40001A4h setting for KEY1 commands (used in mode 2)
    uint32_t bannerOffset;            //!< offset to the banner with icon and titles etc.

    uint16 secureCRC16;            //!< Secure Area Checksum, CRC-16.

    uint16 readTimeout;            //!< Secure Area Loading Timeout.

    uint32_t unknownRAM1;            //!< ARM9 Auto Load List RAM Address (?)
    uint32_t unknownRAM2;            //!< ARM7 Auto Load List RAM Address (?)

    uint32_t bfPrime1;                //!< Secure Area Disable part 1.
    uint32_t bfPrime2;                //!< Secure Area Disable part 2.
    uint32_t romSize;                //!< total size of the ROM.

    uint32_t headerSize;                //!< ROM header size.
    uint32_t zeros88[3];
    uint16 nandRomEnd;                //!< ROM region end for NAND games.
    uint16 nandRwStart;            //!< RW region start for NAND games.
    uint32_t zeros98[10];
    uint8_t gbaLogo[156];            //!< Nintendo logo needed for booting the game.
    uint16 logoCRC16;                //!< Nintendo Logo Checksum, CRC-16.
    uint16 headerCRC16;            //!< header checksum, CRC-16.

    uint32_t debugRomSource;            //!< debug ROM offset.
    uint32_t debugRomSize;            //!< debug size.
    uint32_t debugRomDestination;    //!< debug RAM destination.
    uint32_t offset_0x16C;            //reserved?

    uint8_t zero[0x40];
    uint32_t region;
    uint32_t accessControl;
    uint32_t arm7SCFGSettings;
    uint16 dsi_unk1;
    uint8_t dsi_unk2;
    uint8_t dsi_flags;

    uint32_t arm9iromOffset;            //!< offset of the arm9 binary in the nds file.
    uint32_t arm9iexecuteAddress;
    uint32_t arm9idestination;        //!< destination address to where the arm9 binary should be copied.
    uint32_t arm9ibinarySize;        //!< size of the arm9 binary.

    uint32_t arm7iromOffset;            //!< offset of the arm7 binary in the nds file.
    uint32_t deviceListDestination;
    uint32_t arm7idestination;        //!< destination address to where the arm7 binary should be copied.
    uint32_t arm7ibinarySize;        //!< size of the arm7 binary.

    uint8_t zero2[0x20];

    // 0x200
    // TODO: More DSi-specific fields.
    uint32_t dsi1[0x10/4];
    uint32_t twlRomSize;
    uint32_t dsi_unk3;
    uint32_t dsi_unk4;
    uint32_t dsi_unk5;
    uint8_t dsi2[0x10];
    uint32_t dsi_tid;
    uint32_t dsi_tid2;
    uint32_t pubSavSize;
    uint32_t prvSavSize;
    uint8_t dsi3[0x174];
} sNDSHeaderExt;

/*!
    \brief the NDS banner format.
    See gbatek for more information.
*/
typedef struct {
    uint16_t version;        //!< version of the banner.
    uint16_t crc[4];        //!< CRC-16s of the banner.
    uint8_t reserved[22];
    uint8_t icon[512];        //!< 32*32 icon of the game with 4 bit per pixel.
    uint16_t palette[16];    //!< the palette of the icon.
    uint16_t titles[8][128];    //!< title of the game in 8 different languages.

    // [0xA40] Reserved space, possibly for other titles.
    uint8_t reserved2[0x800];

    // DSi-specific.
    uint8_t dsi_icon[8][512];    //!< DSi animated icon frame data.
    uint16_t dsi_palette[8][16];    //!< Palette for each DSi icon frame.
    uint16_t dsi_seq[64];    //!< DSi animated icon sequence.
} sNDSBannerExt;

#endif /* NDSCartridge_h */
