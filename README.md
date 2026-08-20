# CARACTERIZACIÓN DINÁMICA Y ELÉCTRICA DEL MOTORREDUCTOR (AGITADOR) - GRUPO 5
## Identificación Experimental de Mezcla - Sistemas de Control II (UNET)

Elaborado por: Daniel Torres y Yermey Castro

---

### 1. OBJETIVO DEL PROYECTO DE CARACTERIZACIÓN
Este repositorio contiene todo lo necesario para reproducir la caracterización física de un motorreductor DC utilizado como agitador en un Reactor Batch. 

En la industria, no podemos controlar lo que no conocemos. Por ello, el objetivo de esta práctica es medir cómo responde el motor ante diferentes niveles de potencia (PWM) bajo la resistencia viscosa de 2 Litros de agua. Los datos extraídos permiten identificar no linealidades (como la **Zona Muerta** y la **Saturación**), lo cual es un paso fundamental en *Sistemas de Control II* antes de diseñar un lazo cerrado.

---

### 2. LISTADO DE COMPONENTES UTILIZADOS y Hardware Mínimo Requerido
Para reproducir este experimento, se requiere el siguiente hardware. Todos los componentes deben compartir una referencia de tierra común (GND).

| Componente | Referencia / Modelo | Cantidad | Función en el sistema |
| :--- | :--- | :--- | :--- |
| **Microcontrolador** | ESP32 DevKit V1 (30 pines) | 1 | Procesamiento, conteo de interrupciones y servidor Web WiFi. |
| **Driver de Motor** | Puente H L298N | 1 | Etapa de potencia para suministrar 12V al motor modulados por PWM. |
| **Actuador** | Motorreductor DC tipo TT | 1 | Agitador mecánico del reactor. |
| **Sensor (Feedback)**| Encoder Óptico FC-03 | 1 | Lectura de las ranuras del disco para calcular RPM reales. |
| **Fuente de Poder** | Fuente ATX de PC (Reciclada)| 1 | Suministra 12V estables (Cable amarillo) para la potencia. |
| **Carga de Trabajo** | Jarra plástica + Agua | 1 | Simula la inercia viscosa con 2 Litros de agua. |
| **Aspas** | Fabricadas con alambre y aspas de ventiladores de 12V | 2 | 1 Aspa ligera y 1 Aspa pesada para comparar torque resistente. |

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

*(El diagrama eléctrico detallado en formato .fzz de Fritzing se encuentra dentro de la carpeta `Diagrama electrico` de este repositorio).*

---

### 4. INSTRUCCIONES DE DESARROLLO Y CARGA
Para un estudiante nuevo, siga estos pasos para ejecutar el proyecto:

### A. Preparación del Entorno
1. Descargue este repositorio: Puede hacer clic en el botón verde **"Code" -> "Download ZIP"** y descomprimirlo, o clonarlo vía Git:
   `git clone https://github.com/tu-usuario/tu-repo-motor.git`
2. Instale **Visual Studio Code (VS Code)**.
3. Vaya a las extensiones de VS Code e instale **PlatformIO IDE**.
4. En VS Code, vaya a *File -> Open Folder* y seleccione la carpeta de este proyecto.

### B. Compilación y Carga
*(Nota: Para este proyecto, la página web (HTML/JS) se encuentra embebida directamente en el archivo `main.cpp`, por lo que **no es necesario cargar un sistema de archivos LittleFS**, simplificando el proceso).*
1. Conecte el ESP32 a su computadora vía USB.
2. Abra la terminal de PlatformIO en VS Code y compile el proyecto:
   `pio run`
3. Suba el firmware a la placa:
   `pio run --target upload`

### C. Puesta en Marcha y Monitoreo
1. Una vez cargado, abra el monitor serial en VS Code:
   `pio device monitor --baud 115200`
2. Si el sistema arrancó correctamente, verá el mensaje: `"WiFi Access Point 'Reactor_Batch_G5' Iniciado"`.
3. Desde su teléfono o laptop, busque las redes WiFi y conéctese a **Reactor_Batch_G5** (Contraseña: `control_industrial`).
4. Abra su navegador web (recomendado modo incógnito) e ingrese a: **`http://192.168.4.1`**.
5. Verá la interfaz HMI cargada. Deslice el control PWM y observe cómo el motor gira y las RPM se actualizan.

---

### 5. VALIDACIÓN DE LIBRERÍAS LOCALES (MODO OFFLINE)
Para garantizar el funcionamiento del banco de pruebas en entornos industriales o laboratorios sin acceso a internet (como los de la UNET), las librerías de visualización y exportación se cargan directamente desde la memoria interna del ESP32 (LittleFS).

Al ingresar a la interfaz en tu navegador (`192.168.4.1`), verifique el estado en la sección de diagnóstico:
*   **Chart.js local:** cargado
*   **SheetJS local (XLSX):** cargado
*   **Modo offline:** OK

*Nota:* Si alguna librería aparece como "no cargado", asegúrese de haber ejecutado con éxito el comando `uploadfs` en el Paso 3 de la sección anterior.

---

### 6. PROCEDIMIENTO DEL ENSAYO DE CARACTERIZACIÓN (PASO A PASO)
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

## ⚠️ 7. Problemas Frecuentes (Troubleshooting)

*   **El ESP32 no aparece en el puerto COM:** Instale los drivers CP210x o CH340 según el modelo de su placa ESP32. Asegúrese de usar un cable USB de transferencia de datos, no solo de carga.
*   **El motor zumba pero no gira:** El PWM es demasiado bajo (está en la zona muerta) o la fuente ATX no está encendida (recuerde puentear el cable verde con un negro en la fuente ATX para que encienda).
*   **La página web no carga o se congela:** Desactive los "Datos Móviles" de su teléfono celular mientras está conectado al WiFi del ESP32.
*   **El encoder FC-03 siempre marca 0 RPM:** Revise que el disco de ranuras no esté rozando la herradura negra del sensor. Verifique que el cable verde de datos esté firmemente conectado al pin D33.
*   **El firmware no compila (Error de librerías):** Asegúrese de que el archivo `platformio.ini` esté en la raíz del proyecto y contenga las librerías `ESPAsyncWebServer` y `DallasTemperature`.

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
