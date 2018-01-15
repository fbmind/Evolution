#include "global.h"
#include "string.h"
#include "stdio.h"

void init_8259a();

void cstart ()
{
	u16_t *plimit = (u16_t *) gdt_info;
	u32_t *pbase = (u32_t *) (gdt_info + 2);

	puts("Init gdt");
	memcpy((void *) &gdt, (void *) *pbase, *plimit + 1);

	*pbase = (u32_t) &gdt;
	*plimit = sizeof gdt - 1;

	/* 这段代码有什么用呢？忘了，好像是为了查看 gdt_info 的内容。 */
	u8_t *t = (u8_t *) 0x7e00;
	u8_t *f = gdt_info;

	for (int i = 0; i < 8; i++) {
		*t = *f;
		t++;
		f++;
	}

	puts("Init idt");
	init_idt();

	init_8259a();
}
