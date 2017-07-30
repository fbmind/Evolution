#include "evolution/type.h"
#include "evolution/prot.h"

void init_descriptor (descriptor_t *p_desc, u32_t base, u32_t limit, u16_t attr)
{
	p_desc->limit1 = limit & 0xFFFF;
	p_desc->base1 = base & 0xFFFF;
	p_desc->base2 = (base >> 16) & 0x00FF;
	p_desc->attr1 = attr & 0xFF;
	p_desc->attr2_limit2 = ((attr >> 8) && 0xF0) | ((limit >> 16) & 0x0F);
	p_desc->base3 = (base >> 24) & 0x00FF;
}
