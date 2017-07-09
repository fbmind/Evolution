#include "global.h"
#include "string.h"

void cstart () {
	u16_t *plimit = (u16_t *) gdt_info;
	u32_t *pbase = (u32_t *) (gdt_info + 2);

	memcpy((void *) &gdt, (void *) *pbase, *plimit + 1);

	*pbase = (u32_t) &gdt;
	*plimit = sizeof gdt - 1;

	u8_t *t = (u8_t *) 0x7e00;
	u8_t *f = gdt_info;

	for (int i = 0; i < 8; i++) {
		*t = *f;
		t++;
		f++;
	}
}
