#ifndef _TYPE_H_
#define _TYPE_H_

typedef unsigned char u8_t;
typedef unsigned short u16_t;
typedef unsigned int u32_t;

typedef struct descriptor {
	u16_t limit1;
	u16_t base1;
	u8_t base2;
	u8_t type1;
	u8_t type2_limit2;
	u8_t base3;
} descriptor_t;

#endif
