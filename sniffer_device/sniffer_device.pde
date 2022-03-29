/*  
 *  ------ Sniffer device (malicious device that eavesdrop frames and send them to the bridge server) -------- 
 *  
 *  This program is free software: you can redistribute it and/or modify  
 *  it under the terms of the GNU General Public License as published by  
 *  the Free Software Foundation, either version 3 of the License, or  
 *  (at your option) any later version.  
 *   
 *  This program is distributed in the hope that it will be useful,  
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of  
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
 *  GNU General Public License for more details.  
 *   
 *  You should have received a copy of the GNU General Public License  
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *  
 *  Version:           1.0
 *  Design:            Pierluigi Locatelli, Pietro Spadaccino
 *  Implementation:    Pierluigi Locatelli, Pietro Spadaccino
 */


#include <WaspWIFI_PRO.h>
#include <WaspLoRaWAN.h>

////////////   WIFI SETTINGS   /////////////////
uint8_t tcp_socket = SOCKET1;
uint8_t remote_server_handle = 0;
uint8_t local_pc_handle = 0;


char ESSID[] = "Vodafone-C02130189";
char PASSW[] = "HNZXt2zfrr7CRXmJ";

char buffer[100];


//REMOTE_SERVER_INFO
char HOST[]        = "rastafan.ddns.net";
char REMOTE_PORT[] = "4200";
char LOCAL_PORT[]  = "8000";
///////////////////////////////////////




////////////   LORA SETTINGS   /////////////////
uint8_t lora_socket = SOCKET0;

uint8_t power = 15;
uint32_t frequency;
char spreading_factor[] = "sf7";
char sf_12[] = "sf12";
char sf_7[] = "sf7";

char coding_rate[] = "4/5";
uint16_t bandwidth = 125;
char crc_mode[] = "on";

// Device parameters for Back-End registration
char DEVICE_EUI[]  = "###############";
char APP_EUI[] = "################";
char APP_KEY[] = "################################";

uint8_t PORT = 3;
////////////////////////////////////////////////////////////


// define variables
char client_role[] = "sniffer";
uint8_t error;
uint8_t error_config;
uint8_t status;
unsigned long previous;
uint8_t wifi_connected = 0;
int num_packets_sent = 0;
int NUM_PACKETS_TO_SEND = 1;

int last_packet_id = -1;


//////////////// LORA FUNCTIONS /////////////////////////
void lora_radio_setup() { 
  uint8_t status = 0;
  uint8_t e = 0;
  
  // 1. switch on
  e = LoRaWAN.ON(lora_socket);

  // Check status
  if (e == 0) {
    USB.println(F("1. Switch ON OK"));     
  }
  else {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

  if (LoRaWAN._version == RN2483_MODULE || LoRaWAN._version == RN2903_IN_MODULE) {
    frequency = 868100000;
    //frequency = 868300000;
    //frequency = 868500000;
    //frequency = 869525000;
  }
  else if(LoRaWAN._version == RN2903_MODULE) {
    frequency = 902300000;
  }
  else if(LoRaWAN._version == RN2903_AS_MODULE) {
    frequency = 917300000;
  }

  // 2. Enable P2P mode
  e = LoRaWAN.macPause();

  // Check status
  if (e == 0) {
    USB.println(F("2. P2P mode enabled OK"));
  }
  else  {
    USB.print(F("2. Enable P2P mode error = "));
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));
  
  //3. Set/Get Radio Power
  // Set power
  e = LoRaWAN.setRadioPower(power);

  // Check status
  if (e == 0) {
    USB.println(F("3.1. Set Radio Power OK"));
  }
  else  {
    USB.print(F("3.1. Set Radio Power error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get power
  e = LoRaWAN.getRadioPower();

  // Check status
  if (e == 0) {
    USB.print(F("3.2. Get Radio Power OK. ")); 
    USB.print(F("Power: "));
    USB.println(LoRaWAN._radioPower);
  }
  else {
    USB.print(F("3.2. Get Radio Power error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

  // 4. Set/Get Radio Frequency  
  // Set frequency
  e = LoRaWAN.setRadioFreq(frequency);

  // Check status
  if (e == 0) {
    USB.println(F("4.1. Set Radio Frequency OK"));
  }
  else {
    USB.print(F("4.1. Set Radio Frequency error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get frequency
  e = LoRaWAN.getRadioFreq();

  // Check status
  if (e == 0) {
    USB.print(F("4.2. Get Radio Frequency OK. ")); 
    USB.print(F("Frequency: "));
    USB.println(LoRaWAN._radioFreq);
  }
  else {
    USB.print(F("4.2. Get Radio Frequency error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

  // 5. Set/Get Radio Spreading Factor (SF)  
  // Set SF
  e = LoRaWAN.setRadioSF(spreading_factor);

  // Check status
  if (e == 0) {
    USB.println(F("5.1. Set Radio SF OK"));
  }
  else {
    USB.print(F("5.1. Set Radio SF error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get SF
  e = LoRaWAN.getRadioSF();

  // Check status
  if (e == 0) {
    USB.print(F("5.2. Get Radio SF OK. ")); 
    USB.print(F("Spreading Factor: "));
    USB.println(LoRaWAN._radioSF);
  }
  else {
    USB.print(F("5.2. Get Radio SF error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

  // 6. Set/Get Radio Coding Rate (CR)  
  // Set CR
  e = LoRaWAN.setRadioCR(coding_rate);

  // Check status
  if (e == 0) {
    USB.println(F("6.1. Set Radio CR OK"));
  }
  else {
    USB.print(F("6.1. Set Radio CR error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CR
  e = LoRaWAN.getRadioCR();

  // Check status
  if (e == 0) {
    USB.print(F("6.2. Get Radio CR OK. ")); 
    USB.print(F("Coding Rate: "));
    USB.println(LoRaWAN._radioCR);
  }
  else {
    USB.print(F("6.2. Get Radio CR error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

  // 7. Set/Get Radio Bandwidth (BW)
  // Set BW
  e = LoRaWAN.setRadioBW(bandwidth);

  // Check status
  if (e == 0) {
    USB.println(F("7.1. Set Radio BW OK"));
  }
  else {
    USB.print(F("7.1. Set Radio BW error = "));
    USB.println(e, DEC);
  }

  // Get BW
  e = LoRaWAN.getRadioBW();

  // Check status
  if (e == 0) {
    USB.print(F("7.2. Get Radio BW OK. ")); 
    USB.print(F("Bandwidth: "));
    USB.println(LoRaWAN._radioBW);
  }
  else {
    USB.print(F("7.2. Get Radio BW error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

  // 8. Set/Get Radio CRC mode
  // Set CRC
  e = LoRaWAN.setRadioCRC(crc_mode);
  //
  //// Check status
  if (e == 0) {
    USB.println(F("8.1. Set Radio CRC mode OK"));
  }
  else {
    USB.print(F("8.1. Set Radio CRC mode error = "));
    USB.println(e, DEC);
    status = 1;
  }
  //
  //// Get CRC
  e = LoRaWAN.getRadioCRC();
  //
  //// Check status
  if (e == 0) {
    USB.print(F("8.2. Get Radio CRC mode OK. ")); 
    USB.print(F("CRC status: "));
    USB.println(LoRaWAN._crcStatus);
  }
  else {
    USB.print(F("8.2. Get Radio CRC mode error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));
}


void lora_join_otaa() {
  
  // 1. Switch on
  error = LoRaWAN.ON(lora_socket);

  // Check status
  if( error == 0 ) {
    USB.println(F("1. Switch ON OK"));     
  }
  else {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(error, DEC);
    error_config = 1;
  }
  
  // 2. Change data rate
  error = LoRaWAN.setDataRate(5);

  // Check status
  if( error == 0 ) {
    USB.println(F("2. Data rate set OK"));     
  }
  else {
    USB.print(F("2. Data rate set error= ")); 
    USB.println(error, DEC);
     error_config = 2;
  }

  // 3. Set Device EUI
  error = LoRaWAN.setDeviceEUI(DEVICE_EUI);

  // Check status
  if( error == 0 ) {
    USB.println(F("3. Device EUI set OK"));     
  }
  else {
    USB.print(F("3. Device EUI set error = ")); 
    USB.println(error, DEC);
    error_config = 3;
  }

  // 4. Set Application EUI
  error = LoRaWAN.setAppEUI(APP_EUI);

  // Check status
  if( error == 0 ) {
    USB.println(F("4. Application EUI set OK"));     
  }
  else {
    USB.print(F("4. Application EUI set error = ")); 
    USB.println(error, DEC);
    error_config = 4;
  }

  // 5. Set Application Session Key
  error = LoRaWAN.setAppKey(APP_KEY);

  // Check status
  if( error == 0 ) {
    USB.println(F("5. Application Key set OK"));     
  }
  else {
    USB.print(F("5. Application Key set error = ")); 
    USB.println(error, DEC);
    error_config = 5;
  }

  // 6. Join OTAA to negotiate keys with the server
  error = LoRaWAN.joinOTAA();

  // Check status
  if( error == 0 ) {
    USB.println(F("6. Join network OK"));         
  }
  else {
    USB.print(F("6. Join network error = ")); 
    USB.println(error, DEC);
    error_config = 6;
  }

  // 7. Save configuration
  error = LoRaWAN.saveConfig();

  // Check status
  if( error == 0 ) {
    USB.println(F("7. Save configuration OK"));     
  }
  else {
    USB.print(F("7. Save configuration error = ")); 
    USB.println(error, DEC);
    error_config = 7;
  }
}

void send_data_on_lora(char* data_to_send) {
  uint8_t err;
  err = LoRaWAN.sendRadio(data_to_send);

  // Check status
  if (err == 0) {
    USB.println(F("--> Packet sent OK"));
  }
  else {
    USB.print(F("Error sending packets. error = "));  
    USB.println(err, DEC);   
  }
}

int receive_data_on_lora(int time) {
  error = LoRaWAN.receiveRadio(time);

  //int packetID;
  // check to avoid multipath message repetitions
  //sscanf((const char*) LoRaWAN._buffer, "%d", &packetID);
  //if(packetID <= last_packet_id) return 0;
  //else last_packet_id = packetID;
  // Check status
  previous = millis();
  if (error == 0)
  {
    USB.println(F("--> Packet received"));
    USB.print(F("packet: "));
    USB.println((char*) LoRaWAN._buffer);
    USB.print(F("length: "));
    USB.println(LoRaWAN._length);

    memcpy(buffer, LoRaWAN._buffer, 46);
    
    //USB.print(F("length: "));
    //USB.println(LoRaWAN._length);
    //    
    //// get SNR 
    //LoRaWAN.getRadioSNR();
    //USB.print(F("SNR: "));
    //USB.println(LoRaWAN._radioSNR);
    return 1;
  }
  else 
  {
    // error code
    //  1: error
    //  2: no incoming packet
    USB.print(F("Error waiting for packets. error = "));  
    USB.println(error, DEC);
    return 0;
  }  
}

int send_join_accept() {
  LoRaWAN.setRadioFreq(869525000);
  LoRaWAN.setRadioSF("sf12");

  unsigned long passed = millis() - previous;

  delay(5000 - passed);

  for (uint8_t i = 0; i < 5; i++) {
    send_data_on_lora("200D699A08E0A6F09DC725CB490541657C6E42E5FAA903919FB682B655C63A67C5");
  }
  USB.println(F("Inviati"));
  LoRaWAN.setRadioFreq(frequency);
  LoRaWAN.setRadioSF(spreading_factor);
}

int recv_join_accept() {
  LoRaWAN.setRadioFreq(869525000);
  LoRaWAN.setRadioSF("sf12");

  uint8_t res = receive_data_on_lora(20000);
  if(res) {
    USB.println(F("Inviati"));
  }
  else {
    USB.println(F("Niente"));
  }

  LoRaWAN.setRadioFreq(frequency);
  LoRaWAN.setRadioSF(spreading_factor);
}

//////////////// WIFI FUNCTIONS /////////////////////////
void setup_wifi_parameters() {
  error = WIFI_PRO.ON(tcp_socket);

  if (error == 0) {    
    USB.println(F("1. WiFi switched ON"));
  }
  else {
    USB.println(F("1. WiFi did not initialize correctly"));
  }

  // 2. Reset to default values
  error = WIFI_PRO.resetValues();

  if (error == 0) {    
    USB.println(F("2. WiFi reset to default"));
  }
  else {
    USB.println(F("2. WiFi reset to default ERROR"));
  }

  // 3. Set ESSID
  error = WIFI_PRO.setESSID(ESSID);

  if (error == 0) {    
    USB.println(F("3. WiFi set ESSID OK"));
  }
  else {
    USB.println(F("3. WiFi set ESSID ERROR"));
  }

  // 4. Set password key (It takes a while to generate the key)
  // Authentication modes:
  //    OPEN: no security
  //    WEP64: WEP 64
  //    WEP128: WEP 128
  //    WPA: WPA-PSK with TKIP encryption
  //    WPA2: WPA2-PSK with TKIP or AES encryption
  error = WIFI_PRO.setPassword(WPA2, PASSW);

  if (error == 0) {    
    USB.println(F("4. WiFi set AUTHKEY OK"));
  }
  else {
    USB.println(F("4. WiFi set AUTHKEY ERROR"));
  }


  // 5. Software Reset 
  // Parameters take effect following either a 
  // hardware or software reset
  error = WIFI_PRO.softReset();

  if (error == 0) {    
    USB.println(F("5. WiFi softReset OK"));
  }
  else {
    USB.println(F("5. WiFi softReset ERROR"));
  }
  // get current time
  previous = millis();
} 

void get_local_ip() {
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true) {    
    USB.print(F("WiFi is connected OK"));
    USB.println(F("-------------------------------------")); 
    wifi_connected = 1;  

    // 2.1. Get IP address
    error = WIFI_PRO.getIP();

    if (error == 0) {    
      USB.print(F("IP address: "));
      USB.println(WIFI_PRO._ip);   
    }
    else {
      USB.println(F("getIP error"));
    }
  }
  else {
    USB.print(F("WiFi is not connected"));
  }
}

void send_internet_packet(uint8_t remote) {
  //USB.println(F("Listen to TCP socket:"));
  if(remote) {
    error = WIFI_PRO.send(remote_server_handle, buffer);
    if (error == 0) {
      USB.println(F("3.2. Send data1 OK"));   
    }
    else {
      USB.println(F("3.2. Error calling 'send1' function"));
      WIFI_PRO.printErrorCode();       
    }
  }
  else {
    error = WIFI_PRO.send(local_pc_handle, "stop");
    if (error == 0) {
      USB.println(F("3.2. Send data2 OK"));   
    }
    else {
      USB.println(F("3.2. Error calling 'send2' function"));
      WIFI_PRO.printErrorCode();       
    }
  }
}

void receive_internet_packet() {
  ////////////////////////////////////////////////
  // 3.3. Wait for answer from server
  ////////////////////////////////////////////////
  USB.println(F("Listen to TCP socket:"));
  error = WIFI_PRO.receive(remote_server_handle, 60000);

  // check answer  
  if (error == 0)
  {
    USB.println(F("\n========================================"));
    USB.print(F("Data: "));  
    USB.println( WIFI_PRO._buffer, WIFI_PRO._length);

    USB.print(F("Length: "));  
    USB.println( WIFI_PRO._length,DEC);
    USB.println(F("========================================"));

    // Data received, send with LoRa
    char data_to_send[WIFI_PRO._length];
    memcpy(data_to_send, WIFI_PRO._buffer, WIFI_PRO._length);
    send_data_on_lora(data_to_send);
    if(num_packets_sent == NUM_PACKETS_TO_SEND - 1) {
      ////////////////////////////////////////////////
      // 3.4. close socket
      ////////////////////////////////////////////////
      error = WIFI_PRO.closeSocket(remote_server_handle);
  
      // check response
      if (error == 0)
      {
        USB.println(F("3.3. Close socket OK"));
      }
      else
      {
        USB.println(F("3.3. Error calling 'closeSocket' function"));
        WIFI_PRO.printErrorCode();
      }
  
      WIFI_PRO.OFF(tcp_socket); 
      delay(10000000);
    }
    else num_packets_sent++;
  }
}

void setup_tcp_client() {
  ////////////////////////////////////////////////
  // 3.1. Open TCP socket
  ////////////////////////////////////////////////
  //error = WIFI_PRO.setUDP(HOST, REMOTE_PORT, LOCAL_PORT);
  error = WIFI_PRO.setTCPclient(HOST, REMOTE_PORT, LOCAL_PORT);

  // check response
  if (error == 0)
  {
    // get socket handle (from 0 to 9)
    remote_server_handle = WIFI_PRO._socket_handle;

    USB.print(F("3.1. Open TCP socket OK in handle: "));
    USB.println(remote_server_handle, DEC);
  }
  else
  {
    USB.println(F("3.1. Error calling 'setTCPclient' function"));
    WIFI_PRO.printErrorCode();
  }
}

void init_client_info() {
  sprintf(buffer, "init %s", client_role);
  send_internet_packet(1);
}

//////////////// SETUP ////////////////////

/*
void setup() {
  USB.println(F("Started!"));
  previous = millis();
  USB.println(previous, DEC);   
  setup_wifi_parameters();
  while(!wifi_connected) {
    get_local_ip();  
  }
  lora_radio_setup();
  setup_tcp_client();
  init_client_info();

  previous = millis();
  USB.println(previous, DEC);   
}

void loop() {
  uint8_t res = receive_data_on_lora(60000);
  uint8_t e;
  uint8_t status;
  if(res) {
    send_internet_packet(1);
    USB.println(F("Inviato!"));
  }
}*/

void setup()
{
  USB.ON();
  pinMode(DIGITAL2, INPUT);
  pinMode(DIGITAL3, OUTPUT);
  pinMode(DIGITAL4, OUTPUT);
  pinMode(DIGITAL5, OUTPUT);

  digitalWrite(DIGITAL4, HIGH);

  USB.println(F("Started!"));
  previous = millis();
  USB.println(previous, DEC);   
  setup_wifi_parameters();
  while(!wifi_connected) {
    get_local_ip();  
  }
  lora_radio_setup();
  setup_tcp_client();
  init_client_info();

  previous = millis();
  USB.println(previous, DEC);
  memset(buffer,0,100);
}

int lighted = false;

void loop()
{
  if (digitalRead(DIGITAL2)) {
      digitalWrite(DIGITAL3, HIGH);
      delay(500);
      uint8_t res = receive_data_on_lora(20000);
      uint8_t e;
      uint8_t status;
      digitalWrite(DIGITAL3, LOW);
      if(res) {
        send_internet_packet(1);
        USB.println(F("Inviato!"));
        digitalWrite(DIGITAL5, HIGH);
        delay(500);
        digitalWrite(DIGITAL5, LOW);

      }
      else {
        USB.println(F("Ricevuto nada"));
      }
      digitalWrite(DIGITAL3, LOW);
  }
  delay(50);
}
