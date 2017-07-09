#include "evolution/type.h"
#include "string.h"

void *memcpy (void *pdest, void *psrc, int count)
{
	u8_t *pcdest = (u8_t *) pdest;
	u8_t *pcsrc = (u8_t *) psrc;

	for (int i = 0; i < count; i++) {
		*pcdest = *pcsrc;
		pcdest++;
		pcsrc++;
	}	
}
