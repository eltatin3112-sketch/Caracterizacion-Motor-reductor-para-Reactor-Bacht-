# CARACTERIZACIÓN DINÁMICA Y ELÉCTRICA DEL MOTORREDUCTOR (AGITADOR) - GRUPO 5
## Identificación Experimental de Mezcla - Sistemas de Control II (UNET)

Elaborado por: Daniel Torres y Yermey Castro

---

### 1. OBJETIVO DEL PROYECTO DE CARACTERIZACIÓN
Este repositorio contiene el firmware, los esquemas de conexión y los datos crudos utilizados para la caracterización dinámica y eléctrica del motorreductor TT de 12V empleado en el agitador de hélice del reactor batch. 

El propósito de esta fase experimental es identificar y modelar el comportamiento estático y dinámico de la etapa de mezcla bajo condiciones reales de carga. A través de este ensayo se busca:
*   Identificar la relación exacta entre la señal de mando (PWM de 0 a 255) y la velocidad de rotación real (RPM).
*   Cuantificar las no linealidades críticas del actuador mecánico, tales como la zona muerta por fricción estática y la saturación de voltaje impuesta por el driver de potencia.
*   Analizar el comportamiento del consumo de corriente de armadura ante variaciones de velocidad y el efecto de la fuerza contraelectromotriz (FCEM).
*   Validar la inercia del motor y determinar el tiempo de establecimiento mecánico para compararlo con el lazo térmico.

---

### 2. LISTADO DE COMPONENTES UTILIZADOS
Para este ensayo específico de caracterización, se utilizó el siguiente hardware:

*   **Microcontrolador Principal:** ESP32 DevKit V1 (Encargado del conteo de pulsos, cálculo de velocidad y servidor de telemetría).
*   **Actuador Mecánico:** Motorreductor de corriente continua tipo TT de 12V acoplado a una hélice de alambre galvanizado.
*   **Driver de Potencia:** Módulo Puente H L298N (Configurado para modulación por ancho de pulso PWM).
*   **Sensor de Velocidad (Retroalimentación):** Encoder óptico de herradura FC-03 con disco acoplado de 20 ranuras.
*   **Fuente de Alimentación:** Fuente conmutada tipo ATX de computadora (Riel de 12V para potencia y puerto USB de la laptop para la lógica de 5V).
*   **Recipiente de Proceso:** Jarra cilíndrica de polímero de 3.5 Litros con una carga de agua estandarizada de 2 Litros (para simular la inercia viscosa real).
*   **Instrumentación Auxiliar:** Multímetro digital configurado en modo Amperímetro (en serie con el motor) y Voltímetro (en paralelo a los bornes).

---

### 3. TABLA DE CONEXIONES Y PINOUT (CABLEADO)
Para garantizar el correcto funcionamiento de las señales de control de alta velocidad (PWM e interrupciones del encoder) y mitigar el ruido, se unificaron las referencias de tierra del sistema. Las conexiones del módulo ESP32, el driver de motores y el sensor se estructuran de la siguiente manera:

| Conexión Origen | Señal / Pin | Destino Hardware | Notas Técnicas |
| :--- | :--- | :--- | :--- |
| **Fuente ATX** | `+12V` (Cable Amarillo) | L298N `VCC` | Potencia para el motor TT de 12V |
| **Fuente ATX** | `G
ND` (Cable Negro) | **GND COMÚN** | Unión de tierras del sistema en borne L298N |
| **ESP32** | `3V3` | `VCC` Sensor FC-03 | Alimentación lógica estable de 3.3V |
| **ESP32** | `GND` | **GND COMÚN** | Conectado al pin GND del ESP32 |
| **ESP32** | `GPIO 25` (D25) | L298N `ENA` | Requiere remover el jumper negro de ENA |
| **ESP32** | `GPIO 26` (D26) | L298N `IN1` | Control de sentido de giro del agitador |
| **ESP32** | `GPIO 27` (D27) | L298N `IN2` | Control de sentido de giro del agitador |
| **ESP32** | `GPIO 33` (D33) | `OUT` Sensor FC-03 | Pin con soporte de interrupciones externas |
| **L298N** | `OUT1 / OUT2` | Bornes Motor TT | Conexión directa de potencia al agitador |

#### Conexiones de Advertencia y Seguridad (Pines Strapping):
*   **NO** alimentar el sensor FC-03 con los 5V de la fuente ATX o el pin VIN del ESP32. Su salida de señal debe operar estrictamente a 3.3V para proteger las entradas del ESP32.
*   **OBLIGATORIO:** Conectar físicamente el pin GND del ESP32 con el borne de tierra del L298N para unificar las referencias de las señales lógicas PWM e impedir voltajes flotantes.

*(El diagrama eléctrico detallado en formato .fzz de Fritzing se encuentra dentro de la carpeta `/hardware` de este repositorio).*

---

### 4. ESTRUCTURA DEL PROYECTO (PLATFORMIO)
El software se encuentra organizado bajo el estándar de PlatformIO en Visual Studio Code. Las dependencias lógicas y los archivos de la interfaz web se distribuyen en las siguientes carpetas:

*   **platformio.ini:** Archivo de configuración del entorno (board: esp32dev, framework: arduino, librerías y monitor_speed en 115200).
*   **src/main.cpp:** Código central de la prueba (conteo de pulsos por interrupción, cálculo de RPM y servidor de telemetría asíncrono).
*   **data/index.html:** Interfaz gráfica del usuario (HMI) diseñada en HTML5.
*   **data/app.js:** Lógica de telemetría y actualización de gráficas dinámicas en JavaScript.
*   **data/style.css:** Diseño visual responsivo del panel de control.
*   **data/chart.umd.min.js:** Librería de gráficas alojada localmente en la flash para funcionamiento sin internet.
*   **data/xlsx.full.min.js:** Librería de exportación local para Excel.

---

### 5. INSTRUCCIONES DE DESARROLLO Y CARGA
Siga esta secuencia de comandos en la terminal de VS Code para compilar y subir todo el sistema a la placa ESP32:

1. **Compilar el código fuente:** 
   `pio run`
2. **Subir el Firmware al ESP32:** 
   `pio run --target upload`
3. **Subir la Interfaz Web (LittleFS) a la memoria Flash:** 
   `pio run --target uploadfs`
4. **Abrir Monitor Serial para diagnóstico:** 
   `pio device monitor --baud 115200`

---

### 6. VALIDACIÓN DE LIBRERÍAS LOCALES (MODO OFFLINE)
Para garantizar el funcionamiento del banco de pruebas en entornos industriales o laboratorios sin acceso a internet (como los de la UNET), las librerías de visualización y exportación se cargan directamente desde la memoria interna del ESP32 (LittleFS).

Al ingresar a la interfaz en tu navegador (`192.168.4.1`), verifique el estado en la sección de diagnóstico:
*   **Chart.js local:** cargado
*   **SheetJS local (XLSX):** cargado
*   **Modo offline:** OK

*Nota:* Si alguna librería aparece como "no cargado", asegúrese de haber ejecutado con éxito el comando `uploadfs` en el Paso 3 de la sección anterior.

---

### 7. PROCEDIMIENTO DEL ENSAYO DE CARACTERIZACIÓN (PASO A PASO)
Este protocolo experimental está diseñado para obtener de forma cuantitativa la fricción, zona muerta, voltaje de saturación, velocidad máxima y corriente de armadura bajo la carga viscosa real de 2 Litros de agua utilizando dos diseños de hélice distintos:

#### Etapa 1: Preparación de la Instrumentación de Medición
1.  **Conexión del Amperímetro:** Conectar un multímetro digital configurado en modo **Amperímetro (mA DC)** en serie con el cable positivo de alimentación que va del driver L298N hacia el motor TT. (Esto nos permitirá medir el consumo de corriente de armadura).
2.  **Conexión del Voltímetro:** Conectar un segundo multímetro configurado en modo **Voltímetro (V DC)** en paralelo a los bornes del motor para validar la linealidad del voltaje suministrado.
3.  **Alineación del Encoder:** Verificar que el disco de 20 ranuras acoplado al eje posterior del motor esté alineado dentro de la herradura del sensor óptico **FC-03** para permitir la lectura digital de RPM en tiempo real sin interferir con la hélice sumergida.

#### Etapa 2: Ensayo con Aspa Ligera (Mezcla Activa de 2 Litros)
1.  Sumergir el agitador con el **Aspa Ligera** dentro de la jarra graduada con exactamente 2 Litros de agua pura.
2.  Abrir la interfaz web del ESP32 en la laptop o teléfono (`192.168.4.1`).
3.  **Rampa Ascendente:** Iniciar en 0 PWM e ir aumentando la velocidad en pasos de 20 unidades (0, 20, 40, 60, 80, 100, etc.) hasta llegar a 255. En cada escalón, esperar exactamente **5 segundos** para que la velocidad se estabilice y anotar en tu hoja de cálculo:
    *   Las **RPM** reales mostradas en la pantalla de telemetría web (leídas por el FC-03).
    *   La **corriente de armadura (mA)** mostrada en el amperímetro en serie.
    *   El **voltaje en bornes (V)** mostrado en el voltímetro en paralelo.
4.  **Rampa Descendente:** Repetir el proceso de forma descendente (de 255 a 0 PWM) en los mismos pasos, anotando los tres valores en cada escalón para cuantificar la histéresis mecánica.
5.  Hacer clic en el botón de la web **"DESCARGAR DATOS EXCEL (CSV)"** para exportar la base de datos de esta prueba.

#### Etapa 3: Ensayo con Aspa Pesada (Mezcla Activa de 2 Litros)
1.  Apagar el sistema, retirar el aspa ligera e instalar el **Aspa Pesada de alambre** en el eje del agitador.
2.  Sumergir el agitador nuevamente en la jarra con los 2 Litros de agua.
3.  Repetir exactamente toda la secuencia de la **Rampa Ascendente y Descendente** (Paso 3 y 4 de la Etapa anterior) anotando las RPM leídas por el encoder, la corriente y el voltaje.
4.  Descargar el segundo archivo de datos CSV para su análisis comparativo en MATLAB.

---

### 8. INTERPRETACIÓN DE RESULTADOS OBTENIDOS (ANÁLISIS)
A partir del procesamiento de los datos descargados en formato CSV y su análisis en MATLAB, se identificaron los siguientes comportamientos físicos y no linealidades de la etapa de agitación:

#### A. Zona Muerta Mecánica (Fricción Estática)
Se identificó una zona muerta significativa situada entre las **0 y las 25.5 unidades de PWM**. En este rango, aunque el motor recibe un voltaje residual de 0.25V y consume 76 mA de corriente, el torque magnético generado es insuficiente para vencer la fricción interna de los engranajes de plástico y la resistencia viscosa del agua. Para el algoritmo de control, cualquier valor por debajo de este umbral mantendrá el motor estático.

#### B. Eficiencia Eléctrica y Caída de Tensión (Saturación)
A pesar de alimentar el driver L298N con un riel estable de 12V DC de la fuente ATX, el voltaje máximo medido en los bornes del motor a PWM 255 fue de solo **9.25 Voltios**. Esto revela una caída de tensión interna de aproximadamente **2.75V** consumida por la conmutación de los transistores bipolares del puente H, actuando como una saturación física que limita la velocidad máxima de agitación a **441 RPM**.

#### C. Consumo de Corriente de Armadura (Inercia y Fuerza Contraelectromotriz)
La curva de consumo eléctrico registró un comportamiento no lineal típico de motores DC bajo carga viscosa:
*   **Pico de Arranque:** Se registró un pico máximo de corriente de **118 mA** en los niveles medios de PWM (alrededor de 76.5 unidades), punto exacto donde el motor realiza el mayor esfuerzo mecánico para romper la inercia del agua estática.
*   **Efecto de la Fuerza Contraelectromotriz (FCEM):** A medida que la hélice gana velocidad y establece el flujo continuo, la corriente desciende significativamente hasta estabilizarse en los **27.8 mA** a máxima velocidad (441 RPM), demostrando que el sistema es más eficiente a altas velocidades.

#### D. Comparativa de Aspas (Impacto del Diseño Geométrico)
La carga del fluido actúa como una perturbación crítica ligada al diseño de la hélice:
*   **Aspa Ligera:** Permitio alcanzar una velocidad máxima de **405 RPM** bajo carga de 2 Litros.
*   **Aspa Pesada:** Debido a su mayor área de contacto y arrastre viscoso, limitó la velocidad máxima a **320 RPM** bajo las mismas condiciones de potencia. Esto representa una **reducción del 21% en la ganancia de velocidad (Km)**, demostrando que el diseño mecánico influye de forma directa en el torque resistente.

#### E. Análisis Dinámico (Constante de Tiempo Mecánica)
La respuesta temporal al escalón de 0 a 100% de PWM confirmó que la dinámica de la agitación mecánica es sumamente rápida, alcanzando el estado estable en aproximadamente **16 segundos**. Al comparar esto con la constante de tiempo del lazo térmico (92 segundos), se justifica y valida el supuesto de **agitación constante y homogénea** durante todo el posterior proceso de calentamiento PID.
