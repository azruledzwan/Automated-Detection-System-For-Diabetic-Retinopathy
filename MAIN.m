function varargout = MAIN(varargin)
% MAIN MATLAB code for MAIN.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAIN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAIN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAIN

% Last Modified by GUIDE v2.5 30-Mar-2021 20:40:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAIN_OpeningFcn, ...
                   'gui_OutputFcn',  @MAIN_OutputFcn, ...
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


% --- Executes just before MAIN is made visible.
function MAIN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAIN (see VARARGIN)

% Choose default command line output for MAIN
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAIN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MAIN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ah = axes('unit', 'normalized', 'position', [0 0 1 1]); 
% import the background image and show it on the axes
bg = imread('bg.jpg'); imagesc(bg);
% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')
% making sure the background is behind all the other uicontrols
uistack(ah, 'bottom');
% Get default command line output from handles structure


text(handles.axes11,.5,.5,'ORIGINAL IMAGE','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes13,.5,.5,'PROCESS IMAGE','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes15,.5,.5,'RESULT','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes16,.5,.5,'HARD EXUDATES','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes17,.5,.5,'DIABETIC RETINOPATHY STAGES','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes18,.5,.5,'SENSITIVITY','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes20,.5,.5,'F-SCORE','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');
text(handles.axes21,.5,.5,'ACCURACY','FontSize', 10,...
    'HorizontalAlignment','Center','VerticalAlignment', 'middle');

set(handles.axes1,'xtick',[]);
set(handles.axes1,'ytick',[]);
set(handles.axes1,'xcolor',[1 1 1])
set(handles.axes1,'ycolor',[1 1 1])

set(handles.axes5,'xtick',[]);
set(handles.axes5,'ytick',[]);
set(handles.axes5,'xcolor',[1 1 1])
set(handles.axes5,'ycolor',[1 1 1])


set(handles.axes8,'xtick',[]);
set(handles.axes8,'ytick',[]);
set(handles.axes8,'xcolor',[1 1 1])
set(handles.axes8,'ycolor',[1 1 1])

varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global ori    
global pathname
global filename

    
    uiwait(helpdlg('You can only upload JPG, JPEG, PNG files. Click OK to continue','Message from system'));
    [filename,pathname]=uigetfile({'*.jpg;*.jpeg;*.png'}, 'File Selector');
original = filename;
if pathname == 0
   % User clicked cancel. Bail out.
   return;
end
ori = imread([pathname,filename]);
axes(handles.axes1);
imshow(ori);



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles) %preprocess
global ori
global green
global filterImage
global total
global img
global Lrgb
global mask
global J

if isempty(ori)
    errordlg('Image not found to perform this process. Please select and process the image','Invalid File');
else  
    
    green = ori(:, :, 2); % Take green channel.
    
    image = green;
    se = strel('disk',30);
    tophat = imtophat(image,se); % apply top hat and bottom hat filter
    bottomhat = imbothat(image,se);
    filterImage = image + (tophat - bottomhat); %combine filter image

    se = strel('disk',15); %threshold

    tophat = imtophat(filterImage,se); %double apply tophat
    bottomhat = imbothat(filterImage,se);
%     filterImage = filterImage + (tophat - bottomhat);
    
    image = green;
    total = numel(image);
    % apply top hat and bottom hat filter
    se = strel('disk',30);
    tophat = imtophat(image,se);
    bottomhat = imbothat(image,se);
    filterImage = image + (tophat - bottomhat);
    se = strel('disk',15);
    tophat = imtophat(filterImage,se);
    bottomhat = imbothat(filterImage,se);
    filterImage = filterImage + (tophat - bottomhat);
    % calculate histogram of filtered image
    % estimate more than 78.5% area is background (pi/4 = .785)
    [counts,x] = imhist(filterImage);
    ssum = cumsum(counts);
    bg = .215*total;
    fg = .99*total;
    low = find(ssum>bg, 1, 'first');
    high = find(ssum>fg, 1, 'first');
    adjustedImage = imadjust(filterImage, [low/255 high/255],[0 1],1.8);
    adjustedImage = imclearborder(adjustedImage);
    % image binarization, threshold is choosen based on experience
    if(nargin < 2)
        matrix = reshape(adjustedImage,total,1);
        matrix = sort(matrix);
        threshold = graythresh(matrix(total*.5:end));
    end
    binarization = im2bw(adjustedImage);
    % open image and then detect edge using laplacian of gaussian
    se2 = strel('disk',5);
    afterOpening  = imopen(binarization,se2);
    % nsize = 6; sigma = 3;
    % h = fspecial('log',nsize,sigma);
    % afterLoG = uint8(imfilter(double(afterOpening)*255,h,'same').*(sigma^2)); 

    se2 = strel('disk',5);
    afterOpening = imopen(binarization,se2);
    % you can either use watershed method to do segmentation
    D = -bwdist(~afterOpening);
    D(~afterOpening) = -Inf;
    D = medfilt2(D,[5 5]); %median filtering
    L = watershed(D);
    Lrgb = label2rgb(L);
    


    se = strel('disk',5);
    C = imerode(afterOpening,se);

    se = strel('disk',10);
    C1 = imdilate(C,se);

    count = bwconncomp(C1,4); %coding count 
    num = count.NumObjects;

    img = imcomplement(C1);
    mask = bsxfun(@times, ori, cast(C1, 'like', ori));
    M = repmat(all(~mask,3),[1 1 3]);
    mask(M) = 255; %turn them white
    text = 'Total count of HEs : ';
    text2 = num2str(num);
    text3 = [text,text2];
    
    h = waitbar(0,'Please wait while the image is being processed...');
    steps = 2000;
    for step = 1:steps
        % computations take place here
        waitbar(step / steps)
    end
    close(h)
    
%     imshow(green,'Parent',handles.axes6);  
    imshow(filterImage,'Parent',handles.axes5); 
%     imshow(Lrgb,'Parent',handles.axes7);
    J = insertText(mask,[5 5],text3,'FontSize',85,'TextColor','black','BoxColor','white');
    imshow(J,'Parent',handles.axes8); 

    
    %points = detectBRISKFeatures(img);
    set(handles.edit5, 'string', num, 'enable', 'inactive');

    % c.LineWidth = 1;
    % g = imnoise(Lrgb, 'salt & pepper', 0.02);
    % [Accuracy, Sensitivity] = EvaluateImageSegmentationScores(Lrgb, g);
    % set(handles.edit5,'String', b);

    if (num>=0 && num<=22)
        set(handles.edit7, 'String', 'NORMAL', 'enable', 'inactive');
    elseif (num>=23 && num<=40)
        set(handles.edit7, 'String', 'NPDR', 'enable', 'inactive');
    elseif (num>=41)
        set(handles.edit7, 'String', 'PDR', 'enable', 'inactive');
    else
        disp('Error')
    end 
end





% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)%PERFORMANCE METRIC
global afterOpening
global img
global filename

file = filename;

npdr = 'C:\Program Files\EYRIS\application\Sample Image\groundtruth\npdr1.jpg';
[pathstr1,name1,ext1] = fileparts(npdr);
npdrr = strcat(name1,ext1);

pdr = 'C:\Program Files\EYRIS\application\Sample Image\groundtruth\pdr1.jpg';
[pathstr2,name2,ext2] = fileparts(pdr);
pdrr = strcat(name2,ext2);

normal = 'C:\Program Files\EYRIS\application\Sample Image\groundtruth\normal1.jpg';
[pathstr3,name3,ext3] = fileparts(normal);
normall = strcat(name3,ext3);



if isempty(img)
    
        errordlg('Result image not found to evaluate performance. Please select and process the image','Invalid File');
        
else
    uiwait(helpdlg('This function is to evaluate the quality of the segmentation result, click OK to continue ','Message from system'));
    switch file
    case npdrr
        gt =  imread(npdr);
        gt = imbinarize(gt);
        [Accuracy, Sensitivity, Fmeasure, Precision, MCC, Dice, Jaccard, Specitivity] = EvaluateImageSegmentationScores(gt,img);
        set(handles.edit8, 'string', Sensitivity, 'enable', 'inactive');
%         set(handles.edit9, 'string', Specitivity, 'enable', 'inactive');
        set(handles.edit10, 'string', Fmeasure, 'enable', 'inactive');
        set(handles.edit11, 'string', Accuracy, 'enable', 'inactive');
    case pdrr
        gt =  imread(pdr);
        gt = imbinarize(gt);
        [Accuracy, Sensitivity, Fmeasure, Precision, MCC, Dice, Jaccard, Specitivity] = EvaluateImageSegmentationScores(gt,img);
        set(handles.edit8, 'string', Sensitivity, 'enable', 'inactive');
%         set(handles.edit9, 'string', Specitivity, 'enable', 'inactive');
        set(handles.edit10, 'string', Fmeasure, 'enable', 'inactive');
        set(handles.edit11, 'string', Accuracy, 'enable', 'inactive');
    case normall
        gt =  imread(normal);
        gt = imbinarize(gt);
        [Accuracy, Sensitivity, Fmeasure, Precision, MCC, Dice, Jaccard, Specitivity] = EvaluateImageSegmentationScores(gt,img);
        set(handles.edit8, 'string', Sensitivity, 'enable', 'inactive');
%         set(handles.edit9, 'string', Specitivity, 'enable', 'inactive');
        set(handles.edit10, 'string', Fmeasure, 'enable', 'inactive');
        set(handles.edit11, 'string', Accuracy, 'enable', 'inactive');
    otherwise
         errordlg('The selected image is not recognized, please use a different image','Invalid File');
    end

    
end




% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles) %SAVE

global J
if isempty(J)
    errordlg('Failed to save the image. Please select and process the image','Invalid File');
else

result = J;
answer = questdlg('Are you sure want to save this images?',...
           'Save Image',...
           'Yes','No','Yes');
       
switch answer
    case 'Yes'
        [filename,pathname]=uiputfile({'*.jpg;'}, 'Save as');
        if pathname == 0
        % User clicked cancel. Bail out.
         return;
        end
        imwrite(result,[pathname,filename]);
        msgbox('Image saved successfully');
        
        
    case 'No'
        msgbox('Failed to save image!');
end
end
% % img4 = handles.axes8;
% % gambar = montage({img1,img2,img3});
% % % imgArray = cat(3,green,filterImage,afterOpening);
% % [filename,pathname]=uiputfile({'*.jpg;*.jpeg','JPEG Files(*.jpg,*.jpeg)'},'Save as');
% % imwrite(gambar,[pathname,filename]);
% % % % zippedfiles = zip('tmwlogo.zip',{'green.jpg'});
% % % N = 3 ;
% % % folder = 'C:\Users\Asus\Desktop\UUM\SEMESTER 5\PROJECT\system\segment'; % Change this to whatever you want.
% % % for k = 1:3
% % % imwrite(imread('img%d' ,k),['im_' num2str(k) '.jpg']);
% % % end




% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles) %reset
global green
global filterImage
global Lrgb
global img
global mask
answer = questdlg('Are you sure want to clear all images?',...
           'Clear Image',...
           'Yes','No','Yes');
       
switch answer
    case 'Yes'
    cla(handles.axes1,'reset')
    cla(handles.axes5,'reset')
%     cla(handles.axes6,'reset')
%     cla(handles.axes7,'reset')
    cla(handles.axes8,'reset')
    set(handles.edit5, 'string', "");
    set(handles.edit7, 'string', "");
    set(handles.edit8, 'string', "");
%     set(handles.edit9, 'string', "");
    set(handles.edit10, 'string', "");
    set(handles.edit11, 'string', "");
    clear global;
    set(handles.axes1,'xtick',[]);
set(handles.axes1,'ytick',[]);
set(handles.axes1,'xcolor',[1 1 1])
set(handles.axes1,'ycolor',[1 1 1])

set(handles.axes5,'xtick',[]);
set(handles.axes5,'ytick',[]);
set(handles.axes5,'xcolor',[1 1 1])
set(handles.axes5,'ycolor',[1 1 1])

% set(handles.axes6,'xtick',[]);
% set(handles.axes6,'ytick',[]);
% set(handles.axes6,'xcolor',[1 1 1])
% set(handles.axes6,'ycolor',[1 1 1])

% set(handles.axes7,'xtick',[]);
% set(handles.axes7,'ytick',[]);
% set(handles.axes7,'xcolor',[1 1 1])
% set(handles.axes7,'ycolor',[1 1 1])

set(handles.axes8,'xtick',[]);
set(handles.axes8,'ytick',[]);
set(handles.axes8,'xcolor',[1 1 1])
set(handles.axes8,'ycolor',[1 1 1])
    case 'No'
    msgbox('Reset Failed!');
end




% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
answer = questdlg('Are you sure want to log out?',...
           'Log Out',...
           'Yes','No','Yes');
       
switch answer
    case 'Yes'
    clear global;
    close(MAIN);
    LOGIN;
    case 'No'
    msgbox('Log Out Failed!');
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes10


% --- Executes during object creation, after setting all properties.
function axes11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes11


% --- Executes during object creation, after setting all properties.
function axes12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes12


% --- Executes during object creation, after setting all properties.
function axes13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes13


% --- Executes during object creation, after setting all properties.
function axes14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes14


% --- Executes during object creation, after setting all properties.
function axes15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes15


% --- Executes during object creation, after setting all properties.
function axes16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes16


% --- Executes during object creation, after setting all properties.
function axes17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes17


% --- Executes during object creation, after setting all properties.
function axes18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes18


% --- Executes during object creation, after setting all properties.
function axes19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes19


% --- Executes during object creation, after setting all properties.
function axes20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes20


% --- Executes during object creation, after setting all properties.
function axes21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes21
