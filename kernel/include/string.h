#ifndef _STRING_H_
#define _STRING_H_

#include "evolution/type.h"

void *memcpy (void *pdest, void *psrc, int count);
char *strcpy (char *dest, const char *src);
u32_t strlen (const char *str);
int uitoa (u32_t num, char *buf, u32_t len);

#endif
