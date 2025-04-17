// --- Настройка пинов: подберите под свою плату RP2040 ---
const uint8_t SENSOR_UP_RIGHT_PIN  = 2;  // датчик, реагирующий на наклон влево
const uint8_t SENSOR_DOWN_RIGHT_PIN = 3;  // датчик, реагирующий на наклон вправо

// Как подключать ртутный датчик:
//   один кончик датчика → пин, другой → GND
//   используем внутренний pullup, поэтому при замыкании читаем LOW.

char lastState = 0;

void setup() {
  // Старт USB‑Serial
  Serial.begin(115200);
  delay(1000);       // даём секунду на инициализацию USB‑CDC

  // Настраиваем входы с pull‑up
  pinMode(SENSOR_DOWN_RIGHT_PIN, INPUT_PULLUP);
  pinMode(SENSOR_UP_RIGHT_PIN,  INPUT_PULLUP);
}

void loop() {
  bool upRight  = (digitalRead(SENSOR_UP_RIGHT_PIN) == LOW);
  bool downRight = (digitalRead(SENSOR_DOWN_RIGHT_PIN) == LOW);

  char state;
  if (upRight) {
    if (downRight)
      state = 'N';            // normal (flat)
    else
      state = 'L';            // tilt left
  }
  else{
    if (downRight)
      state = 'R';            // tilt right
    else
      state = 'I';            // inverted (upside‑down)
  }

  // Если состояние изменилось — шлём новый код
  if (state != lastState) {
    Serial.write(state);
    lastState = state;
  }

  delay(100);  // антидребезг и не перегружать USB
}
