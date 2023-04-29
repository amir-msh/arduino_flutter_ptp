#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

#define ledPin BUILTIN_LED

const char *ssid = "IOT-LED";
const char *password = "iot02461357";

const char* ledValueArgName = "value";

ESP8266WebServer server(80);

void handleLedValueSet() {
    Serial.println("handleLedValueSet()");

    if (server.hasArg(ledValueArgName)) {
        int value = server.arg(ledValueArgName).toInt();

        Serial.print("Value: ");
        Serial.println(value);

        digitalWrite(ledPin, !(bool) value);

        server.send(200, "text/html", "Setting the LED value was successful!");
    }
}

void handleLedValueGet() {
    Serial.println("handleLedValueGet()");

    int value = (int) !(bool)digitalRead(ledPin);

    String json = "{\"value\":" + String(value) + "}";
    server.send(200, "application/json", json);
}

void handleNotFound() {
    server.send(404, "text/html", "Oops! There's no page here :O");
}

void setup() {
    delay(1500);
    Serial.begin(115200);
    Serial.print("\n\nConfiguring AP ...");

    WiFi.softAP(ssid, password, 11, true);

    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, true);

    IPAddress ip = WiFi.softAPIP();
    Serial.print("AP IP address: ");
    Serial.println(ip);

    server.on("/", HTTP_GET, handleLedValueSet);
    server.on("/value", HTTP_GET, handleLedValueGet);
    server.onNotFound(handleNotFound);
    server.begin();
    Serial.println("* The HTTP server is started! *");
}


void loop() {
    server.handleClient();
}