#include "evolution/type.h"
#include "stdio.h"
#include "string.h"

void debug_num (u32_t num)
{
	char buf[120];

	uitoa(num, buf, sizeof buf);
	puts(buf);
}
