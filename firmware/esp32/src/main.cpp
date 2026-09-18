#include <Arduino.h>

namespace {
constexpr uint8_t flowSensorPin = 27;
constexpr uint8_t statusLedPin = 2;
constexpr uint8_t switchPin = 4;
constexpr float sensorCalibration = 7.5F;
constexpr float pulsesPerLiter = sensorCalibration * 60.0F;
constexpr float maxPlausibleFlowRate = 30.0F;
constexpr float smoothingFactor = 0.35F;
constexpr unsigned long sampleIntervalMs = 1000;
constexpr uint32_t minimumPulseIntervalUs = 2500;
constexpr char deviceId[] = "SL-001";

volatile uint32_t pulseCount = 0;
volatile uint32_t lastPulseTimeUs = 0;
bool systemActive = false;
float totalLiters = 0.0F;
float smoothedFlowRate = 0.0F;
unsigned long previousSampleTime = 0;

void IRAM_ATTR pulseCounter() {
  const uint32_t nowUs = micros();
  if (nowUs - lastPulseTimeUs < minimumPulseIntervalUs) return;

  lastPulseTimeUs = nowUs;
  pulseCount++;
}

uint32_t takePulseCount() {
  noInterrupts();
  const uint32_t pulses = pulseCount;
  pulseCount = 0;
  interrupts();
  return pulses;
}

void printReading(float flowRate) {
  Serial.printf(
      "DATA:{\"deviceId\":\"%s\",\"currentFlowRate\":%.2f,"
      "\"totalLiters\":%.3f,\"status\":\"%s\"}\n",
      deviceId,
      flowRate,
      totalLiters,
      "online");
}
}  // namespace

void setup() {
  Serial.begin(115200);

  pinMode(statusLedPin, OUTPUT);
  digitalWrite(statusLedPin, LOW);
  pinMode(switchPin, INPUT_PULLUP);
  pinMode(flowSensorPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(flowSensorPin), pulseCounter, FALLING);

  previousSampleTime = millis();
  Serial.println("Smart Loop water monitor is ready.");
}

void loop() {
  const bool switchIsOn = digitalRead(switchPin) == LOW;

  if (switchIsOn != systemActive) {
    delay(30);
    if ((digitalRead(switchPin) == LOW) == switchIsOn) {
      systemActive = switchIsOn;
      digitalWrite(statusLedPin, systemActive ? HIGH : LOW);
      takePulseCount();
      smoothedFlowRate = 0.0F;
      previousSampleTime = millis();
      printReading(0.0F);
    }
  }

  const unsigned long now = millis();

  // The switch controls water measurement, not device connectivity. Keep a
  // heartbeat flowing while measurement is paused so the app can distinguish
  // a connected idle device from a genuinely disconnected ESP32.
  if (!systemActive) {
    takePulseCount();
    if (now - previousSampleTime >= sampleIntervalMs) {
      previousSampleTime = now;
      printReading(0.0F);
    }
    return;
  }

  const unsigned long elapsedMs = now - previousSampleTime;
  if (elapsedMs < sampleIntervalMs) return;

  const uint32_t pulses = takePulseCount();
  const float pulsesPerSecond = pulses * 1000.0F / elapsedMs;
  const float rawFlowRate = pulsesPerSecond / sensorCalibration;

  // Reject a complete sample when electrical noise produces an impossible rate.
  // The YF-S201 normal measurement range tops out around 30 L/min.
  if (rawFlowRate > maxPlausibleFlowRate) {
    previousSampleTime = now;
    Serial.printf("WARN: rejected noisy sample (%.2f L/min)\n", rawFlowRate);
    printReading(smoothedFlowRate);
    return;
  }

  totalLiters += pulses / pulsesPerLiter;
  smoothedFlowRate = rawFlowRate == 0.0F
                         ? 0.0F
                         : smoothingFactor * rawFlowRate +
                               (1.0F - smoothingFactor) * smoothedFlowRate;
  previousSampleTime = now;

  printReading(smoothedFlowRate);
}
