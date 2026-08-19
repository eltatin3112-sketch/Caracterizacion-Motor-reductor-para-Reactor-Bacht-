%% CARACTERIZACIÓN EXPERIMENTAL - MOTORREDUCTOR TT - GRUPO 5
clear all; clc; close all;
% --- 1. DEFINICIÓN DE DATOS EXPERIMENTALES ---
% Datos generales (PWM vs RPM, Voltaje y Corriente)
pwm_puntos = [0, 25.5, 51, 76.5, 102, 127.5, 153, 178.5, 201, 229.5, 255];
rpm_puntos = [0, 0, 147, 190, 270, 291, 340, 363, 381, 411, 441];
voltaje_v  = [0, 0.25, 3.03, 4.8, 5.95, 6.7, 7.38, 7.8, 8.25, 8.7, 9.25];
corriente_ma = [0, 76, 114, 118, 114.7, 108, 97, 86, 72.3, 51.7, 27.8];

% Datos Respuesta al Escalón (Tiempo vs RPM)
tiempo_s = [0, 9, 16, 22, 27, 31, 35, 38, 44, 47, 54];
rpm_escalon = [0, 0, 147, 190, 270, 291, 340, 363, 381, 411, 441];

% Datos Comparativa de Aspas (Carga real)
pwm_aspas = [25, 51, 76, 102, 103, 153, 178, 201, 230, 255];
rpm_pesada = [0, 39, 72, 81, 111, 168, 201, 246, 295, 320];
rpm_ligera = [0, 93, 126, 190, 234, 258, 318, 345, 375, 405];

% --- 2. GRÁFICA 1: CARACTERIZACIÓN ELÉCTRICA Y MECÁNICA ---
figure('Name', 'Caracterizacion Estatica del Motor', 'Color', 'w');

subplot(3,1,1);
plot(pwm_puntos, rpm_puntos, '-ok', 'LineWidth', 1.5, 'MarkerFaceColor', 'g');
title('PWM vs Velocidad (RPM)');
ylabel('RPM'); grid on;

subplot(3,1,2);
plot(pwm_puntos, voltaje_v, '-ob', 'LineWidth', 1.5, 'MarkerFaceColor', 'c');
title('PWM vs Voltaje en Bornes');
ylabel('Voltios (V)'); grid on;

subplot(3,1,3);
plot(pwm_puntos, corriente_ma, '-or', 'LineWidth', 1.5, 'MarkerFaceColor', 'm');
title('PWM vs Corriente de Armadura');
xlabel('Ciclo de Trabajo (PWM)'); ylabel('Corriente (mA)'); grid on;

% --- 3. GRÁFICA 2: COMPARATIVA DE CARGA (ASPAS) ---
figure('Name', 'Efecto de la Carga Mecanica', 'Color', 'w');
plot(pwm_aspas, rpm_ligera, '-o', 'Color', [0 0.5 0], 'LineWidth', 2, 'DisplayName', 'Aspa Ligera');
hold on;
plot(pwm_aspas, rpm_pesada, '-o', 'Color', [0.8 0 0], 'LineWidth', 2, 'DisplayName', 'Aspa Pesada');
title('Comparativa de Velocidad: Aspa Ligera vs Pesada');
xlabel('PWM'); ylabel('RPM');
legend('Location', 'best');
grid on;

% --- 4. GRÁFICA 3: RESPUESTA DINÁMICA (ESCALÓN) ---
figure('Name', 'Respuesta Dinamica al Escalon', 'Color', 'w');
stairs(tiempo_s, rpm_escalon, 'LineWidth', 2, 'Color', [0.4 0 0.7]);
title('Respuesta Temporal del Motor (Escalon 0 a 100% PWM)');
xlabel('Tiempo (s)'); ylabel('RPM');
grid on;