#include "global.h"
#include "stdio.h"

int puts(const char *s)
{
	u8_t *write_pos;
	u8_t write;

	while (*s != '\0') {
		write = *s++;

		write_pos = (u8_t *) VIDEO_START + tty_pos * 2;
		*write_pos = write;
		*(write_pos + 1) = 0x07;

		if (++tty_pos >= 25 * 80) {
			tty_pos = 0;
		}
	}
}
