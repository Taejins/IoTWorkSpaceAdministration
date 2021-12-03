//----------------------------- BUTTON and LED -------------------------------
#define led_ON 7
#define button_on 6
#define button_A 4
#define sound_alrt 5
int btn_count = 0;
int A_btn_count = 0;
// ----------------------------- GPS -----------------------------------------
#define gpsSerial Serial1
String str = ""; // \n 전까지 c 값을 저장.
String targetStr = "GPGGA"; // str의 값이 NMEA의 GPGGA 값인지 타겟
void GPS_parser();
double lat;
float lon;
// ----------------------------- LCD -----------------------------------------
#include <Wire.h>
#include <hd44780.h> // include hd44780 library header file
#include <hd44780ioClass/hd44780_I2Cexp.h> // i/o expander/backpack class
hd44780_I2Cexp lcd; // auto detect backpack and pin mappings
// LCD geometry
const int LCD_COLS = 16;
const int LCD_ROWS = 2;
int customcharRow = 1;
// ----------------------------- AWS -----------------------------------------
#include <ArduinoBearSSL.h>
#include <ArduinoECCX08.h>
#include <ArduinoMqttClient.h>
#include <WiFiNINA.h> // change to #include <WiFi101.h> for MKR1000
#include "arduino_secrets.h"
#include <ArduinoJson.h>

/////// Enter your sensitive data in arduino_secrets.h
const char ssid[]        = SECRET_SSID;
const char pass[]        = SECRET_PASS;
const char broker[]      = SECRET_BROKER;
const char* certificate  = SECRET_CERTIFICATE;

const char employee[] = "employee1"; //deviceID 
const char* getstate;

WiFiClient    wifiClient;            // Used for the TCP socket connection
BearSSLClient sslClient(wifiClient); // Used for SSL/TLS connection, integrates with ECC508
MqttClient    mqttClient(sslClient);

unsigned long gps_send_lastMillis = 0;
unsigned long button_send_lastMillis = 0;


void setup() { 
  int status;
  pinMode(sound_alrt,OUTPUT);
  pinMode(led_ON,OUTPUT);
  pinMode(button_on, INPUT);
  pinMode(button_A, INPUT);
  Serial.begin(115200);
//  while (!Serial);
  gpsSerial.begin(9600);
  status = lcd.begin(LCD_COLS, LCD_ROWS);
  if(status)
  {
    hd44780::fatalError(status); // does not return
  }
  
  lcd.clear();
//  lcd_print(0);
  
  if (!ECCX08.begin()) {
    Serial.println("No ECCX08 present!");
    while (1);
  }

  ArduinoBearSSL.onGetTime(getTime);
  sslClient.setEccSlot(0, certificate);
  mqttClient.onMessage(onMessageReceived);
}

void loop() {
  if(gpsSerial.available()){      
    GPS_parser(); //GPS 파싱을 위해 GPS가 사용가능하면 계속해서 파싱하여 값을 추출
  }

  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }

  if (!mqttClient.connected()) {
    // MQTT client is disconnected, connect
    connectMQTT();
  }
  
  //button push check
  button_push();

  // poll for new MQTT messages and send keep alives
  mqttClient.poll();

  // publish a message roughly every 20 seconds.
  if (millis() - gps_send_lastMillis > 20000) {
    gps_send_lastMillis = millis();
    char payload[512];
    if(lat > 0 && lon > 0){
      getDeviceStatus(payload); //gps에서 추출한 경도 위도값을 20초마다 한번씩 AWS에 전송
      sendMessage(payload);
    }
  }
}

unsigned long getTime() {
  // get the current time from the WiFi module  
  return WiFi.getTime();
}

void connectWiFi() {
  Serial.print("Attempting to connect to SSID: ");
  Serial.print(ssid);
  Serial.print(" ");

  while (WiFi.begin(ssid, pass) != WL_CONNECTED) {
    // failed, retry
    Serial.print(".");
    delay(5000);
  }
  Serial.println();

  Serial.println("You're connected to the network");
  Serial.println();
}

void connectMQTT() {
  Serial.print("Attempting to MQTT broker: ");
  Serial.print(broker);
  Serial.println(" ");

  while (!mqttClient.connect(broker, 8883)) {
    // failed, retry
    Serial.print(".");
    delay(5000);
  }
  Serial.println();

  Serial.println("You're connected to the MQTT broker");
  Serial.println();

  lcd_print(0);

  // subscribe to a topic
  mqttClient.subscribe("$aws/things/employee1/shadow/update/delta");
}

void getDeviceStatus(char* payload) {
  // make payload for the device update topic ($aws/things/MyMKRWiFi1010/shadow/update)
  sprintf(payload,"{\"devicename\":\"%s\",\"lat\":\"%f\",\"lon\":\"%f\",\"emergency\":\"%d\"}",employee,lat,lon,99);
}

void EMR_getDeviceStatus(char* payload) { //긴급 신호버튼 눌렀을시 update에 전송위한 함수
  // make payload for the device update topic ($aws/things/MyMKRWiFi1010/shadow/update)
  sprintf(payload,"{\"devicename\":\"%s\",\"lat\":\"%f\",\"lon\":\"%f\",\"emergency\":\"%d\"}",employee,lat,lon,1);
}

void sendMessage(char* payload) {
  char TOPIC_NAME[]= "$aws/things/employee1/shadow/update";
  
  Serial.print("Publishing send message:");
  Serial.println(payload);
  mqttClient.beginMessage(TOPIC_NAME);
  mqttClient.print(payload);
  mqttClient.endMessage();
}


void onMessageReceived(int messageSize) {
  // we received a message, print out the topic and contents
  Serial.print("Received a message with topic '");
  Serial.print(mqttClient.messageTopic());
  Serial.print("', length ");
  Serial.print(messageSize);
  Serial.println(" bytes:");

  // store the message received to the buffer
  char buffer[512] ;
  int count=0;
  while (mqttClient.available()) {
     buffer[count++] = (char)mqttClient.read();
  }
  buffer[count]='\0'; // 버퍼의 마지막에 null 캐릭터 삽입
  Serial.println(buffer);
  Serial.println();

  // JSon 형식의 문자열인 buffer를 파싱하여 필요한 값을 얻어옴.
  // 디바이스가 구독한 토픽이 $aws/things/employee1/shadow/update/delta 이므로,
  // JSon 문자열 형식은 다음과 같다.
  // {
  //    "version":391,
  //    "timestamp":1572784097,
  //    "state":{
  //        "LED":"ON"
  //    },
  //    "metadata":{
  //        "LED":{
  //          "timestamp":15727840
  //         }
  //    }
  // }
  //
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, buffer);
  JsonObject root = doc.as<JsonObject>();
  JsonObject state = root["state"];
  const char* led = state["LED"]; //LED파싱
  getstate = state["place"]; //장소 파싱
  Serial.println(led);
  
  char payload[512];
  
  if (strcmp(led,"ON")==0) { //LED가 ON신호가 왔을 때, 업무 신호 수신 LED ON, 및 부저 알림, LCD에 장소 표시
    digitalWrite(led_ON, HIGH);
    tone(sound_alrt,1046,2000);
    lcd_print(3);
    sprintf(payload,"{\"state\":{\"reported\":{\"LED\":\"%s\",\"place\":\"%s\"}}}","ON", getstate);
    sendMessage(payload);
    
  } else if (strcmp(led,"OFF")==0) {
    digitalWrite(led_ON, LOW);
    sprintf(payload,"{\"state\":{\"reported\":{\"LED\":\"%s\"}}}","OFF");
    sendMessage(payload);
    sprintf(payload,"{\"devicename\":\"%s\",\"emergency\":\"%d\"}",employee,2);
    sendMessage(payload);
  }
}


void GPS_parser(){ //GPS 파싱
  char c = gpsSerial.read();
        if(c == '\n'){ // \n 값인지 구분.
        // \n 일시. 지금까지 저장된 str 값이 targetStr과 맞는지 구분
        if(targetStr.equals(str.substring(1, 6))){
          // , 를 토큰으로서 파싱.
          int first = str.indexOf(",");
          int two = str.indexOf(",", first+1);
          int three = str.indexOf(",", two+1);
          int four = str.indexOf(",", three+1);
          int five = str.indexOf(",", four+1);
          // Lat과 Long 위치에 있는 값들을 index로 추출
          String Lat = str.substring(two+1, three);
          String Long = str.substring(four+1, five);
          // Lat의 앞값과 뒷값을 구분
          String Lat1 = Lat.substring(0, 2);
          String Lat2 = Lat.substring(2);
          // Long의 앞값과 뒷값을 구분
          String Long1 = Long.substring(0, 3);
          String Long2 = Long.substring(3);
          // 좌표 계산.
          double LatF = Lat1.toDouble() + Lat2.toDouble()/60;
          float LongF = Long1.toFloat() + Long2.toFloat()/60;
          //좌표 출력.
          lat = LatF;
          lon = LongF;
        }
        // str 값 초기화 
        str = "";
      }else{ // \n 아닐시, str에 문자를 계속 더하기
        str += c;
      }
}

void lcd_print(int a){ //LCD 출력을 위한 함수
  if(a == 0){
    lcd.clear();
    lcd.print("Work");
    lcd.setCursor(0, customcharRow);
    lcd.print(":Have a nice day");
  }
  if(a == 1){
    lcd.clear();
    lcd.print("Urgent Support");
    lcd.setCursor(0,customcharRow);
    lcd.print("Request");
  }
  if(a == 2){
    lcd.clear();
    lcd.print("Work Alloc");
    lcd.setCursor(0,customcharRow);
    lcd.print(": ");
    lcd.write(getstate);
    lcd.print(" (ACK)");
  }
  if(a == 3){
    lcd.clear();
    lcd.print("Work Alloc");
    lcd.setCursor(0,customcharRow);
    lcd.print(": ");
    lcd.write(getstate);
  }
}

void button_push(){ // 풀링 현상을 막기 위해 1초마다 버튼이 눌렸는지 확인하여 카운팅을하여, 긴급신호와 일반신호를 구별하고 전송.
   if(millis() - button_send_lastMillis > 1000){
    int i = 0;
    button_send_lastMillis = millis();
    if(digitalRead(button_on) == LOW){
      btn_count++;
    }
    else{
      btn_count = 0;
    }
    
    if(digitalRead(button_A) == LOW){
      A_btn_count++;
    }
    else{
      A_btn_count = 0;
    }
    
    if(btn_count > 4){ //긴급신호버튼 5초 이상 눌렀을시 긴급 신호 전송 및 부저 알림.
      char payload[512];
      EMR_getDeviceStatus(payload);
      sendMessage(payload);
      lcd_print(1);
      tone(sound_alrt,1046,1000);
      btn_count = 0;
    }
    else if(A_btn_count > 1){ //수신신호버튼 1초이상 눌렀을시 LED OFF신호 전송
      lcd_print(2);
      char payload[512];
      sprintf(payload,"{\"state\":{\"desired\":{\"LED\":\"%s\",\"place\":\"%s\"}}}","OFF","OK");
      sendMessage(payload);
      sprintf(payload,"{\"state\":{\"reported\":{\"LED\":\"%s\",\"place\":\"%s\"}}}","OFF","OK");
      sendMessage(payload);
      A_btn_count = 0;
    }
    
  }
}
