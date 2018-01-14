#include "evolution/type.h"
#include "evolution/prot.h"
#include "stdio.h"

#include "global.h"

void schedule ()
{
	if (proc_next->ticks > MAX_PROC_TICKS) {
		proc_next->ticks = 0;
		proc_next++;

		if (proc_next >= proc_table + NR_TASKS) {
			proc_next = proc_table;
		}
	}
}

void whoisnext ()
{
	puts(proc_next->p_name);
}
