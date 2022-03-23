/*  
 *  ------ Benign device (simple device that loops on join requests) -------- 
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

#define RED_ON      digitalWrite(DIGITAL2, HIGH);
#define RED_OFF     digitalWrite(DIGITAL2, LOW);
#define GREEN_ON    digitalWrite(DIGITAL4, HIGH);
#define GREEN_OFF   digitalWrite(DIGITAL4, LOW);
#define YELLOW_ON   digitalWrite(DIGITAL6, HIGH);
#define YELLOW_OFF  digitalWrite(DIGITAL6, LOW);
#define BLUE_ON     digitalWrite(DIGITAL8, HIGH);
#define BLUE_OFF    digitalWrite(DIGITAL8, LOW);

#define BUZZER_ON   analogWrite(DIGITAL1, 254);
#define BUZZER_OFF  analogWrite(DIGITAL1, LOW);

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
char APP_EUI[] = "###############";
char APP_KEY[] = "##############################";

uint8_t PORT = 3;
////////////////////////////////////////////////////////////

// define variables
uint8_t error;
uint8_t error_config;
uint8_t status;
unsigned long previous;
uint8_t wifi_connected = 0;
int num_packets_sent = 0;
int NUM_PACKETS_TO_SEND = 1;
uint8_t initialized = 0;
char buffer[1024];

//////////////// LORA FUNCTIONS /////////////////////////

void setIQInverted(char *inv)
{
  uint8_t error = 0;
  error = LoRaWAN.setIQInverted(inv);
  if (error == 0)
  {
    USB.println(F("--> set iq inverted ok"));
  }
  else
  {
    USB.print(F("Error setting iq inverted. error = "));
    USB.println(error, DEC);
  }
  // check that was set:
  error = LoRaWAN.getIQInverted();
  if (error == 0)
  {
    USB.println(F("--> get iq inverted ok"));
  }
  else
  {
    USB.print(F("Error getting iq inverted. error = "));
    USB.println(error, DEC);
  }
}


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

  // Check status
  if (e == 0) {
    USB.println(F("8.1. Set Radio CRC mode OK"));
  }
  else {
    USB.print(F("8.1. Set Radio CRC mode error = "));
    USB.println(e, DEC);
    status = 1;
  }

  // Get CRC
  e = LoRaWAN.getRadioCRC();

  // Check status
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
  if(!initialized) {
    error = LoRaWAN.ON(lora_socket);
    // Check status
    if( error == 0 ) {
      USB.println(F("1. Switch ON OK"));
      initialized = 1;
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
  }
  previous = millis();
  // 6. Join OTAA to negotiate keys with the server
  error = LoRaWAN.joinOTAA();
  USB.println(millis() - previous, DEC);

  // Check status
  if( error == 0 ) {
    USB.println(F("6. Join network OK"));
    // 7. Save configuration
    error = LoRaWAN.saveConfig();

    // Check status
    if (error == 0)
    {
      USB.println(F("7. Save configuration OK"));
    }
    else
    {
      USB.print(F("7. Save configuration error = "));
      USB.println(error, DEC);
      error_config = 7;
    }
  }
  else {
    USB.print(F("6. Join network error = ")); 
    USB.println(error, DEC);
    error_config = 6;
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

int receive_data_on_lora() {
  error = LoRaWAN.receiveRadio(10000);
  YELLOW_OFF
  // Check status
  if (error == 0)
  {
    GREEN_ON
    BUZZER_ON
    USB.println(F("--> Packet received"));
    USB.print(F("packet: "));
    USB.println((char*) LoRaWAN._buffer);
    USB.print(F("length: "));
    USB.println(LoRaWAN._length);
        
    // get SNR 
    LoRaWAN.getRadioSNR();
    USB.print(F("SNR: "));
    USB.println(LoRaWAN._radioSNR);
    memcpy(buffer, LoRaWAN._buffer, 100);
    delay(500);
    BUZZER_OFF
    return 1;
  }
  else 
  {
    // error code
    //  1: error
    //  2: no incoming packet
    RED_ON
    BUZZER_ON
    delay(100);
    BUZZER_OFF
    delay(100);
    BUZZER_ON
    delay(100);
    BUZZER_OFF
    delay(100);
    BUZZER_ON
    delay(100);
    BUZZER_OFF
    delay(100);
    BUZZER_ON
    delay(100);
    BUZZER_OFF
    USB.print(F("Error waiting for packets. error = "));  
    USB.println(error, DEC);
    return 0;
  }  
}

//////////////// SETUP ////////////////////
void setup() {
  pinMode(DIGITAL2,OUTPUT);
  pinMode(DIGITAL4,OUTPUT);
  pinMode(DIGITAL6,OUTPUT);
  pinMode(DIGITAL8,OUTPUT);
  pinMode(DIGITAL1,OUTPUT);

  USB.println(F("Started!"));
  BLUE_ON
  previous = millis();
  USB.println(previous, DEC);   

  lora_radio_setup();

  previous = millis();
  USB.println(previous, DEC);   
  delay(5000);
  BLUE_OFF
  YELLOW_ON
}

void loop() {
  setIQInverted("off");
  LoRaWAN.setRadioCRC("on");
  send_data_on_lora("INSERT_JOIN_REQUEST_PACKET_HERE");
  LoRaWAN.setRadioCRC("off");
  setIQInverted("on");
  receive_data_on_lora();
  delay(150000);
  GREEN_OFF
  RED_OFF
}