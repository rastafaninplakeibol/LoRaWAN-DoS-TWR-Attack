#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include "./socket.h"

socket_t clients[256];
socket_t server;
socket_t sniffer, replayer;

void *receiver(void *args) {
	int ret;
	int index = *((int *)args);
	free(args);

	char buffer[512];
	printf("Started thread %d\n", index);
	while (1) {
		ret = m_recv(clients[index], buffer, 512);
		if (ret > 0) {
			if (!strncmp(buffer, "init", 4)) {
				char t[32], name[32];
				sscanf(buffer, "%s %s", t, name);
				if (!strncmp(name, "sniffer", 8)) {
					if (sniffer != 0) close(sniffer);
					sniffer = clients[index];
					printf("initialized sniffer\n");
				}
				else if (!strncmp(name, "replayer", 9)) {
					if (replayer != 0) close(replayer);
					replayer = clients[index];
					printf("initialized replayer\n");
				}
			}
			else if (replayer != 0) m_send(replayer, buffer, ret);
		}
	}
	pthread_exit(NULL);
}

int main(int argc, char const *argv[]) {
    int ret;
    int client_index = 0;
    pthread_t threads[2];
    server = create_server(2003);
    while (1) {
        clients[client_index] = m_accept(server);
        int *th_index = calloc(1, sizeof(int));
        *th_index = client_index;
        ret = pthread_create(&threads[client_index], NULL, receiver, (void *)th_index);
        client_index = (client_index + 1) % 256;
    }
    printf("Parent closing\n");
    return 0;
}
