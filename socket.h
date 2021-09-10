#ifndef M_SOCKET_H
#define M_SOCKET_H

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>  // htons()
#include <netinet/in.h> // struct sockaddr_in
#include <sys/socket.h>

typedef int socket_t;
int MAX_CONNECTIONS = 30;
int DEBUG_VAR_SOCK = 0;

socket_t create_server(int port) {
	int ret;
	int sock;

    struct sockaddr_in addr = { 0 };

    sock = socket(AF_INET , SOCK_STREAM , 0);
    if(sock < 0) {if(DEBUG_VAR_SOCK)fprintf(stderr,"Errno on create_server.socket: %d, Error message: %s\n",errno,strerror(errno)); return -1;}

    int sockaddr_len = sizeof(struct sockaddr_in);

    addr.sin_addr.s_addr = INADDR_ANY; 
    addr.sin_family      = AF_INET;
    addr.sin_port        = htons(port);

    int reuseaddr_opt = 1;
    ret = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &reuseaddr_opt, sizeof(reuseaddr_opt));
    if(ret < 0) {if(DEBUG_VAR_SOCK)fprintf(stderr,"Errno on create_server.setsockopt: %d, Error message: %s\n",errno,strerror(errno)); return -1;}

    ret = bind(sock, (struct sockaddr*) &addr, sizeof(struct sockaddr_in));
    if(ret < 0) {if(DEBUG_VAR_SOCK)fprintf(stderr,"Errno on create_server.bind: %d, Error message: %s\n",errno,strerror(errno)); return -1;}

    ret = listen(sock, MAX_CONNECTIONS);
    if(ret < 0) {if(DEBUG_VAR_SOCK)fprintf(stderr,"Errno on create_server.listen: %d, Error message: %s\n",errno,strerror(errno)); return -1;}
    return sock;
}

socket_t create_client(const char* ip_address,int port) {
	int ret;
    int sock;
    struct sockaddr_in server_addr = {0};

    sock = socket(AF_INET, SOCK_STREAM, 0);
    if(sock < 0) {if(DEBUG_VAR_SOCK)fprintf(stderr,"Errno on create_client.socket: %d, Error message: %s\n",errno,strerror(errno)); return -1;}

    server_addr.sin_addr.s_addr = inet_addr(ip_address); //indirizzo ip del server
    server_addr.sin_family      = AF_INET;
    server_addr.sin_port        = htons(port);

    ret = connect(sock, (struct sockaddr*) &server_addr, sizeof(struct sockaddr_in));
    if(ret < 0) {if(DEBUG_VAR_SOCK)fprintf(stderr,"Errno on create_client.connect: %d, Error message: %s\n",errno,strerror(errno)); return -1;}
    return sock;
}

socket_t m_accept(int server_sock) {
    socket_t client_sock;
    struct sockaddr_in* client_addr = (struct sockaddr_in*) calloc(1, sizeof(struct sockaddr_in));
    int sockaddr_size = sizeof(struct sockaddr_in);

    client_sock = accept(server_sock, (struct sockaddr*) client_addr, (socklen_t*) &sockaddr_size);
    if(client_sock < 0) { if(DEBUG_VAR_SOCK) fprintf(stderr,"Errno on m_accept: %d, Error message: %s\n",errno,strerror(errno)); return -1;}
    return client_sock;
}

int m_recv(int sock,char* buf,int len) {
    int ret;
    while ((ret = recv(sock, buf, len, 0)) < 0 ) {
        if (errno == EINTR) continue;
        if(ret == -1) {
            if(DEBUG_VAR_SOCK) fprintf(stderr,"Errno on m_recv: %d, Error message: %s\n",errno,strerror(errno));
            return -1;
        }
    }
    buf[ret] = '\0';
    return ret;
}


int m_send(int sock,char* buf,int len) {
    int ret;
	while ( (ret = send(sock, buf, len, 0)) < 0) {
        if (errno == EINTR) continue;
        if(ret == -1) {
            if(DEBUG_VAR_SOCK) fprintf(stderr,"Errno on m_send: %d, Error message: %s\n",errno,strerror(errno));
            return -1;
        }
    }
	return ret;
}

void debug_on() {
    DEBUG_VAR_SOCK = 1;
}

void set_max_connections(int n) {
    MAX_CONNECTIONS = n;
}

/*
int ping_pong(int sock,char* msg,char* buf,int len) {
    sprintf(buf,msg);
    if(m_send(client,buffer,strlen(buffer)) < 0) return -1;
    if(m_recv(client,buffer,len) < 0) return -1;
    return 1;
}
*/

#endif