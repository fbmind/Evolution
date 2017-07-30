#ifndef _PROT_H_
#define _PROT_H_

#define GDT_SIZE 128
#define LDT_SIZE 2 

typedef struct descriptor {
	u16_t limit1;
	u16_t base1;
	u8_t base2;
	u8_t attr1;
	u8_t attr2_limit2;
	u8_t base3;
} descriptor_t;

#define SELECTOR_DUMMY 0x00
#define SELECTOR_KERNEL_CODE 0x08
#define SELECTOR_KERNEL_DATA 0x10
#define SELECTOR_KERNEL_STACK 0x18
#define SELECTOR_TSS 0x0020
#define SELECTOR_LDT_FIRST 0x0028

#define INDEX_DUMMY 0x00
#define INDEX_KERNEL_CODE 0x01
#define INDEX_KERNEL_DATA 0x02
#define INDEX_KERNEL_STACK 0x03
#define INDEX_TSS 0x04
#define INDEX_LDT_FIRST 0x05

#define LDT_ATTR 0x4082
#define TSS_ATTR 0x4089

void init_descriptor (descriptor_t *p_desc, u32_t base, u32_t limit, u16_t attr);

#endif
