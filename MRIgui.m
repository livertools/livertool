function varargout = MRIgui(varargin)
% MRIGUI MATLAB code for MRIgui.fig
%      MRIGUI, by itself, creates a new MRIGUI or raises the existing
%      singleton*.
%
%      H = MRIGUI returns the handle to a new MRIGUI or the handle to
%      the existing singleton*.
%
%      MRIGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MRIGUI.M with the given input arguments.
%
%      MRIGUI('Property','Value',...) creates a new MRIGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MRIgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MRIgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MRIgui

% Last Modified by GUIDE v2.5 25-Aug-2015 18:59:16
%---------------------------------------------------------------------------
% GUI desenvolvida por Yuri Ajala sob Orientação do Prof. Dr. Fernando Paiva
%-----------------  CIERMag - IFSC - USP ----------------------------------- 
%
%Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MRIgui_OpeningFcn, ...
                   'gui_OutputFcn',  @MRIgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --------------------------------------------------------------------
% Executa imediatamente antes da inteface MRIgui se tornar visível
% --------------------------------------------------------------------
function MRIgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MRIgui (see VARARGIN)

%Seta valores iniciais para os sliders

% set(handles.concl,'enable','off')
set(handles.slider5,'Value',1);
set(handles.slider6,'Value',1);
handles.nROI = 0;
handles.ft = get(handles.slider5,'Value');
handles.cancelTokenAntes = 0;
%cria atalhos para os conjuntos de botões (para set e get)
handles.naveg = [handles.slider5, handles.edit1, handles.slider6,...
                handles.edit2];
handles.defROI = [handles.retang, handles.circ, handles.polig,...
                handles.freeha];
handles.canceConcl = [handles.cancelar, handles.concl];            
handles.editROI = [handles.refaz, handles.excluir, handles.esconde,...
                handles.roiList];
handles.infoROI = [handles.popupmenu];
handles.abrir = [handles.File, handles.Open, handles.dicom,...
                handles.dicomEnhanced];
%Desativa tudo exceto o botão abrir
set([handles.naveg, handles.defROI, handles.editROI, handles.infoROI,...
    handles.canceConcl],'enable','off')


% Choose default command line output for MRIgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MRIgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MRIgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
% Callback para abrir arquivo DICOM
% --------------------------------------------------------------------
function dicom_Callback(hObject, eventdata, handles)
% hObject    handle to dicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Use UIGETFILE to allow for the selection of a custom dicom file.
[filename, pathname] = uigetfile( ...   %abre janela para selecionar arquivo
    {'*.dcm', 'All DICOM  Files (*.dcm)'; ...   %filtra por arquivos DICOM
        '*.*','All Files (*.*)'}, ...
    'Selecione os arquivos DICOM','MultiSelect', 'on');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    % Otherwise construct the fullfilename and Check and load the file.
else
    filename = sort(filename);
    for i=1:size(filename,2)
        File(i,:) = fullfile(pathname,filename{i});
    end
handles.File = File;

%Guarda imagens, header e informações específicas
 for i=1:size(File,1)
handles.mriFig(:,:,i) = dicomread (File(i,:)); %junta as partes de imagem dos arquivos
end
handles.mriInfo = dicominfo(File(1,:));      %pega a o header do primeiro arquivo
handles.cortesMax = handles.mriInfo.Private_2001_1018(1);   %numero de cortes
handles.ecosMax = handles.mriInfo.Private_2001_1014(1);     %numero de ecos
handles.altura = handles.mriInfo.Height;    %altura da imagem (numero de linhas da matriz)
handles.largura = handles.mriInfo.Width;    %largura da imagem (numero de colunas da matriz)
handles.FlipAngle = handles.mriInfo.FlipAngle; %flip angle
handles.MagneticField = handles.mriInfo.MagneticFieldStrength; %Intensidade do campo magnético do scanner
handles.FlipAngleRad = deg2rad(handles.FlipAngle); %flip angle em radianos
%Converte imagens para escala de cinza entre 0 e 1
handles.mriFig = mat2gray(handles.mriFig);
%reorganiza a matriz de imagens
handles.mriFig = reshape(handles.mriFig,[handles.altura handles.largura handles.ecosMax handles.cortesMax]);
%determina a imagem atual como a primeira
handles.current_Fig = handles.mriFig(:,:,1,1);
imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela

%cria string com as informações (todas retiradas do header)
infoStr = {['Patient               ', handles.mriInfo.PatientName.FamilyName],
           ['Study description    ', handles.mriInfo.StudyDescription], 
           ['Body part examined            ', handles.mriInfo.BodyPartExamined],
           ['Number of slices         ', num2str(handles.cortesMax)],
           ['Number of echoes           ', num2str(handles.ecosMax)],
           ['Flip angle            ', num2str(handles.FlipAngle)],
           ['Magnetic field (T)             ', num2str(handles.MagneticField)]
           };
set(handles.listbox3,'String',infoStr); %coloca a string na lista visível
           
%arruma o range dos sliders e posiciona em 1
set(handles.slider5,'Min',1);   %seta o valor mínimo
set(handles.slider5,'Max',handles.cortesMax); %seta o valor max baseado no header
Cmax = double(handles.cortesMax);   %estas equações determinam o step do slider. 
a = 1/(Cmax-1);                     %consulte SliderStep em Help (documento,não na janela de comando) para + info
b = 5*a;                            
set(handles.slider5,'SliderStep',[a b]);
set(handles.slider5,'Value',1);
set(handles.edit1,'String',1)

set(handles.slider6,'Min',1);
set(handles.slider6,'Max',handles.ecosMax);
Emax = double(handles.ecosMax);
c = 1/(Emax-1);
d = 5*c;
set(handles.slider6,'SliderStep',[c d]);
set(handles.slider6,'Value',1);     
set(handles.edit2,'String',1)

% limpa os dados do arquivo anterior, se houver
try
    for aux=1:handles.nROI
    clear handles.listaROIs{aux};
    end
vazioStr ='<vazio>';
set (handles.roiList,'String', vazioStr);
set (handles.popupmenu,'String', vazioStr);
tableData = [];                %esvazia as tabelas
colNames = {'Echo (s)','Intensity'};
set(handles.mainTable, 'Data', tableData, 'ColumnName', colNames);
tableData2 = [];                %escreve os dados na tabela de Resultados
colNames2 = {'Results'};
set(handles.resultsTable, 'Data', tableData2, 'ColumnName', colNames2);
set(handles.text13, 'String', vazioStr); %escreve o valor de R-squared
plot(handles.axes2,0);
catch
end
handles.nROI = 0;

%reativa todos os botões exceto canceConcl:
set([handles.naveg, handles.defROI, handles.infoROI,...
    handles.abrir],'enable','on')
set(handles.canceConcl,'enable','off')

% Update handles structure
guidata(hObject, handles);
end



% ------------------------------------------------------------
% Callback para abrir DICOM Enhanced
% ------------------------------------------------------------
function dicomEnhanced_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Use UIGETFILE to allow for the selection of a custom dicom file.
[filename, pathname] = uigetfile( ...   %abre janela para selecionar arquivo
    {'*.dcm', 'All DICOM  Files (*.dcm)'; ...   %filtra por arquivos DICOM
        '*.*','All Files (*.*)'}, ...
    'Selecione o arquivo DICOM Enhanced');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
    return
    % Otherwise construct the fullfilename and Check and load the file.
else
    File = fullfile(pathname,filename); %guarda o arquivo completo em 'file'

%Guarda imagens, header e informações específicas    
handles.mriFig = dicomread(File);       %pega a parte de imagem do arquivo
handles.mriInfo = dicominfo(File);      %pega a o header do arquivo
handles.cortesMax = handles.mriInfo.Private_2001_1018(1);   %numero de cortes
handles.ecosMax = handles.mriInfo.Private_2001_1014(1);     %numero de ecos
handles.altura = handles.mriInfo.Height;    %altura da imagem (numero de linhas da matriz)
handles.largura = handles.mriInfo.Width;    %largura da imagem (numero de colunas da matriz)
handles.FlipAngle = handles.mriInfo.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.FlipAngle; %flip angle
handles.MagneticField = handles.mriInfo.MagneticFieldStrength;
handles.FlipAngleRad = deg2rad(handles.FlipAngle); %flip angle em radianos
%Converte imagens para escala de cinza entre 0 e 1
handles.mriFig = mat2gray(handles.mriFig);
%reorganiza a matriz de imagens
handles.mriFig = reshape(handles.mriFig,[handles.altura handles.largura handles.ecosMax handles.cortesMax]);
%determina a imagem atual como a primeira
handles.current_Fig = handles.mriFig(:,:,1,1);
imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela

%cria string com as informações (todas retiradas do header)
infoStr = {['Patient               ', handles.mriInfo.PatientName.FamilyName],
           ['Study description    ', handles.mriInfo.StudyDescription], 
           ['Body part examined            ', handles.mriInfo.BodyPartExamined],
           ['Number of slices         ', num2str(handles.cortesMax)],
           ['Number of echoes           ', num2str(handles.ecosMax)],
           ['Flip angle            ', num2str(handles.FlipAngle)],
           ['Magnetic field (T)             ', num2str(handles.MagneticField)]
           };
set(handles.listbox3,'String',infoStr); %coloca a string na lista visível
           
%arruma o range dos sliders e posiciona em 1
set(handles.slider5,'Min',1);   %seta o valor mínimo
set(handles.slider5,'Max',handles.cortesMax); %seta o valor max baseado no header
Cmax = double(handles.cortesMax);   %estas equações determinam o step do slider. 
a = 1/(Cmax-1);                     %consulte SliderStep em Help (documento,não na janela de comando) para + info
b = 5*a;                            
set(handles.slider5,'SliderStep',[a b]);
set(handles.slider5,'Value',1);
set(handles.edit1,'String',1)

set(handles.slider6,'Min',1);
set(handles.slider6,'Max',handles.ecosMax);
Emax = double(handles.ecosMax);
c = 1/(Emax-1);
d = 5*c;
set(handles.slider6,'SliderStep',[c d]);
set(handles.slider6,'Value',1);     
set(handles.edit2,'String',1)

% limpa os dados do arquivo anterior, se houver
try
    for aux=1:handles.nROI
    clear handles.listaROIs{aux};
    end
vazioStr ='<vazio>';
set (handles.roiList,'String', vazioStr);
set (handles.popupmenu,'String', vazioStr);
tableData = [];                %esvazia as tabelas
colNames = {'Echo (s)','Intensity'};
set(handles.mainTable, 'Data', tableData, 'ColumnName', colNames);
tableData2 = [];                %escreve os dados na tabela de Resultados
colNames2 = {'Results'};
set(handles.resultsTable, 'Data', tableData2, 'ColumnName', colNames2);
set(handles.text13, 'String', vazioStr); %escreve o valor de R-squared
plot(handles.axes2,0);
catch
end
handles.nROI = 0;

%reativa todos os botões exceto canceConcl:
set([handles.naveg, handles.defROI, handles.infoROI,...
    handles.abrir],'enable','on')
set(handles.canceConcl,'enable','off')


% Update handles structure
guidata(hObject, handles);
end

% ------------------------------------------------------------
% Callback para SLIDER DE ESCOLHA DE CORTE
% ------------------------------------------------------------

function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
  
  
  NewVal = get(hObject,'Value');    % pega o novo valor de cortes do slider
  NewVal = round(NewVal);           % arredonda para um número inteiro
  handles.ft = NewVal;              %corte atual
  ec = get(handles.slider6,'Value');%pega o valor de eco do slider de ecos
  handles.ec = round(ec);           %arredonda e armazena o valor do eco
 % Muda o valor do campo mostrador de corte (edit1) para o novo valor atual
  set(handles.edit1,'String',NewVal)
 % encontra a matriz de saída (imagem no corte e eco desejados)na matriz 4D
      handles.current_Fig = handles.mriFig(:,:,handles.ec,handles.ft); 
      
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end
      
   % Update handles structure
guidata(hObject, handles);
  

  
  

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% ------------------------------------------------------------
% Callback para SLIDER DE ECO
% ------------------------------------------------------------

function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


  NewVal = get(hObject,'Value');    % pega o novo valor de cortes do slider
  NewVal = round(NewVal);           % arredonda para um número inteiro
  handles.ec = NewVal;              % eco atual
  ft = get(handles.slider5,'Value');%pega o valor de corte do slider de cortes
  handles.ft = round(ft);           %arredonda e armazena o valor do corte
  % Muda o valor do campo mostrador de eco (edit2) para o novo valor atual
  set(handles.edit2,'String',NewVal)
% encontra a matriz de saída (imagem no corte e eco desejados)na matriz 4D
   handles.current_Fig = handles.mriFig(:,:,handles.ec,handles.ft); 
   
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end
   
   % Update handles structure
guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ------------------------------------------------------------
% Callback para Mostrador do valor do Corte Atual
% ------------------------------------------------------------
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

  NewStrVal = get(hObject,'String');    %pega o novo valor do corte
  NewVal = str2double(NewStrVal);       %muda de string para double
  NewVal = round(NewVal);               %arredonda para inteiro

  %checa se o novo valor está dentro dos limites aceitáveis
  if  isempty(NewVal) || (NewVal< 1) || (NewVal> handles.cortesMax),
    % caso negativo, reverte para o valor que está no slider5, de corte
    OldVal = get(handles.slider5,'Value'); %pega o valor do slider5
    OldVal = round(OldVal);                %arredonda
    set(hObject,'String',OldVal)           %seta no campo do mostrador
    ec = get(handles.slider6,'Value'); %pega o valor do slider dos ecos
    handles.ec = round(ec);            %arredonda
    handles.ft = OldVal;               %guarda o valor das fatias
    %econtra a imagem correspondente na matriz 4D
    handles.current_Fig = handles.mriFig(:,:,handles.ec,handles.ft);  
    
    
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end
    


  else %caso esteja dentro dos limites aceitáveis
    set(handles.slider5,'Value',NewVal);    % muda o valor do slider de cortes (slider5) para o valor digitado
    handles.ft = NewVal;                    % passa para a variável de cortes (handles.ft) o valor digitado
    ec = get(handles.slider6,'Value');      % pega o valor atual dos ecos
    handles.ec = round(ec);                 % arredonda
    handles.current_Fig = handles.mriFig(:,:,handles.ec,handles.ft);  %encontra o corte e eco
    
    
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end
     
    
  end
  % Update handles structure
guidata(hObject, handles);

  
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%-----------------------------------------------------
%-Callback para Mostrador do valor do Eco Atual
%-----------------------------------------------------
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

  NewStrVal = get(hObject,'String');    %pega o novo valor do eco
  NewVal = str2double(NewStrVal);       %muda de string para double
  NewVal = round(NewVal);               %arredonda para inteiro
  
  % verifica se o novo valor está dentro dos valores aceitáveis
  if  isempty(NewVal) || (NewVal< 1) || (NewVal> handles.ecosMax),
    % caso negativo, reverte para o valor que está no slider6, de ecos
    OldVal = get(handles.slider6,'Value');  %pega o valor do slider de ecos
    OldVal = round(OldVal);                 %arredonda
    set(hObject,'String',OldVal);           %coloca no mostrador
    handles.ec = OldVal;                    %coloca na variável
    ft = get(handles.slider5,'Value');      %pega o valor do slider de cortes
    handles.ft = round(ft);                 %arredonda e coloca na variável
    handles.current_Fig = handles.mriFig(:,:,handles.ec,handles.ft); %encontra o corte e eco desejados 
    
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end
    
    
  else %caso esteja dentro dos limites aceitáveis
    set(handles.slider6,'Value',NewVal) %muda o slider de ecos (slider6) para o novo valor
    handles.ec = NewVal;                %armazena na variável de eco atual o novo valor
    ft = get(handles.slider5,'Value');  %pega o valor atual do slider de cortes
    handles.ft = round(ft);             %arredonda o valor
    handles.current_Fig = handles.mriFig(:,:,handles.ec,handles.ft); %encontra o corte e eco desejados 
    
    
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            a = 1;
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end
    
    
  end
  % Update handles structure
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-----------------------------------------------------
%-Botões de criação de ROI
%-----------------------------------------------------
% --- Executes on button press in retang.
function retang_Callback(hObject, eventdata, handles)
% hObject    handle to retang (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%desativa as outras formas de criação
set([handles.circ,...
    handles.polig,...
    handles.freeha],'enable','off');
%deixa o botao atual inativo
set(handles.retang, 'enable','inactive');
set([handles.naveg, handles.editROI, handles.infoROI,...
    handles.abrir, handles.concl],'enable','off')
set(handles.cancelar,'enable','on')

handles.roi = imrect(handles.axes1);
%verifica o estado dos botões: se houve cancelamento, estarão inativos
aux = get (handles.canceConcl,'enable');
%se houve cancelamento, desativa o botão concluir
if strcmp(aux,{'off';'off'})
    set(handles.concl,'enable','off')
    guidata(hObject, handles);
%se não, habilita para que o usuário conclua a ROI    
else
    % Update handles structure
    set(handles.concl,'enable','on')
    guidata(hObject, handles);
end


% --- Executes on button press in circ.
function circ_Callback(hObject, eventdata, handles)
% hObject    handle to circ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set([handles.retang,...
    handles.polig,...
    handles.freeha],'enable','off')
%deixa o botao atual inativo
set(handles.circ, 'enable','inactive');
set([handles.naveg, handles.editROI, handles.infoROI,...
    handles.abrir, handles.concl],'enable','off')
set(handles.cancelar,'enable','on')

handles.roi = imellipse(handles.axes1);
%verifica o estado dos botões: se houve cancelamento, estarão inativos
aux = get (handles.canceConcl,'enable');
%se houve cancelamento, desativa o botão concluir
if strcmp(aux,{'off';'off'})
    set(handles.concl,'enable','off')
    guidata(hObject, handles);
%se não, habilita para que o usuário conclua a ROI    
else
    % Update handles structure
    set(handles.concl,'enable','on')
    guidata(hObject, handles);
end


% --- Executes on button press in polig.
function polig_Callback(hObject, eventdata, handles)
% hObject    handle to polig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set([handles.circ,...
    handles.retang...
    handles.freeha],'enable','off')
%deixa o botao atual inativo
set(handles.polig, 'enable','inactive');
set([handles.naveg, handles.editROI, handles.infoROI,...
    handles.abrir, handles.concl],'enable','off')
set(handles.cancelar,'enable','on')

handles.roi = impoly(handles.axes1);
   
%verifica o estado dos botões: se houve cancelamento, estarão inativos
aux = get (handles.canceConcl,'enable');
%se houve cancelamento, desativa o botão concluir
if strcmp(aux,{'off';'off'})
    set(handles.concl,'enable','off')
    guidata(hObject, handles);
%se não, habilita para que o usuário conclua a ROI    
else
    % Update handles structure
    set(handles.concl,'enable','on')
    guidata(hObject, handles);
end


% --- Executes on button press in freeha.
function freeha_Callback(hObject, eventdata, handles)
% hObject    handle to freeha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%desativa as outras formas e botões do painel, deixa o botão da forma usada 
%indisponível,ativa cancelar, e desativa concluir até que termine o desenho
set([handles.circ,...
    handles.retang,...
    handles.polig],'enable','off')
set([handles.naveg, handles.editROI, handles.infoROI,...
    handles.abrir, handles.concl],'enable','off')
set(handles.cancelar,'enable','on')
set(handles.freeha, 'enable','inactive');
%termina de desenhar
handles.roi = imfreehand(handles.axes1);
%verifica o estado dos botões: se houve cancelamento, estarão inativos
aux = get (handles.canceConcl,'enable');
%se houve cancelamento, desativa o botão concluir
if strcmp(aux,{'off';'off'})
    set(handles.concl,'enable','off')
    guidata(hObject, handles);
%se não, habilita o botão concluir para que o usuário conclua a ROI    
else
    % Update handles structure
    set(handles.concl,'enable','on')
    guidata(hObject, handles);
end



% --- Executes on button press in cancelar.
function cancelar_Callback(hObject, eventdata, handles)
% hObject    handle to cancelar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%busca por ROIs já construídas para retornar às imagens com os desenhos
try
    set(gcf,'CurrentAxes',handles.axes1);
    listaROIs = handles.listaROIs;
    nROI = handles.nROI;
    imshow(handles.current_Fig, 'Parent', handles.axes1); %mostra a figura na tela
  
    for aux=1:nROI
        slice = handles.(listaROIs{aux}).corte;
        if handles.ft==slice
            color = handles.(listaROIs{aux}).color;
            a = patch(handles.(listaROIs{aux}).pos(:,1),handles.(listaROIs{aux}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
            set (a, 'Visible', 'on')
        end
    end
catch
     imshow(handles.current_Fig, 'Parent', handles.axes1) %mostra a figura na tela
end

%reativa os botões
%Reativa tudo exceto o botão concluir e cancelar. Essa combinação desligada
%sinaliza que o botão cancelar foi apertado.
set([handles.naveg, handles.defROI, handles.infoROI,...
    handles.abrir],'enable','on')
set(handles.canceConcl,'enable','off')

 % Update handles structure
guidata(hObject, handles);





%-----------------------------------------------------
%-Conclui criação e inicia análise da ROI
%-----------------------------------------------------
%% botão Concluir
function concl_Callback(hObject, eventdata, handles)
% hObject    handle to concl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Os seguintes dados de uma ROI são coletados no endereço handles.ROI_n:
%  handles.ROI_n.pos        Posição da ROI
%               .color      Cor da ROI, RGB  0 a 1
%               .corte      Corte em que se encontra a ROI  
%               .line       Desenho final da ROI
%               .mask       Máscara da ROI (0s fora e 1s dentro)
%               .Vm         Valores médios das ROIs nos ecos
%               .Tecos      Tempos dos ecos
%               .FF         Fat Factor (obtido pelo fitting mas fora do diretório do fitting)
%               .fitresult  Resultado do fitting      
%               .fitresult.Pw   Rho water
%               .fitresult.Pf   Rho fat
%               .fitresult.T2   T2 decay
%               .fitresult.k    constante K que multiplica o flip angle
%               .fitresult.c1   c1 constant
%               .fitresult.c2
%               .fitresult.c3

%Para escrever na ROI atual, utilizar 'handles.(listaROIs{nROI})...'

handles.nROI =  handles.nROI+1; %aumenta o contador
handles.ft = round(get(handles.slider5,'Value'));  %atualiza o valor do corte atual (será utilizado diversas vezes)

%% - Construção do diretório da ROI
nROI = handles.nROI;    %atalho para número da ROI atual
handles.listaROIs{nROI} = sprintf('ROI_%d', nROI);  %nome das ROIs que contém seus dados
listaROIs = handles.listaROIs;  %atalho para o nome das ROIs, para não escrever handles.(handles.listaROIs...)

%% - Obtenção de informações básicas sobre a ROI
handles.(listaROIs{nROI}).pos = getPosition (handles.roi);  %armazena os dados de posição da ROI
handles.(listaROIs{nROI}).color = getColor (handles.roi);   %armazena a cor da ROI atual
handles.(listaROIs{nROI}).corte = handles.ft;               %armazena o corte da ROI atual
color = getColor (handles.roi);                             %atalho para a cor atual da ROI
    %-converte a cor da ROI para RGB HEX  
    colorR = num2str(dec2hex(round(color(1)*255)));
    colorG = num2str(dec2hex(round(color(2)*255)));
    colorB = num2str(dec2hex(round(color(3)*255)));
    colorHEX = strcat(colorR,colorG,colorB);
    %- fim da conversão 
 
%% - Construção do formato da ROI fixa após a conclusão do desenho
try
    handles.(listaROIs{nROI}).pos = getVertices (handles.roi);  %constrói a elipse, se a ROI for uma elipse
    handles.(listaROIs{nROI}).line = patch(handles.(listaROIs{nROI}).pos(:,1),handles.(listaROIs{nROI}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
catch
    
        if size (handles.(listaROIs{nROI}).pos) == [1 4]    %constrói o retângulo, se a ROI for um retângulo
            handles.(listaROIs{nROI}).pos = [handles.(listaROIs{nROI}).pos(1) handles.(listaROIs{nROI}).pos(2);...
                                             handles.(listaROIs{nROI}).pos(1) handles.(listaROIs{nROI}).pos(2)+handles.(listaROIs{nROI}).pos(4);... 
                                             handles.(listaROIs{nROI}).pos(1)+handles.(listaROIs{nROI}).pos(3) handles.(listaROIs{nROI}).pos(2)+handles.(listaROIs{nROI}).pos(4);... 
                                             handles.(listaROIs{nROI}).pos(1)+handles.(listaROIs{nROI}).pos(3) handles.(listaROIs{nROI}).pos(2)];
            handles.(listaROIs{nROI}).line = patch(handles.(listaROIs{nROI}).pos(:,1),handles.(listaROIs{nROI}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
        else                                                %contrói outras formas, se a ROI o for
        handles.(listaROIs{nROI}).line = patch(handles.(listaROIs{nROI}).pos(:,1),handles.(listaROIs{nROI}).pos(:,2),color, 'FaceColor', 'none', 'EdgeColor', color);
        end
end

%% - Obtenção da máscara da ROI na imagem
BW = createMask(handles.roi);               %cria máscara baseada na ROI (1's dentro da área selecionada, 0's fora)
handles.(listaROIs{nROI}).mask (:,:,handles.nROI) = BW(:,:); %salva a máscara no diretório da ROI
BW = double(BW);                            %converte binário->double
delete(handles.roi);                        %deleta a instância da ferramenta interativa atual

%% - Obtenção do valor de intensidade média da ROI para cada eco
k= 1;
for ec=1:handles.ecosMax                    %para cada '1' da máscara, pega o ponto correspondente da imagem original
    for i=1:handles.mriInfo.Height          %e salva em um vetor V. Repete para cada eco, salvando em colunas diferentes
        for j=1:handles.mriInfo.Width       %assim obtém-se os valores das regiões selecionadas, para qualquer formato
            if BW(i,j) ~= 0
            V(k,ec)= handles.mriFig(i,j,ec, handles.ft);
            k = k+1;
            end
        end
    end
end
try
    Vm = mean(V);                                %computa a média de cada coluna, portanto a média de cada eco

catch  %Caso a ROI não tenha uma área (um ponto ou uma linha)
    errordlg('A ROI deve ter área calculável. Clique em "Cancelar" e refaça.','Erro')
    if handles.nROI>0
        handles.nROI = handles.nROI-1; %decresce o contador sem ficar menor que zero
    end
    set(handles.concl,'enable','off')
    
    return
    
end
Vm = Vm';
handles.(listaROIs{nROI}).Vm = Vm;

%% - Obtenção dos TE pelo arquivo DICOM
for n = 1:handles.ecosMax
echoNumber(n,:) = sprintf('Item_%d',n);     %escreve o texto Item_1, Item_2.. a ser utilizado no endereçamento dos ecos
end

try %Obtem os valores dos tempos de cada eco
    for n = 1:handles.ecosMax   %caso dicomEnhanced
    Tecos(n,1) = handles.mriInfo.PerFrameFunctionalGroupsSequence.(echoNumber(n,:)).Private_2005_140f.Item_1.EchoTime;
    end
catch                           %caso dicom simples
    for n = 1:handles.ecosMax
       InfoAux = dicominfo(handles.File(n,:));
    Tecos(n,1) = InfoAux.EchoTime;
    end
end

Tecos = Tecos*0.001;
handles.(listaROIs{nROI}).Tecos = Tecos;


%% - Fitting dos pontos Vm x TE 

Tesla = handles.MagneticField;


if handles.ecosMax > 2 % multi-interferência
    [xData, yData] = prepareCurveData(Tecos, Vm);
    handles.(listaROIs{nROI}).xData = xData;
    handles.(listaROIs{nROI}).yData = yData;
    
    ft = fittype( 'abs(Pw + Pf *(0.12*exp(2*pi*i*(4.7-2.1)*Tesla*42.576*x)+0.792*exp(2*pi*i*(4.7-1.3)*Tesla*42.576*x)+0.088*exp(2*pi*i*(4.7-0.9)*Tesla*42.576*x)))*exp(-x/T2)', 'independent', 'x', 'dependent', 'y', 'problem', {'Tesla'});

    opts = fitoptions( ft );
    opts.Algorithm = 'Trust-Region';
    opts.Display = 'Off';
    opts.Lower = [-1 -1 0]; %Pf, Pw, T2
    opts.MaxIter = 1500;
    opts.StartPoint = [0.5 0.5 0.02];
    opts.Upper = [1 1 1];

    [fitresult, gof] = fit( xData, yData, ft, opts,'problem',{Tesla});
    FF = 100*fitresult.Pf/(fitresult.Pf+fitresult.Pw);
    results = {
    ['%FF:   ', num2str(FF)]
    ['Pw:    ', num2str(fitresult.Pw)]
    ['Pf:    ', num2str(fitresult.Pf)]
    ['T2:    ', num2str(fitresult.T2)]
    ['Method: Multi-interferência']
    };
    handles.(listaROIs{nROI}).fitresult = fitresult;
    handles.(listaROIs{nROI}).gof = gof;

else    %dixon
    Pw = (Vm(2) + Vm(1)) / 2;
    Pf = (Vm(2) - Vm(1)) / 2;
    
    FF = 100*Pf/(Pf+Pw);
    
    gof.rsquare = 1;
    fitresult.Pw = Pw;
    fitresult.Pf = Pf;
        
    results = {
    ['%FF:   ', num2str(FF)]
    ['Pw:    ', num2str(Pw)]
    ['Pf:    ', num2str(Pf)]
    ['Method: Dixon']
    };
    handles.(listaROIs{nROI}).fitresult = fitresult;
    handles.(listaROIs{nROI}).gof = gof;
end
% 
% % Fit model to data.
% [fitresult, gof] = fit( xData, yData, ft, opts,'problem',{FlipAngle, Tesla});
% FF = 100*fitresult.Pf/(fitresult.Pf+fitresult.Pw);
% FF2 = 100-FF;
% if handles.ecosMax >= 7
%  results = {
%     ['%FF:   ', num2str(FF)]
%     ['Pw:    ', num2str(fitresult.Pw)]
%     ['Pf:    ', num2str(fitresult.Pf)]
%     ['T2:    ', num2str(fitresult.T2)]
%     ['k:    ', num2str(fitresult.k)]
%     ['c1:    ', num2str(fitresult.c1)]
%     ['c2:    ', num2str(fitresult.c2)]
%     ['c3:    ', num2str(fitresult.c3)]
%     };
% elseif (2<handles.ecosMax)&&(handles.ecosMax<7)
%  results = {
%     ['%FF:   ', num2str(FF)]
%     ['Pw:    ', num2str(fitresult.Pw)]
%     ['Pf:    ', num2str(fitresult.Pf)]
%     ['T2:    ', num2str(fitresult.T2)]
%     };  
% elseif handles.ecosMax <= 2
%     results = {
%     ['%FF:   ', num2str(FF)]
%     ['1-%FF: ', num2str(FF2)]
%     ['Pw:    ', num2str(fitresult.Pw)]
%     ['Pf:    ', num2str(fitresult.Pf)]
%     };
% end
% 
% 
handles.(listaROIs{nROI}).FF = FF;
handles.(listaROIs{nROI}).results = results;

%% - Plota o(s) gráfico(s) 

try
    for aux=1:(nROI-1) %replota ROIs anteriores
        set(gcf,'CurrentAxes',handles.axes2);
        h = plot(handles.(listaROIs{aux}).fitresult, handles.(listaROIs{aux}).xData, handles.(listaROIs{aux}).yData); %essa função plot é especial do cfit e não aceita parâmetros comuns da função plot
        set (h, 'Color', handles.(listaROIs{aux}).color, 'LineWidth', 0.5);
        xlabel('Time to echo (s)');
        ylabel('Intensity [0 1]');
        grid on
        hold on
        handles.(listaROIs{aux}).graph = h;
    end
     set(gcf,'CurrentAxes',handles.axes2);
     h = plot(handles.(listaROIs{nROI}).fitresult, xData, yData); %plota ROI atual
     set (h, 'Color', handles.(listaROIs{nROI}).color, 'LineWidth', 1.5);
     xlabel('Time to echo (s)');
     ylabel('Intensity [0 1]');
     grid on
     legend('hide')
     hold off
     handles.(listaROIs{nROI}).graph = h;
catch
    if handles.ecosMax > 2 % multi-interferência
     set(gcf,'CurrentAxes',handles.axes2);
        h = plot(handles.(listaROIs{nROI}).fitresult, xData, yData); %essa função plot é especial do cfit e não aceita parâmetros comuns da função plot
        grid on
        set (h, 'Color', handles.(listaROIs{nROI}).color, 'LineWidth', 1.5);
        xlabel('Time to echo (s)');
        ylabel('Intensity [0 1]');
        legend('hide')
        handles.(listaROIs{nROI}).graph = h;
    else
        h = plot(Tecos, Vm);
        grid on
        set (h, 'Color', handles.(listaROIs{nROI}).color, 'LineWidth', 1.5);
        xlabel('Time to echo (s)');
        ylabel('Intensity [0 1]');
        legend('hide')
        handles.(listaROIs{nROI}).graph = h;      
    
    end
end
%% - Escreve dados Estatísticos
set (handles.popupmenu, 'Value', nROI);
set (handles.roiList, 'Value', nROI);
tableData = [Tecos Vm];                %escreve os dados na tabela de TE x Vm
colNames = {'Echo (s)','Intensity'};
set(handles.mainTable, 'Data', tableData, 'ColumnName', colNames);
tableData2 = [results];                %escreve os dados na tabela de Resultados
colNames2 = {'Results'};
set(handles.resultsTable, 'Data', tableData2, 'ColumnName', colNames2);
set(handles.text13, 'String', gof.rsquare); %escreve o valor de R-squared

%% - Colore fontes de acordo com a cor da ROI
% - a partir daqui, o valor handles.listaROIs{nROI} vira código HTML, e não 
% pode mais ser utilizado como indicador de endereçamento para handles.ROI_n
handles.ROIstr1{nROI} = sprintf('<HTML><FONT color="%s">ROI_%d',colorHEX, nROI);  % atualiza para colorido
set(handles.popupmenu,'String',handles.ROIstr1);      %cria o menu popup colorido
handles.ROIstr2{nROI} = sprintf('<HTML><FONT color="%s"> ROI %d, Slice %d',colorHEX, nROI,handles.ft);    %cria a string com a lista colorida de ROIs
set(handles.roiList,'String',handles.ROIstr2);                           %preenche a lista com a string anterior

%% - Reativa todos os botões
set([handles.naveg, handles.defROI, handles.infoROI,...
    handles.abrir],'enable','on')
%Desativa cancelar e concluir
set(handles.canceConcl,'enable','off')




handles.listaROIs = listaROIs;
% Update handles structure
guidata(hObject, handles);






% --- Executes on selection change in roiList.
function roiList_Callback(hObject, eventdata, handles)
% hObject    handle to roiList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SelectedROI = cellstr(get(hObject,'Value'));
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns roiList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roiList


% --- Executes during object creation, after setting all properties.
function roiList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refaz.
function refaz_Callback(hObject, eventdata, handles)
% hObject    handle to refaz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in excluir.
function excluir_Callback(hObject, eventdata, handles)
% hObject    handle to excluir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in esconde.
function esconde_Callback(hObject, eventdata, handles)
% hObject    handle to esconde (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of esconde


% --- Executes on selection change in popupmenu.
function popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
listaROIs = handles.listaROIs;
nROI = get(hObject,'Value');
Tecos = handles.(listaROIs{nROI}).Tecos;
Vm = handles.(listaROIs{nROI}).Vm;
results = handles.(listaROIs{nROI}).results;

tableData = [Tecos Vm];                %escreve os dados na tabela de TE x Vm
colNames = {'Echo (s)','Intensity'};
set(handles.mainTable, 'Data', tableData, 'ColumnName', colNames);
tableData2 = results;                %escreve os dados na tabela de Resultados
colNames2 = {'Results'};
set(handles.resultsTable, 'Data', tableData2, 'ColumnName', colNames2);
set(handles.text13, 'String', handles.(listaROIs{nROI}).gof.rsquare); %escreve o valor de R-squared

for aux = 1:handles.nROI
    set (handles.(listaROIs{aux}).graph, 'LineWidth', 0.5);
end
set (handles.(listaROIs{nROI}).graph, 'LineWidth', 1.5);





% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu


% --- Executes during object creation, after setting all properties.
function popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
