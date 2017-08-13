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

char *strcpy (char *dest, const char *src)
{
	for (; *src != '\0'; src++, dest++) {
		*dest = *src;
	}
	*dest = '\0';

	return dest;
}

u32_t strlen (const char *str)
{
	const char *end;

	for (end = str; *end != '\0'; end++) {
	}

	return end - str;
}

int uitoa (u32_t num, char *buf, u32_t len)
{
	u8_t m;
	int count = 0;
	char tmp[len - 1];
	char *end;

	do {
		m = num % 10U;
		tmp[count++] = m + 0x30;

		num = num / 10U;
	} while (num > 0 && count < len - 1);
	tmp[count] = '\0';


	for (end = tmp + count - 1; end >= tmp; end--, buf++) {
		*buf = *end;
	}
	*buf = '\0';

	return 0;
}
