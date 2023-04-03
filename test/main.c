#include <stdio.h>
#include <aroma.h>

int main(int argc, char **argv){
	printf("hey there\n");
	libaroma_start();
	libaroma_sleep(2000);
	libaroma_end();
	return 0;
}