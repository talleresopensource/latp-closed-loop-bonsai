%CC-BY-SA
%Marcos Coletti y Cecilia Herbert para LATP 2022
%https://github.com/talleresopensource/latp-closed-loop-bonsai

%leo los datos
path_dat = 'C:\Users\colet\Desktop\LATP - BONSAI\datos_experimentos_alumnos\experimentos\grupo_A\raton_2'; 

datos = readtable(fullfile(path_dat,'dato_F_A_20.csv'));

%% Reorganizar datos
% renombro las columnas de la tabla
datos.Properties.VariableNames{1} = 'x';
datos.Properties.VariableNames{2} = 'y';

%ATENCION CON EL ORDEN DE GUARDADO DE DATOS EN BONSAI
datos.Properties.VariableNames{5} = 'inicio';
datos.Properties.VariableNames{4} = 'roi_F';
datos.Properties.VariableNames{3} = 'roi_N';

% Convertir columnas ROI en vectores logicos
datos.roi_N = strcmp(datos.roi_N, 'True');
datos.roi_F = strcmp(datos.roi_F, 'True');

%% procesamiento de los datos

fm = 30; %frec de muestreo webcam
dt = 1/fm; 

% Deteccion inicio y fin del registro de la tarea
tecla = datos.inicio;
diff_tecla = [false ; diff(tecla)]; %flanco acendete(1) y decendente(-1) de los eventos
eventos_inicio = (diff_tecla ==1); %vector logico con marcas de los flancos acendentes
inicio_tarea = find(eventos_inicio == 1, 1,'first'); %indice del primer flanco asc

% fin de tarea. se presiono la tecla para inidicar el fin de la tarea?
fin_tarea = find(eventos_inicio == 1, 1,'last');

% sino, me quedo con el final del video (busqueda manual en el video)
% fin_tarea = size(datos,1);

%recorto todos los datos entre el inicio y fin de la tarea
pos_x = datos.x(inicio_tarea:fin_tarea);
pos_y = datos.y(inicio_tarea:fin_tarea);
roi_N = datos.roi_N(inicio_tarea:fin_tarea);
roi_F = datos.roi_F(inicio_tarea:fin_tarea);

%% 
%genero el vector de tiempo
t = [0:dt:(fin_tarea - inicio_tarea)*dt]';

%tiempo total de la tarea
t_total = t(end) %en segundos

%% Calculo indice de discriminacion (ID)
% Permite discriminar entre el objeto nuevo y el familiar. No esta
% influenciado por diferencias en el tiempo de exploracion de los objetos
% Es la diferencia entre el tiempo de exploracion del objeto familiar
% dividido tiempo total de exploracion del objeto familiar y novedoso
% Varia entre 1  y -1. Puntuacion positiva indica mas tiempo explorando el
% objeto nuevo.
% Puntuacion negativa, indica mas tiempo explorando objeto familiar.
% Punutuacion  cero indica preferencia nula.
% ID = (tN - tF) / (tN + tF)
% 
tN =  sum(roi_N)*dt

tF = sum(roi_F)*dt

ID = (tN - tF) / (tN + tF)

%Calculo del indice de preferencia (IP)
% Proporcion de la cant de tiempo dedicado a explorar cualquiera de los
% objetos en cualquiera de las fases
% IP> 50% indica pref por objetos nuevos, 
% IP< 50% indica pref por objetos familiares, 
% IP=  50% no indica preferencia, 
% IP = (tN / (tN + tF))*100  o  (tF / (tN + tF))*100

IP_N = (tN / (tN + tF)) * 100
IP_F = (tF / (tN + tF)) * 100


%% FIGURAS

%Recorrido en la arena
figure(1)
plot(pos_x,pos_y)
title('Trajectory')
xlabel('pos x')
ylabel('pos y')

%% 
figure(2)
histogram2(pos_x,pos_y,50,'DisplayStyle','tile','ShowEmptyBins','on')
title('Heatmap')
colormap(gca,'parula')
%colormap(parula(100))
c=colorbar;
c.Label.String='Count';
xlabel('pos x')
ylabel('pos y')

%%

% Calculo de distancia recorrida. Como medida de exploracion. 
euclidean_distance = sqrt((diff(pos_x)).^2+(diff(pos_y)).^2);

%distancia total recorrida
distancia_total = sum(euclidean_distance,'omitnan');


%velocidad entre frames
vel=euclidean_distance./dt;
%velocidad promedio
vel_media=distancia_total./t_total;

%% 
figure(3)
%quiero poner el color de la velocidad, defino el colormap
color_range = linspace(10,1,length(vel)+1);
%marco la trayectoria con colores segun la velocidad
s = scatter(pos_x,pos_y,[],color_range','filled');
colorbar
colormap(parula(100))
title('Velocity')
xlabel('pos x')
ylabel('pos y')
%colormap(gca,'parula')
% 
% distfromzero = sqrt(pos_x.^2 + pos_y.^2);
% s.AlphaData = distfromzero;
% s.MarkerFaceAlpha = 'flat';


