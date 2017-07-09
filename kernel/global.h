#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#include "evolution/type.h"
#include "evolution/const.h"

#define EXTERN extern

#ifdef TABLE
	#undef EXTERN
	#define EXTERN
#endif

EXTERN descriptor_t gdt[GDT_SIZE];
EXTERN u8_t gdt_info[6];

#endif
