#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

const char *ssid = "IOT LED";
const char *password = "iot02461357";

ESP8266WebServer server(80);

void handleSentVar() {
    const char* ledValueArgName = "value";
    Serial.println("handleSentVar function called...");
    if (server.hasArg(ledValueArgName)) {
        Serial.println("Sensor reading received...");

        int value = server.arg(ledValueArgName).toInt();

        Serial.print("Reading: ");
        Serial.println(value);
        Serial.println();

        digitalWrite(BUILTIN_LED, !(bool) value);

        // analogWrite(LED_BUILTIN, pwmValSqrt);
        server.send(200, "text/html", "Data received");
    }
}

void setup() {
    delay(1500);
    Serial.begin(115200);
    Serial.println();
    Serial.print("Configuring access point...");

    WiFi.softAP(ssid, password, 11, true);

    pinMode(BUILTIN_LED, OUTPUT);
    digitalWrite(BUILTIN_LED, false);

    IPAddress myIP = WiFi.softAPIP();
    Serial.print("AP IP address: ");
    Serial.println(myIP);
    server.on("/", HTTP_GET, handleSentVar);
    server.begin();
    Serial.println("HTTP server started");
}


void loop() {
    server.handleClient();
}