/*    
 *  ------ Replayer (receives the message from the bridge server and replays it) --------
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

// If DEBUG_PRINTS is 1, USB prints will be done slowing the replay 
#define DEBUG_PRINTS 0

// Board hardware sockets
uint8_t lora_socket = SOCKET0;
uint8_t wifi_socket = SOCKET1;

// Wifi config
//char ESSID[] = "rastafan";
//char PASSW[] = "laschiava";

char ESSID[] = "Linkem_3A06E4";
char PASSW[] = "lhd3+cun";

// Remote server config
uint8_t remote_server_handle = 0;
char SERVER_HOST[]        = "rastafan.ddns.net";
char SERVER_LOCAL_PORT[]  = "3000";
char SERVER_REMOTE_PORT[] = "2003";

// Radio config
uint8_t power = 15;
uint32_t frequency;
char spreading_factor[] = "sf10";
char coding_rate[] = "4/5";
uint16_t bandwidth = 125;
char crc_mode[] = "on";

// Application logic variables
uint8_t error;
uint8_t status;
char* client_role = "replayer";
char buffer[100];

uint8_t radioModuleSetup() { 

  uint8_t status = 0;
  uint8_t e = 0;
  
  //////////////////////////////////////////////
  // 1. switch on
  //////////////////////////////////////////////

  e = LoRaWAN.ON(lora_socket);

  // Check status
  if (e == 0)
  {
    USB.println(F("1. Switch ON OK"));     
  }
  else 
  {
    USB.print(F("1. Switch ON error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));

    if (LoRaWAN._version == RN2483_MODULE || LoRaWAN._version == RN2903_IN_MODULE)
  {
    frequency = 868100000;
  }
  else if(LoRaWAN._version == RN2903_MODULE)
  {
    frequency = 902300000;
  }
  else if(LoRaWAN._version == RN2903_AS_MODULE)
  {
    frequency = 917300000;
  }

  //////////////////////////////////////////////
  // 2. Enable P2P mode
  //////////////////////////////////////////////

  e = LoRaWAN.macPause();

  // Check status
  if (e == 0)
  {
    USB.println(F("2. P2P mode enabled OK"));
  }
  else 
  {
    USB.print(F("2. Enable P2P mode error = "));
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 3. Set/Get Radio Power
  //////////////////////////////////////////////

  // Set power
  e = LoRaWAN.setRadioPower(power);

  // Check status
  if (e == 0)
  {
    USB.println(F("3.1. Set Radio Power OK"));
  }
  else 
  {
    USB.print(F("3.1. Set Radio Power error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get power
  e = LoRaWAN.getRadioPower();

  // Check status
  if (e == 0) 
  {
    USB.print(F("3.2. Get Radio Power OK. ")); 
    USB.print(F("Power: "));
    USB.println(LoRaWAN._radioPower);
  }
  else 
  {
    USB.print(F("3.2. Get Radio Power error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 4. Set/Get Radio Frequency
  //////////////////////////////////////////////

  // Set frequency
  e = LoRaWAN.setRadioFreq(frequency);

  // Check status
  if (e == 0)
  {
    USB.println(F("4.1. Set Radio Frequency OK"));
  }
  else 
  {
    USB.print(F("4.1. Set Radio Frequency error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get frequency
  e = LoRaWAN.getRadioFreq();

  // Check status
  if (e == 0) 
  {
    USB.print(F("4.2. Get Radio Frequency OK. ")); 
    USB.print(F("Frequency: "));
    USB.println(LoRaWAN._radioFreq);
  }
  else 
  {
    USB.print(F("4.2. Get Radio Frequency error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 5. Set/Get Radio Spreading Factor (SF)
  //////////////////////////////////////////////

  // Set SF
  e = LoRaWAN.setRadioSF(spreading_factor);

  // Check status
  if (e == 0)
  {
    USB.println(F("5.1. Set Radio SF OK"));
  }
  else 
  {
    USB.print(F("5.1. Set Radio SF error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get SF
  e = LoRaWAN.getRadioSF();

  // Check status
  if (e == 0) 
  {
    USB.print(F("5.2. Get Radio SF OK. ")); 
    USB.print(F("Spreading Factor: "));
    USB.println(LoRaWAN._radioSF);
  }
  else 
  {
    USB.print(F("5.2. Get Radio SF error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 6. Set/Get Radio Coding Rate (CR)
  //////////////////////////////////////////////

  // Set CR
  e = LoRaWAN.setRadioCR(coding_rate);

  // Check status
  if (e == 0)
  {
    USB.println(F("6.1. Set Radio CR OK"));
  }
  else 
  {
    USB.print(F("6.1. Set Radio CR error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CR
  e = LoRaWAN.getRadioCR();

  // Check status
  if (e == 0) 
  {
    USB.print(F("6.2. Get Radio CR OK. ")); 
    USB.print(F("Coding Rate: "));
    USB.println(LoRaWAN._radioCR);
  }
  else 
  {
    USB.print(F("6.2. Get Radio CR error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 7. Set/Get Radio Bandwidth (BW)
  //////////////////////////////////////////////

  // Set BW
  e = LoRaWAN.setRadioBW(bandwidth);

  // Check status
  if (e == 0)
  {
    USB.println(F("7.1. Set Radio BW OK"));
  }
  else 
  {
    USB.print(F("7.1. Set Radio BW error = "));
    USB.println(e, DEC);
  }

  // Get BW
  e = LoRaWAN.getRadioBW();

  // Check status
  if (e == 0) 
  {
    USB.print(F("7.2. Get Radio BW OK. ")); 
    USB.print(F("Bandwidth: "));
    USB.println(LoRaWAN._radioBW);
  }
  else 
  {
    USB.print(F("7.2. Get Radio BW error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));



  //////////////////////////////////////////////
  // 8. Set/Get Radio CRC mode
  //////////////////////////////////////////////

  // Set CRC
  e = LoRaWAN.setRadioCRC(crc_mode);

  // Check status
  if (e == 0)
  {
    USB.println(F("8.1. Set Radio CRC mode OK"));
  }
  else 
  {
    USB.print(F("8.1. Set Radio CRC mode error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CRC
  e = LoRaWAN.getRadioCRC();

  // Check status
  if (e == 0) 
  {
    USB.print(F("8.2. Get Radio CRC mode OK. ")); 
    USB.print(F("CRC status: "));
    USB.println(LoRaWAN._crcStatus);
  }
  else 
  {
    USB.print(F("8.2. Get Radio CRC mode error = ")); 
    USB.println(e, DEC);
    status = 1;
  }
  USB.println(F("-------------------------------------------------------"));


  return status;
}

void setup_wifi_parameters() {
  error = WIFI_PRO.ON(wifi_socket);

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
} 

uint8_t get_local_ip() {
  status =  WIFI_PRO.isConnected();

  // Check if module is connected
  if (status == true) {    
    USB.print(F("WiFi is connected OK"));
    USB.println(F("-------------------------------------")); 

    // 2.1. Get IP address
    error = WIFI_PRO.getIP();

    if (error == 0) {    
      USB.print(F("IP address: "));
      USB.println(WIFI_PRO._ip);
      return 0;
    }
    else {
      USB.println(F("getIP error"));
    }
  }
  else {
    USB.println(F("WiFi is not connected"));
  }
  return 1;
}

uint8_t setup_remote_connection() {
  // Open socket with remote server
  error = WIFI_PRO.setTCPclient(SERVER_HOST, SERVER_REMOTE_PORT, SERVER_LOCAL_PORT);
  if (error == 0)
  {
    remote_server_handle = WIFI_PRO._socket_handle;
    USB.print(F("3.1. Open TCP socket OK in handle: "));
    USB.println(remote_server_handle, DEC);
    return 0;
  }
  else
  {
    USB.println(F("3.1. Error opening socket"));
    WIFI_PRO.printErrorCode();
    return 1;
  }
}

void send_data_on_lora(char* data_to_send) {
  uint8_t err;
  USB.println(data_to_send);
  int len = strlen(data_to_send);
  for (uint8_t i = 0; i < len; i++) {
    if (((data_to_send[i] < '0') || (data_to_send[i] > '9')) &&
        ((data_to_send[i] < 'A') || (data_to_send[i] > 'F')) &&
        ((data_to_send[i] < 'a') || (data_to_send[i] > 'f'))) {
        data_to_send[i] = '\0';
        break;
    }
  }
  USB.println(strlen(data_to_send), DEC);
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

void receive_and_replay() {
  USB.println(F("Listen on WiFI:"));
  error = WIFI_PRO.receive(remote_server_handle, 6000000);

  if (error == 0)
  {
  	#if DEBUG_PRINTS >= 1
    USB.println(F("\n============== WIFi received ==============="));
    USB.print(F("Data: "));  
    USB.println( WIFI_PRO._buffer, WIFI_PRO._length);

    USB.print(F("Length: "));  
    USB.println( WIFI_PRO._length,DEC);
    USB.println(F("=============================================="));
    #endif

    // Data received, send with LoRa
    char data_to_send[WIFI_PRO._length];
    memcpy(data_to_send, WIFI_PRO._buffer, WIFI_PRO._length);
    send_data_on_lora(data_to_send);
  }
}

void send_internet_packet() {
  //USB.println(F("Listen to TCP socket:"));
  error = WIFI_PRO.send(remote_server_handle, buffer);
  if (error == 0) {
    USB.println(F("3.2. Send data1 OK"));   
  }
  else {
    USB.println(F("3.2. Error calling 'send1' function"));
    WIFI_PRO.printErrorCode();       
  }
}

void init_client_info() {
  sprintf(buffer, "init %s", client_role);
  send_internet_packet();
}

void setup() {
  USB.ON();
  // LoRa module setup
  error = radioModuleSetup();
  if (error == 0)
  {
    USB.println(F("Module configured OK"));     
  }
  else 
  {
    USB.println(F("Module configured ERROR"));     
  }

  // Wifi setup
  setup_wifi_parameters();
  while(get_local_ip()) { }
  setup_remote_connection();
  init_client_info();
}

void loop() {
  receive_and_replay();
}





