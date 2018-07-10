function varargout = BrainMain(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrainMain_OpeningFcn, ...
                   'gui_OutputFcn',  @BrainMain_OutputFcn, ...
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

function BrainMain_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

guidata(hObject, handles);



function varargout = BrainMain_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
global brainImg
[filename pathname] = uigetfile({'*.jpg';'*.tif';'*.gif';'*.png'},'Select An Image');
brainImg = imread([pathname filename]);
axes(handles.axes1);
imshow(brainImg);
axis off
[m n c] = size(brainImg);
if c == 3
    brainImg  = rgb2gray(brainImg);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global brainImg
[ brainImg ] = Preprocess( brainImg );
axes(handles.axes2);
imshow(brainImg);
axis off


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global brainImg 
%*******************Segmentation***********************
brainImg = imresize(brainImg,[256 256]);
noclus = 4;
data = im2double(brainImg);
data = data(:);
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
tic
[center,U,obj_fcn] = clusterpixel(data,noclus); 
%&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
 
figure(2),
plot(obj_fcn);
title('Objective Function','fontsize',15,'fontname','monotype corsiva');
xlabel('Iteration','fontsize',15,'fontname','monotype corsiva');
ylabel('Cost Function','fontsize',15,'fontname','monotype corsiva');
maxU = max(U);
index1 = find(U(1,:) == maxU);
index2 = find(U(2,:) == maxU);
index3 = find(U(3,:) == maxU);
index4 = find(U(4,:) == maxU);
fcmImage(1:length(data))=0;       
fcmImage(index1)= 1;
fcmImage(index2)= 0.8;
fcmImage(index3)= 0.6;
fcmImage(index4)= 0.4;
imagNew = reshape(fcmImage,256,256);
segtime = toc;
axes(handles.axes3);
imshow(imagNew,[]);
 figure(3),
 imshow(imagNew,[]);
 title('Segmented Image');
colormap(jet)
axis off
% impixelinfo;
% set(handles.text4,'String',segtime);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global  brainImg TestImgFea imagNew
GLCM_mat = graycomatrix(imagNew,'Offset',[2 0;0 2]);
     
     GLCMstruct = Computefea(GLCM_mat,0);
     
     v1=GLCMstruct.contr(1);

     v2=GLCMstruct.corrm(1);

     v3=GLCMstruct.cprom(1);

     v4=GLCMstruct.cshad(1);

     v5=GLCMstruct.dissi(1);

     v6=GLCMstruct.energ(1);

     v7=GLCMstruct.entro(1);

     v8=GLCMstruct.homom1(1);

     v9=GLCMstruct.homop(1);

     v10=GLCMstruct.maxpr(1);

     v11=GLCMstruct.sosvh(1);

     v12=GLCMstruct.autoc(1);
     
     TestImgFea = [v1,v2,v3,v4,v5,v6,v7,v8];
set(handles.uitable1,'Data',TestImgFea);
set(handles.uitable1, 'ColumnName', {'Contrast', 'Correlation',....
        'Dissimilarity','Energy','Entropy','Homogeneity','Homop','Max.Prob',.....
        });
    set(handles.uitable1, 'RowName', {'Value'});


% --- Executes on button press in pushbutton5.

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton1.
function pushbutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
