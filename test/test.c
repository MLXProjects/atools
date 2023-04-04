#include <stdio.h>
#include <aroma.h>

void winmain(){
	LIBAROMA_WINDOWP win = libaroma_window(0,0,0,0,0);
	if (!win){
		printf("win failed\n");
		return;
	}
	LIBAROMA_CONTROLP ctl = libaroma_ctl_progress(win, 0, 0, 0, 48, 48, LIBAROMA_CTL_PROGRESS_INDETERMINATE|LIBAROMA_CTL_PROGRESS_CIRCULAR, 0, 0);
	if (!ctl){
		printf("ctl failed\n");
		return;
	}
	libaroma_window_show(win);
	LIBAROMA_MSG msg={0};
	do {
		libaroma_window_pool(win, &msg);
		if (msg.msg==LIBAROMA_MSG_EXIT || msg.msg==LIBAROMA_MSG_KEY_POWER) break;
	} while(win->onpool);
	printf("bye\n");
	libaroma_window_free(win);
}

int main(int argc, char **argv){
	libaroma_start();
	winmain();
	libaroma_end();
	return 0;
}