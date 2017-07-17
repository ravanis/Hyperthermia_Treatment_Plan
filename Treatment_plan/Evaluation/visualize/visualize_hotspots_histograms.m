% This function is used to visualize the SAR matrix overlaying a gray scale image of the tissue
% matrix, to find hotspots and to display model results (aPA,RTMi, HTQ, histograms).  
%
% Needed subroutines: findHotspot, get_aPA_RTMi_3D, getHTQ
%
% Use the slide bars as follows:
%
% Slice bar: Determines what slice in z/y/x-direction that is currently shown.
%
% Display limit: Determines the limit of what is said to be a hot spot,
% every SAR element above this limit is shown.
% 
% Maximum hot spot slider value: Determines the maximum of the Hot spot
% value bar. 
%
% Color scaling: Scales the colormap maximum 

%tissue_filePath='F:\Models\Duke-tumorModels\tissue_files\df_duke_neck_cst_600MHz.txt';
%visualize_hotspots_histograms(tissue_Matrix, PLDmatrix, tissue_filepath)

function [air_matrix, onlyTissue]=visualize_hotspots_histograms(tissueMatrix, input_SARmatrix, tissue_filepath)
 


%%%%%%%%%%% INPUT VARIABLES %%%%%%%%%%%%%

% tissueMatrix - Tissue matrix for the model
% input_SARmatrix - Specific Absorption Rate matrix calculated by CST or Matlab.
% tissue_filepath - Absolute filepath to tissue file.

%%%%%%%%%%% OUTPUT VARIABLES %%%%%%%%%%%%

% air_matrix - binary 0/1 matrix for all the air in the model tissue matrix
% onlyTissue - binary 0/1 matrix for all the tissues in the model,
%              i.e. not water or air

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---- Initializing main window ----
f=figure;
screenSize=get(0,'ScreenSize'); % Get the screen size of the current screen
startPoint_xy=[screenSize(3)/6, screenSize(4)/6]; % Set the bottom left corner of the window
width=screenSize(3)/1.5 ; % Window width
height=screenSize(4)/1.5; % Window height
bar_height=23; % Slide bars height
windowSize=[startPoint_xy,width, height]; % Set figure window size
set(f, 'Position', windowSize);
set(f,'Visible','off')
set(f,'ResizeFcn',@scalePanel);
set(f,'Visible','on')


% ---- Initializing panel for buttons ----
pPos=[0.5*windowSize(3),0, 0.5*windowSize(3), windowSize(4)];
p=uipanel('Parent',f,...
            'BackgroundColor',get(f,'Color'),...
            'BorderType','none',...
            'Tag','Panel');
set(p,'Units','pixels','Position',pPos);

% ---- Import tissue file and find indeces----

[tissueData, tissue_names]=importTissueFile(tissue_filepath);
tumorIndex=find(strcmp('Tumor',tissue_names));
cystTumorIndex=find(strcmp('Cyst-Tumor',tissue_names));
tumorValue=tissueData(tumorIndex,1);
if ~isempty(cystTumorIndex)
    cystTumorValue=tissueData(cystTumorIndex,1);
else
    cystTumorValue=0;
end
airIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'air'))));
waterIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'water'))));
exteriorIndex=find(~cellfun('isempty',(strfind(lower(tissue_names),'exterior'))));
nonTissueIndeces=[airIndex;waterIndex;exteriorIndex];
nonTissueValues=tissueData(nonTissueIndeces,1);

% ---- Creating SAR matrix with only tissue SAR ----
SARmatrix=input_SARmatrix;

SARmax=max(SARmatrix(:));

onlyTissue=ones(size(input_SARmatrix));
air_matrix=zeros(size(input_SARmatrix));
for i=1:length(airIndex)
    air_matrix=air_matrix+(tissueMatrix==tissueData(airIndex(i),1));
end

for i=1:length(nonTissueIndeces)
           onlyTissue=onlyTissue.*(tissueMatrix~=nonTissueValues(i)); 
end
onlyTissueSAR=SARmatrix.*onlyTissue;

% ---- Default parameters ----
slice=round(size(tissueMatrix,3)/2); % Set center slice as default slice 
HSscaling=5;                        % Set default Color scale as 5
HSslideMax=SARmax;              % Set default Hot Spot slider maximum
display_limit=1;               % Set default display limit value
cut='Z';                 % Set default Cut plane
%-----------------------------


% --- Create default Result Plot ---
f1=subplot(1,2,1); imageOverlay(tissueMatrix,SARmatrix, slice, display_limit, HSscaling,cut);
posPlot=get(f1,'Position'); % Store Result plot position

% --- Create default colorbar plot ---
cbplot=[1:64;1:64;1:64;1:64;1:64]; % Create colormap vector
f2=subplot('Position',[posPlot(1), posPlot(2)*0.5, posPlot(3), posPlot(4)*0.05]); imagesc(cbplot);
axis([1,32,1,5])
set(gca,'YTick',[]); set(gca,'XTick',[1 16 32]); % Set Ticks 

axes(f1); % Change Current Axes to Result Plot

% --- Store variables as application data to be accessible in local functions ---

setappdata(p,'sliceValue',slice);
setappdata(p,'HSValue',display_limit);
setappdata(f,'tm',tissueMatrix);
setappdata(f,'sm',SARmatrix);
setappdata(f,'sarmax',SARmax);
setappdata(p,'HSscaling',HSscaling);
setappdata(p,'HSmax',HSslideMax);
setappdata(p,'cut',cut);
setappdata(f,'colorbar',f2);




%%%%%%%%%%%%%%%%%%%%% CREATE SLIDE BARS %%%%%%%%%%%%%%%%%%%%%%%%%%%

% ========== SLICE SLIDER ===========

sliceSlidePos=[2*bar_height,pPos(4)*0.5,pPos(3)-5*bar_height,bar_height]; % Position vector

sliceSlide = uicontrol('Parent',p,...
                       'Style','slider',...
                       'Position',sliceSlidePos,...
                       'Value',slice,...
                       'min',1, 'max',2*slice,...
                       'Callback',{@sliceSL,f});  
        
set(sliceSlide, 'SliderStep', [1/size(tissueMatrix,3) , 10/size(tissueMatrix,3) ]); % Set slider step to 1
          
% - Text boxes -
sl1=  uicontrol('Parent',p,...
                'Style','text',...
                'Position',[sliceSlidePos(1)-bar_height,sliceSlidePos(2),bar_height,bar_height],...
                'String','0',...
                'BackgroundColor',get(f,'Color'));
            
sl2 = uicontrol('Parent',p,...
                'Style','text',...
                'Position',[sliceSlidePos(1)+sliceSlidePos(3), sliceSlidePos(2),bar_height,bar_height],...
                'String',size(tissueMatrix,3),...
                'BackgroundColor',get(f,'Color'));
            
sl3 = uicontrol('Parent',p,...
                'Style','text',...
                'Position',[sliceSlidePos(1),sliceSlidePos(2)+sliceSlidePos(4),sliceSlidePos(3),sliceSlidePos(4)],...
                'String',['Slice=' int2str(slice)],...
                'BackgroundColor',get(f,'Color'));
          

% - Store handles to slider and text box to be accessible in local functions  

setappdata(p,'slSlide',sliceSlide); 
setappdata(p,'slideMinText',sl1);
setappdata(p,'slideMaxText',sl2);
setappdata(p,'slideValueText',sl3);



% ========== DISPLAY LIMIT VALUE SLIDER ===========

HSvalueSlidePos=[sliceSlidePos(1),sliceSlidePos(2)+3*bar_height,sliceSlidePos(3),bar_height]; % Position vector
HSvalueSlide = uicontrol('Parent',p,...
                         'Style','slider',...
                         'Position',HSvalueSlidePos,...
                         'value',display_limit,...
                         'min',0, 'max',HSslideMax,...
                         'Callback',{@hs,p});
          
%  - Text boxes -         
hs1=  uicontrol('Parent',p,...
                'Style','text',...
                'Position',[HSvalueSlidePos(1)-bar_height,HSvalueSlidePos(2),bar_height,bar_height],...
                'String','0',...
                'BackgroundColor',get(f,'Color'));
            
hs2 = uicontrol('Parent',p,...
                'Style','text',...
                'Position',[HSvalueSlidePos(1)+HSvalueSlidePos(3), HSvalueSlidePos(2),2*bar_height,bar_height],...
                'String',int2str(HSslideMax),...
                'BackgroundColor',get(f,'Color'));
            
hs3 = uicontrol('Parent',p,...
                'Style','text',...
                'Position',[HSvalueSlidePos(1),HSvalueSlidePos(2)+HSvalueSlidePos(4),HSvalueSlidePos(3),HSvalueSlidePos(4)],...
                'String',['Display limit value=' int2str(display_limit)],...
                'BackgroundColor',get(f,'Color'));
      
% - Store handles to be accessible in local functions

setappdata(p,'HSslide',HSvalueSlide);  
setappdata(p,'hs1',hs1);
setappdata(p,'HSmaxText',hs2);
setappdata(p,'HSvalueText',hs3);


% ============== COLOR SCALING SLIDER ===========

ColorSlidePos=[HSvalueSlidePos(1),HSvalueSlidePos(2)+2.5*HSvalueSlidePos(4),sliceSlidePos(3),sliceSlidePos(4)];
ColorSlide = uicontrol('Parent',p,...
                       'Style','slider',...
                       'Position',ColorSlidePos,...
                       'value',HSscaling,...
                       'min',0, 'max',HSscaling*2,...
                       'Callback',{@colorSlide,p});
% - Text box -                    
cs1 =   uicontrol('Parent',p,...
                  'Style','text',...
                  'Position',[ColorSlidePos(1),ColorSlidePos(2)+ColorSlidePos(4),ColorSlidePos(3),ColorSlidePos(4)],...
                  'String','Color Scaling',...
                  'BackgroundColor',get(f,'Color'));
 
% - Store handle -            
setappdata(p,'ColorSlide',ColorSlide); 
setappdata(p,'cs1',cs1);



% === DISPLAY LIMIT SLIDER MAXIMUM TEXT BOX ==

HSvalueBoxPos=[HSvalueSlidePos(1)+bar_height,sliceSlidePos(2)-3.5*bar_height,2*bar_height,bar_height];
% hsvb1 = uicontrol('Parent',p,...
%                   'Style','edit',...
%                   'Position',HSvalueBoxPos,...
%                   'Callback',{@hsBox,p});
%                  
% hsvb2 = uicontrol('Parent',p,...
%                   'Style','text',...
%                   'Position',[HSvalueBoxPos(1)-2*bar_height,HSvalueBoxPos(2)+HSvalueBoxPos(4),HSvalueBoxPos(3)+6*bar_height,HSvalueBoxPos(4)],...
%                   'String','Maximum display limit slider value',...
%                   'BackgroundColor',get(f,'Color'));
% 
% setappdata(p,'hsvb1',hsvb1)
% setappdata(p,'hsvb2',hsvb2)



% ======== CUT PLANE DROP LIST ========

CutPlaneListPos=[HSvalueSlidePos(1)+HSvalueSlidePos(3)-2*bar_height,HSvalueBoxPos(2),3*bar_height,bar_height];
cpl = uicontrol('Parent',p,...
                'Style','popup',...
                'Position',CutPlaneListPos,...
                'String','Z|Y|X',...
                'Callback',{@cpList,p});
                 
cptb = uicontrol('Parent',p,...
                 'Style','text',...
                 'Position',[CutPlaneListPos(1),CutPlaneListPos(2)+CutPlaneListPos(4),CutPlaneListPos(3),CutPlaneListPos(4)],...
                 'String','Cut Plane',...
                 'BackgroundColor',get(f,'Color'));

setappdata(p,'cpl',cpl);
setappdata(p,'cptb',cptb);
% =======================================   




%%%%%%%%%%%%%%%%%%%%% CREATE HISTOGRAM BUTTON %%%%%%%%%%%%%%%%%%%%


HistButtPos=[sliceSlidePos(1)+0.5*sliceSlidePos(3)-HSvalueSlidePos(3)*0.125,CutPlaneListPos(2),HSvalueSlidePos(3)*0.25,bar_height];
histb = uicontrol('Parent',p,...
                  'Style','pushbutton',...
                  'Position',HistButtPos,...
                  'String','Show histograms',...
                  'Callback',{@histButt,p});
                 
setappdata(p,'histb',histb)



%%%%%%%%%%%%%%%%%%%%% CREATE HOTSPOT BUTTON %%%%%%%%%%%%%%%%%%%%


HotSpotButtPos=[sliceSlidePos(1)+0.5*sliceSlidePos(3)-HSvalueSlidePos(3)*0.125,CutPlaneListPos(2)-2*bar_height,HSvalueSlidePos(3)*0.25,bar_height];
hotspotb = uicontrol('Parent',p,...
                  'Style','pushbutton',...
                  'Position',HotSpotButtPos,...
                  'String','Find hotspots',...
                  'Callback',{@hotspotSettings});
                 
setappdata(p,'hotspotb',hotspotb)

%%%%%%%%%%%%%%%%%%%%% SET EXPLANATION TEXT %%%%%%%%%%%%%%%%%%%%%%%%

expText = uicontrol('Parent',p,...
                    'Style','text',...
                    'Position',[sliceSlidePos(1),windowSize(4)*0.8,sliceSlidePos(3),sliceSlidePos(4)*3],...
                    'String',sprintf(['This program displays all points in the SAR matrix with values above the display limit.',...
                            '\n Change the display limit by using the slider.\n ',...
                            'Adjust the color scale on the SAR values on display by using the Color Scaling slider. \n '...
                            , '']),...
                    'BackgroundColor',get(f,'Color'));   

setappdata(p,'expText',expText);

%%%%%%%%%%%%%%%%%%%%% FIGURES OF MERIT BOX %%%%%%%%%%%%%%%%%%%%%%%%%


result=getResultString(getappdata(f,'tm'), onlyTissueSAR);
fomBox = uicontrol('Parent',p,...
                   'Style','text',...
                   'Position',[sliceSlidePos(1)+0.25*sliceSlidePos(3),sliceSlidePos(2)-10*bar_height,sliceSlidePos(3)*0.5,sliceSlidePos(4)*4],...
                   'String',result);

setappdata(p,'fomBox',fomBox);            
            
            

%%%%%%%%%%%%%%%%%%%%% CALLBACK FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%


% ---------- SLICE SLIDER CALLBACK FUNCTION ----------
        
function sliceSL(hObj,~,f) 
    % Get the value from the slice slider
    current_slice = round(get(hObj,'Value'));
    % Redraw image
    imageOverlay(getappdata(f,'tm'),getappdata(f,'sm'),current_slice,getappdata(p,'HSValue'),getappdata(p,'HSscaling'),getappdata(p,'cut'))
    % Update value in application data
    setappdata(p,'sliceValue',current_slice);
    % Update textbox
    set(getappdata(p,'slideValueText'),'String',['Slice=' int2str(current_slice)]);
end


% ------- DISPLAY LIMIT VALUE SLIDER CALLBACK FUNCTION -------

function hs(hObj,~,p) 
    % Get the value from the Hot Spot Value slider
    HSV = round(get(hObj,'Value'));
    % Redraw image
    imageOverlay(getappdata(f,'tm'),getappdata(f,'sm'),getappdata(p,'sliceValue'),HSV,getappdata(p,'HSscaling'),getappdata(p,'cut'))
    % Update application data
    setappdata(p,'HSValue',HSV);
    % Update textbox
    set(getappdata(p,'HSvalueText'),'String',['Display limit value=' int2str(HSV)]);
end


% ----------- COLOR SLIDER CALLBACK FUNCTION ----------------

function colorSlide(hObj,~,p) %
    % Get the value from the Hot Spot Value slider
    colorScale = get(hObj,'Value');
    % Redraw image
    imageOverlay(getappdata(f,'tm'),getappdata(f,'sm'),getappdata(p,'sliceValue'),getappdata(p,'HSValue'),colorScale,getappdata(p,'cut'))
    % Update application data
    setappdata(p,'HSscaling',colorScale);
end

% ------DISPLAY LIMIT VALUE SLIDER MAXIMUM CALLBACK FUNCTION -------- 

% function hsBox(hObj,event,p) %#ok<INUSL>
%     % Get the value from the Hot Spot Value Box
% 
%     HSV = round(str2double(get(hObj,'String')));
%     % Update slider min/max values
%     set(getappdata(p,'HSslide'),'value',HSV,'min',0,'max',HSV);
%     % Update slider maximum text box
%     set(getappdata(p,'HSmaxText'),'string',int2str(HSV));
%     % Update hot spot value text box
%     set(getappdata(p,'HSvalueText'),'string',['Hot spot value=' int2str(HSV)]);
%     % Redraw image
%     imageOverlay(getappdata(f,'tm'),getappdata(f,'sm'),getappdata(p,'sliceValue'),HSV,getappdata(p,'HSscaling'),getappdata(p,'cut'))
% end


% ----- CUT PLANE DROP LIST CALLBACK FUNCTION --------

function cpList(hObj,event,p) %#ok<INUSL>

    % Get the value from the Cut Plane drop list
    current_cut = get(hObj,'Value');
    tm=getappdata(f,'tm');
    sizeTM=size(tm);
    if current_cut==1
        newSlice=round(sizeTM(3)/2);
        current_cut='Z';
    elseif current_cut==2
        newSlice=round(sizeTM(2)/2);
        current_cut='Y';
    elseif current_cut==3
        newSlice=round(sizeTM(1)/2);
        current_cut='X';
    end

    % Redraw image
    imageOverlay(getappdata(f,'tm'),getappdata(f,'sm'),newSlice,getappdata(p,'HSValue'),getappdata(p,'HSscaling'),current_cut)
    % Set new slice bar maximum
    set(getappdata(p,'slSlide'),'value',newSlice,'Max',newSlice*2)
    % Update value in application data
    setappdata(p,'sliceValue',newSlice);
    % Update textbox
    set(getappdata(p,'slideValueText'),'String',['Slice=' int2str(newSlice)]);
    % Update slice max textbox
    set(getappdata(p,'slideMaxText'),'String',int2str(newSlice*2));
    % Update cut plane
    setappdata(p,'cut',current_cut);
end

% --------- HOT SPOT SETTINGS CALLBACK FUNCTION ----

function hotspotSettings(~,~)

   hsfig=figure; 
   pos=get(hsfig,'Position');
   
% CREATE SETTINGS OPTIONS FIELDS

% --- Number of Hotspots ---
    nbrOfHotspotsBoxPos=[pos(3)/2-bar_height,pos(4)/2+3.5*bar_height,2*bar_height,bar_height];
    nhsb1 = uicontrol('Parent',hsfig,...
                  'Style','edit',...
                  'Position',nbrOfHotspotsBoxPos);
                 
    nhsb2 = uicontrol('Parent',hsfig,...
                  'Style','text',...
                  'Position',[nbrOfHotspotsBoxPos(1)-2*bar_height,nbrOfHotspotsBoxPos(2)+nbrOfHotspotsBoxPos(4),nbrOfHotspotsBoxPos(3)+4*bar_height,nbrOfHotspotsBoxPos(4)],...
                  'String','Number of hotspots',...
                  'BackgroundColor',get(f,'Color'));

% --- Hotspot fraction ---
              
    hsfb1 = uicontrol('Parent',hsfig,...
                  'Style','edit',...
                  'Position',[nbrOfHotspotsBoxPos(1)-2*bar_height,nbrOfHotspotsBoxPos(2)-2.5*nbrOfHotspotsBoxPos(4),nbrOfHotspotsBoxPos(3)+4*bar_height,nbrOfHotspotsBoxPos(4)]);
                 
    hsfb2 = uicontrol('Parent',hsfig,...
                  'Style','text',...
                  'Position',[nbrOfHotspotsBoxPos(1)-4*bar_height,nbrOfHotspotsBoxPos(2)-1.5*nbrOfHotspotsBoxPos(4),nbrOfHotspotsBoxPos(3)+8*bar_height,nbrOfHotspotsBoxPos(4)],...
                  'String','Hotspot limit',...
                  'BackgroundColor',get(f,'Color'));
  
% --- Number of neighbors ---     
         
    nnb1 = uicontrol('Parent',hsfig,...
                  'Style','edit',...
                  'Position',[nbrOfHotspotsBoxPos(1)-2*bar_height,nbrOfHotspotsBoxPos(2)-6*nbrOfHotspotsBoxPos(4),nbrOfHotspotsBoxPos(3)+4*bar_height,nbrOfHotspotsBoxPos(4)]);
                 
    nnb2 = uicontrol('Parent',hsfig,...
                  'Style','text',...
                  'Position',[nbrOfHotspotsBoxPos(1)-5*bar_height,nbrOfHotspotsBoxPos(2)-5*nbrOfHotspotsBoxPos(4),nbrOfHotspotsBoxPos(3)+10*bar_height,nbrOfHotspotsBoxPos(4)*2],...
                  'String','Number of neighbors required out of 30x30x30 voxel surrounding box (default = 50)',...
                  'BackgroundColor',get(f,'Color'));              
              
              
              
setappdata(hsfig,'nhsb1',nhsb1)
setappdata(hsfig,'nhsb2',nhsb2)
setappdata(hsfig,'hslb1',hsfb1)
setappdata(hsfig,'hslb2',hsfb2)
setappdata(hsfig,'nnb1',nnb1)
setappdata(hsfig,'nnb2',nnb2)

    
% --- Show hotspots button ---
   
    hotspotsettb = uicontrol('Parent',hsfig,...
                  'Style','pushbutton',...
                  'Position',[nbrOfHotspotsBoxPos(1)-bar_height,nbrOfHotspotsBoxPos(2)-7.5*nbrOfHotspotsBoxPos(4),nbrOfHotspotsBoxPos(3)+2*bar_height,nbrOfHotspotsBoxPos(4)],...
                  'String','Show Hotspots',...
                  'Callback',{@hotspotButt,hsfig});
    
end


% --------- SHOW HOTSPOTS CALLBACK FUNCTION ----

function hotspotButt(hObj,event,hsfig) %#ok<INUSL>

    
    
    % Find hotspots
    nbrOfHotspots=str2double(get(getappdata(hsfig,'nhsb1'),'string'));
    [output]=findHotspot(onlyTissueSAR, str2double(get(getappdata(hsfig,'nhsb1'),'string')), str2double(get(getappdata(hsfig,'hslb1'),'string')), str2double(get(getappdata(hsfig,'nnb1'),'string')));
    
    % Store results
    hotspotMasked=output(1:nbrOfHotspots);
    centerPoints=output{nbrOfHotspots+1};
    values=output{nbrOfHotspots+2};
    hotspots_found=output{nbrOfHotspots+3};
    tm=getappdata(f,'tm');
    
    for figur=1:hotspots_found
    
    hsm=tm.*(hotspotMasked{figur}>0);
    hsm(hsm==0)=NaN;
    center_string=tissue_names{tissueData(:,1)==tm(centerPoints(figur,1),centerPoints(figur,2),centerPoints(figur,3))};
    most_frequent_string=tissue_names{tissueData(:,1)==mode(hsm(:))};

            figure('units','normalized','outerposition',[0 0 1 1])
            subplot(1,3,1);
            imageOverlay(getappdata(f,'tm'),hotspotMasked{figur},centerPoints(figur,1),0,1,'X')
            title(['Hotspot ' int2str(figur) ', X = ' int2str(centerPoints(figur,1))]);

            subplot(1,3,2);
            imageOverlay(getappdata(f,'tm'),hotspotMasked{figur},centerPoints(figur,2),0,1,'Y')
            title(['Hotspot ' int2str(figur) ', Y = ' int2str(centerPoints(figur,2))]);

            subplot(1,3,3);
            imageOverlay(getappdata(f,'tm'),hotspotMasked{figur},centerPoints(figur,3),0,1,'Z')
            title(['Hotspot ' int2str(figur) ', Z = ' int2str(centerPoints(figur,3)) ]);

            suptitle(sprintf([' Max value = ', int2str(values(figur,1)),...
                              '. Mean value = ', int2str(values(figur,2)),...
                              '\n Tissue in center point: ', center_string,...
                              '\n Most frequent tissue: ', most_frequent_string])); 

    end
end



% --------- SHOW HISTOGRAM CALLBACK FUNCTION -------

function histButt(~,~,~) 
    
    % - Create new window, same size as original window
    histfig=figure;
    set(histfig, 'Position', windowSize);
    set(histfig,'Visible','off')
    set(histfig,'ResizeFcn',@scaleHist); 
    set(histfig,'Visible','on')
    setappdata(f,'histfig',histfig)
    f3=subplot(2,2,1);
    f4=subplot(2,2,3);
    setappdata(f,'f3',f3)
    setappdata(f,'f4',f4)
    
    % Create new Panel
    p2=uipanel('Parent',histfig,...
            'BackgroundColor',get(f,'Color'),...
            'BorderType','none',...
            'Unit','pixels',...
            'Tag','histPanel',...
            'Position',pPos);

   fig = getappdata(f,'histfig') ;
   figPos = get(fig,'Position'); % New size of the changed window 
   newPos = [0.5*figPos(3),0, 0.5*figPos(3), figPos(4)]; % Calculate new Panel position 
   
   % Set new positions for check boxes
   
   newBar_height=newPos(4)/40; % New slide bar height
   newBar_width=newPos(3)*0.5-2*newBar_height;
        
        
    % - Position for first check box
    StartPosCheck=[2*newBar_height,4*newBar_height,newBar_width,newBar_height];    
        
    
    % - Import tissue file  
    nbrOfCheckboxes=size(tissueData,1);
    setappdata(f,'cbv',nbrOfCheckboxes);
    
    % Intitialize 50 checkboxes
    cb1=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb1',cb1);
    cb2=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb2',cb2);
    cb3=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb3',cb3);
    cb4=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb4',cb4);
    cb5=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb5',cb5);
    cb6=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb6',cb6);
    cb7=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb7',cb7);
    cb8=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb8',cb8);
    cb9=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb9',cb9);
    cb10=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb10',cb10);
    cb11=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb11',cb11);
    cb12=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb12',cb12);
    cb13=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb13',cb13);
    cb14=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb14',cb14);
    cb15=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb15',cb15);
    cb16=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb16',cb16);
    cb17=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb17',cb17);
    cb18=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb18',cb18);
    cb19=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb19',cb19);
    cb20=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb20',cb20);
    cb21=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb21',cb21);
    cb22=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb22',cb22);
    cb23=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb23',cb23);
    cb24=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb24',cb24);
    cb25=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb25',cb25);


    cb26=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb26',cb26);
    cb27=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb27',cb27);
    cb28=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb28',cb28);
    cb29=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb29',cb29);
    cb30=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb30',cb30);
    cb31=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb31',cb31);
    cb32=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb32',cb32);
    cb33=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb33',cb33);
    cb34=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb34',cb34);
    cb35=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb35',cb35);
    cb36=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb36',cb36);
    cb37=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb37',cb37);
    cb38=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb38',cb38);
    cb39=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb39',cb39);
    cb40=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb40',cb40);
    cb41=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb41',cb41);
    cb42=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb42',cb42);
    cb43=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb43',cb43);
    cb44=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb44',cb44);
    cb45=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb45',cb45);
    cb46=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb46',cb46);
    cb47=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb47',cb47);
    cb48=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb48',cb48);
    cb49=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb49',cb49);
    cb50=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb50',cb50);
    cb51=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb51',cb51);
    cb52=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb52',cb52);
    cb53=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb53',cb53);
    cb54=uicontrol('Parent',p2,'Style','checkbox'); setappdata(f,'cb54',cb54);
    
    % Insert names from tissue-file to checkboxes - surplus checkboxes are
    % left unnamed
    for j=1:nbrOfCheckboxes
       set(getappdata(f,['cb', int2str(j)]),'String', tissue_names{j}) 
    end
    
    for j=nbrOfCheckboxes+1:54
        set(getappdata(f,['cb', int2str(j)]),'Visible', 'off')
    end
    
    
     set(getappdata(f,'cb1'),'Position',[StartPosCheck(1),StartPosCheck(2),StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb2'),'Position',[StartPosCheck(1),StartPosCheck(2)+bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb3'),'Position',[StartPosCheck(1),StartPosCheck(2)+2*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb4'),'Position',[StartPosCheck(1),StartPosCheck(2)+3*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb5'),'Position',[StartPosCheck(1),StartPosCheck(2)+4*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb6'),'Position',[StartPosCheck(1),StartPosCheck(2)+5*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb7'),'Position',[StartPosCheck(1),StartPosCheck(2)+6*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb8'),'Position',[StartPosCheck(1),StartPosCheck(2)+7*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb9'),'Position',[StartPosCheck(1),StartPosCheck(2)+8*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb10'),'Position',[StartPosCheck(1),StartPosCheck(2)+9*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb11'),'Position',[StartPosCheck(1),StartPosCheck(2)+10*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb12'),'Position',[StartPosCheck(1),StartPosCheck(2)+11*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb13'),'Position',[StartPosCheck(1),StartPosCheck(2)+12*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb14'),'Position',[StartPosCheck(1),StartPosCheck(2)+13*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb15'),'Position',[StartPosCheck(1),StartPosCheck(2)+14*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb16'),'Position',[StartPosCheck(1),StartPosCheck(2)+15*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb17'),'Position',[StartPosCheck(1),StartPosCheck(2)+16*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb18'),'Position',[StartPosCheck(1),StartPosCheck(2)+17*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb19'),'Position',[StartPosCheck(1),StartPosCheck(2)+18*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb20'),'Position',[StartPosCheck(1),StartPosCheck(2)+19*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb21'),'Position',[StartPosCheck(1),StartPosCheck(2)+20*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb22'),'Position',[StartPosCheck(1),StartPosCheck(2)+21*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb23'),'Position',[StartPosCheck(1),StartPosCheck(2)+22*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb24'),'Position',[StartPosCheck(1),StartPosCheck(2)+23*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb25'),'Position',[StartPosCheck(1),StartPosCheck(2)+24*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb26'),'Position',[StartPosCheck(1),StartPosCheck(2)+25*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb27'),'Position',[StartPosCheck(1),StartPosCheck(2)+26*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   
   set(getappdata(f,'cb51'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2),StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb52'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb28'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+2*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb29'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+3*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb30'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+4*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb31'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+5*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb32'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+6*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb33'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+7*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb34'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+8*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb35'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+9*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb36'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+10*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb37'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+11*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb38'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+12*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb39'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+13*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb40'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+14*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb41'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+15*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb42'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+16*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb43'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+17*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb44'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+18*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb45'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+19*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb46'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+20*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb47'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+21*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb48'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+22*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb49'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+23*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb50'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+24*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb53'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+25*bar_height,StartPosCheck(3),StartPosCheck(4)]);
   set(getappdata(f,'cb54'),'Position',[StartPosCheck(1)+StartPosCheck(3),StartPosCheck(2)+26*bar_height,StartPosCheck(3),StartPosCheck(4)]);
     
    
    % Create update histogram push button
    UpdateHistButtPos=[StartPosCheck(1)+0.5*StartPosCheck(3),StartPosCheck(2)-2*StartPosCheck(4),StartPosCheck(3),StartPosCheck(4)];
    uphistbutt = uicontrol('Parent',p2,...
                           'Style','pushbutton',...
                           'Position',UpdateHistButtPos,...
                           'String','Update histograms',...
                           'Callback',{@histPlotUdate,f});
    setappdata(f,'uphistbutt',uphistbutt);
end



% -------- HistPlotUpdate Callback FUNCTION -----------

        
function histPlotUdate(~,~,f)
        
    % Extract values from check boxes
    checkValues=zeros(getappdata(f,'cbv'),1);
    for j=1:size(checkValues,1)
       checkValues(j)=get(getappdata(f,['cb', int2str(j)]),'Value'); 
    end
    
    % Create vector with the tissue indeces to be displayed
    td=tissueData;
    displayValues=td(:,1);
    displayValues=displayValues(displayValues.*checkValues~=0);

    % Clear the axes from previous figures
    axes(getappdata(f,'f3')); cla
    axes(getappdata(f,'f4')); cla
    
    plotHTQHistograms(getappdata(f,'tm'),getappdata(f,'sm'),displayValues)
end     





%%%%%%%%%%% PANEL RESIZE FUNCTION %%%%%%%%%%

function scalePanel(~,~) 

    
   % Resize Panel 
   p1 = findobj(gcbo, 'Type','uipanel','Tag','Panel');
   fig = f ;    
   panelunits = get(p1,'Units');
   set(p1,'Units','pixels');
   figPos = get(fig,'Position'); % New size of the changed window 
   newPos = [0.5*figPos(3),0, 0.5*figPos(3), figPos(4)]; % Calculate new Panel position 
   set(p1,'Position',newPos); 
   
   
   % --- Resize sliders and text boxes ---
   newBar_height=figPos(4)/30; % New slide bar height
   
   newSliceSlidePos=[2*newBar_height,newPos(4)*0.5,newPos(3)-5*newBar_height,newBar_height]; % New slice slider position
   
   % Slice slider
   set(getappdata(p,'slSlide'),'Position',newSliceSlidePos)
   set(getappdata(p,'slideMinText'),'Position',[newSliceSlidePos(1)-newBar_height,newSliceSlidePos(2),newBar_height,newBar_height]);
   set(getappdata(p,'slideMaxText'),'Position',[newSliceSlidePos(1)+newSliceSlidePos(3), newSliceSlidePos(2),newBar_height,newBar_height]);
   set(getappdata(p,'slideValueText'),'Position',[newSliceSlidePos(1),newSliceSlidePos(2)+newSliceSlidePos(4),newSliceSlidePos(3),newSliceSlidePos(4)])
   
   % Hot Spot Value slider
   newHSvalueSlidePos=[newSliceSlidePos(1),newSliceSlidePos(2)+3*newBar_height,newSliceSlidePos(3),newBar_height];
   set(getappdata(p,'HSslide'),'Position',newHSvalueSlidePos);
   set(getappdata(p,'hs1'), 'Position',[newHSvalueSlidePos(1)-newBar_height,newHSvalueSlidePos(2),newBar_height,newBar_height])
   set(getappdata(p,'HSmaxText'),'Position',[newHSvalueSlidePos(1)+newHSvalueSlidePos(3), newHSvalueSlidePos(2),2*newBar_height,newBar_height])
   set(getappdata(p,'HSvalueText'),'Position',[newHSvalueSlidePos(1),newHSvalueSlidePos(2)+newHSvalueSlidePos(4),newHSvalueSlidePos(3),newHSvalueSlidePos(4)]);
   
   % Color slider
   newColorSlidePos=[newHSvalueSlidePos(1),newHSvalueSlidePos(2)+2.5*newHSvalueSlidePos(4),newSliceSlidePos(3),newSliceSlidePos(4)];
   set(getappdata(p,'ColorSlide'),'Position',newColorSlidePos);
   set(getappdata(p,'cs1'),'Position',[newColorSlidePos(1),newColorSlidePos(2)+newColorSlidePos(4),newColorSlidePos(3),newColorSlidePos(4)]);
   
   % HS value text box
   newHSvalueBoxPos=[newHSvalueSlidePos(1)+newBar_height,newSliceSlidePos(2)-3.5*newBar_height,2*newBar_height,newBar_height];
%    set(getappdata(p,'hsvb1'),'Position',newHSvalueBoxPos);
%    set(getappdata(p,'hsvb2'),'Position',[newHSvalueBoxPos(1)-2*newBar_height,newHSvalueBoxPos(2)+newHSvalueBoxPos(4),newHSvalueBoxPos(3)+6*newBar_height,newHSvalueBoxPos(4)]);
   
   % Cut plane drop list
   newCutPlaneListPos=[newHSvalueSlidePos(1)+newHSvalueSlidePos(3)-2*newBar_height,newHSvalueBoxPos(2),3*newBar_height,newBar_height];
   set(getappdata(p,'cpl'),'Position',newCutPlaneListPos);
   set(getappdata(p,'cptb'),'Position',[newCutPlaneListPos(1),newCutPlaneListPos(2)+newCutPlaneListPos(4),newCutPlaneListPos(3),newCutPlaneListPos(4)]);
   
   % Histogram push button
   newHistButtPos=[newSliceSlidePos(1)+0.5*newSliceSlidePos(3)-newHSvalueSlidePos(3)*0.125,newCutPlaneListPos(2),newHSvalueSlidePos(3)*0.25,newBar_height];
   set(getappdata(p,'histb'),'Position',newHistButtPos);
  
   % Hotspots button 
   
   newHotSpotButtPos=[newSliceSlidePos(1)+0.5*newSliceSlidePos(3)-newHSvalueSlidePos(3)*0.125,newCutPlaneListPos(2)-2*newBar_height,newHSvalueSlidePos(3)*0.25,newBar_height];
   set(getappdata(p,'hotspotb'),'Position',newHotSpotButtPos);
   
   % Explanation text
   
   set(getappdata(p,'expText'),'Position',[newSliceSlidePos(1),newPos(4)*0.8,newSliceSlidePos(3),newSliceSlidePos(4)*3]);
  
   % Figures of Merit Box
   
   set(getappdata(p,'fomBox'),'Position',[newSliceSlidePos(1)+0.25*newSliceSlidePos(3),newSliceSlidePos(2)-10*newBar_height,newSliceSlidePos(3)*0.5,newSliceSlidePos(4)*3]);
   
   
   % restore units for the panel
   set(p1,'Units',panelunits);
end 

% ------ SCALE HISTOGRAM BWINDOW FUNCTION ------

function scaleHist(~,~) 
    
   % Resize Panel 
   p2 = findobj(gcbo, 'Type','uipanel','Tag','histPanel');
   fig = getappdata(f,'histfig') ;
   panelunits = get(p2,'Units');
   set(p2,'Units','pixels');
   figPos = get(fig,'Position'); % New size of the changed window 
   newPos = [0.5*figPos(3),0, 0.5*figPos(3), figPos(4)]; % Calculate new Panel position 
   set(p2,'Position',newPos); 
   
   % Set new positions for check boxes
   
   newBar_height=newPos(4)/40; % New slide bar height
   newBar_width=newPos(3)*0.5-2*newBar_height;
   newStartPosCheck=[2*newBar_height,4*newBar_height,newBar_width,newBar_height];
   
   set(getappdata(f,'cb1'),'Position',[newStartPosCheck(1),newStartPosCheck(2),newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb2'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb3'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+2*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb4'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+3*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb5'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+4*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb6'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+5*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb7'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+6*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb8'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+7*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb9'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+8*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb10'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+9*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb11'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+10*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb12'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+11*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb13'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+12*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb14'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+13*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb15'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+14*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb16'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+15*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb17'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+16*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb18'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+17*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb19'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+18*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb20'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+19*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb21'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+20*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb22'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+21*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb23'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+22*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb24'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+23*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb25'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+24*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb26'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+25*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb27'),'Position',[newStartPosCheck(1),newStartPosCheck(2)+26*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   
   set(getappdata(f,'cb51'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2),newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb52'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb28'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+2*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb29'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+3*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb30'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+4*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb31'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+5*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb32'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+6*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb33'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+7*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb34'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+8*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb35'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+9*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb36'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+10*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb37'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+11*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb38'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+12*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb39'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+13*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb40'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+14*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb41'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+15*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb42'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+16*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb43'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+17*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb44'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+18*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb45'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+19*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb46'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+20*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb47'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+21*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb48'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+22*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb49'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+23*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb50'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+24*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb53'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+25*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   set(getappdata(f,'cb54'),'Position',[newStartPosCheck(1)+newStartPosCheck(3),newStartPosCheck(2)+26*newBar_height,newStartPosCheck(3),newStartPosCheck(4)]);
   
   set(getappdata(f,'uphistbutt'),'Position',[newStartPosCheck(1)+0.5*newStartPosCheck(3),newStartPosCheck(2)-2*newStartPosCheck(4),newStartPosCheck(3),newStartPosCheck(4)]);
   % restore units for the panel
   set(p2,'Units',panelunits);
   
end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%% getResultString FUNCTION %%%%%%%%%%%%%%%%%%%%%%%

    function result=getResultString(tissue_matrix, SAR_matrix)

      
        % Get Results
        [aPA, RTMi]=get_aPA_RTMi_3D(SAR_matrix,tissue_matrix,10,tissue_filepath);
        [HTQ, ~, tc]=getHTQ(tissue_matrix,SAR_matrix,tissue_filepath);
        % Concatenate string
        result=sprintf(['Model HTQ = ', num2str(HTQ),...
            '\n SAR-Model aPA = ', num2str(aPA), ...
            '\n SAR-Model RTMi = ', num2str(RTMi),...
            '\n Max SAR in model = ', num2str(getappdata(f,'sarmax')) ,...
            '\n TC25 = ', num2str(tc(1)) ]);
    end






    %%%%%%%%%%%%%%%%%%%%%%%% IMAGE OVERLAY FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function imageOverlay(tissueMatrix,SARmatrix, slice, HSvalue, HSscaling,cutPlane)

            % ---- INPUT PARAMETERS-----
            % slice - Cut plane coordinate
            % HSvalue -Hot spot limit value
            % HSscaling -The colormap maximum is HotSpotMax/HSscaling. If a single hotspot peak is way higher than the other, this can be used.
            % --------------------------
        
        

            % Find tumor index
            tumorIndexVector=tumorIndex;
            if cystTumorIndex~=0
                tumorIndexVector=[tumorIndex, cystTumorIndex];
            end


            % Reshape matrices to fit imagesc-function

            if cutPlane=='X'
                A=reshape(tissueMatrix(slice,:,:),[size(tissueMatrix,2) size(tissueMatrix,3)]);
                B=reshape(SARmatrix(slice,:,:),[size(SARmatrix,2) size(SARmatrix,3)]);
                xlimit=[1, size(tissueMatrix,3)] ;
                ylimit=[1, size(tissueMatrix,2)];
            elseif cutPlane=='Y'
                A=reshape(tissueMatrix(:,slice,:),[size(tissueMatrix,1) size(tissueMatrix,3)]);
                B=reshape(SARmatrix(:,slice,:),[size(SARmatrix,1) size(SARmatrix,3)]);
                xlimit=[1, size(tissueMatrix,3)] ;
                ylimit=[1, size(tissueMatrix,1)];
            elseif cutPlane=='Z'
                A=tissueMatrix(:,:,slice);
                B=SARmatrix(:,:,slice);
                xlimit=[1, size(tissueMatrix,2)] ;
                ylimit=[1, size(tissueMatrix,1)];
            end

            % Find tumor edge mask
            C=findTumorEdge(A,tumorIndexVector);
            % Plot the two images
            h(1) = imagesc(A);
            axis('xy'); axis equal; xlim(xlimit); ylim(ylimit);
            hold on
            h(2) = imagesc(B.*C); % Mask PLD with tumor edge so the edge will show
            axis('xy'); axis equal; xlim(xlimit); ylim(ylimit)
            hold on

            % Create two different colormaps

            m = 64;  % 64-elements is each colormap
            colormap([jet(m);gray(m)])
            % CData for PLD
            cminB = min(B(:));
            cmaxB = max(B(:))/HSscaling;
            C1 = min(m,round((m-1)*(B-cminB)/(cmaxB-cminB))+1);
            % CData for tissue
            cmin = min(A(:))-1;
            cmax = max(A(:));
            C2 = 64+min(m,round((m-1)*(A-cmin)/(cmax-cmin))+1);


            % Update the CDatas for each object.
            set(h(1),'CData',double(C2));
            set(h(2),'CData',double(C1));
            % Display only the hotspot values
            I=(B>HSvalue); % SAR over a certain value
            set(h(2),'AlphaData',I.*C);
            set(getappdata(f,'colorbar'),'XTickLabel',{sprintf('%d',cminB),sprintf('%d',round((cmaxB-cminB)/2)), ['>', sprintf('%d',round(cmaxB))]});
    end

    %%%%%%%%%%%%%% PLOT HTQ HISTOGRAMS FUNCTION %%%%%%%%%%%%%%%%

    %%%%%%%% Plots histograms over SAR distribution in the tumor plus the tissues specified in
    %%%%%%%% tissuePlot. The histograms are plotted both with reference to
    %%%%%%%% maximum SAR in tumor and maximum SAR in healthy tissue.
    %%%%%%%% Last edit: 150722 by Joel Wanemark 

    function plotHTQHistograms(TissueMatrix,PLDMatrix,tissuePlot)

        % --- INPUT PARAMETERS ---
        % tissuePlot - vector containing the numerical values for the tissues that
        % you want to plot
        % tissueFilePath - absolute path to Tissue File
        


        tissueLegend=tissue_names;
        A=PLDMatrix;
        B=TissueMatrix;
        sizeA=size(A);

        %Creating 0/1 healthy tissue matrix excluding Tumor and dividing it with
        %density. Healthy tissue is every tissue except tumor, air/exterior and water bolus
        
        healthyTissue=ones(sizeA);
     
        for i=1:length(nonTissueIndeces)
           healthyTissue=healthyTissue.*(B~=nonTissueValues(i)); 
        end


        %Creating Healthy SAR matrix by multiplying PLD-matrix and tissue matrix
        healthyMatrix=SARmatrix;
        % Number of elements in the healthy tissue
        [rowHEALTH, ~]=find(healthyTissue);
        % Reshape head matrix to a vector to be able to sort
        healthyVector=reshape(healthyMatrix,sizeA(1).*sizeA(2).*sizeA(3),1);
        sortHealthyVector=sort(healthyVector,'descend');
        %Create correct length on head vector
        sortHealthyVector=sortHealthyVector(1:size(rowHEALTH));





        %Creating 0/1 tumor tissue matrix and dividing it with density
        tumorTissue=(B== tumorValue).*SARmatrix;
        cystTumorTissue=zeros(size(B));
        if ~isempty(cystTumorIndex)
            cystTumorTissue=(B== cystTumorValue).*SARmatrix;
        end


        %Creating tumor matrix by multiplying SAR-matrix and tissue 0/-1 matrix
         tumorMatrix=tumorTissue+cystTumorTissue;
        % Create sorted tumor vector
        [rowTUM, ~]=find(tumorTissue);
        tumorVector=reshape(tumorMatrix,sizeA(1).*sizeA(2).*sizeA(3),1);
        sortTumorVector=sort(tumorVector,'descend');
        tumorVector=sortTumorVector(1:size(rowTUM));
        sizeTum=size(tumorVector);

        %Color vector for plots
        color=['b', 'r', 'g', 'k', 'm', 'c','y'];

        %Plot tumor histogram with reference to maximum SAR in tumor tissue
        axes(getappdata(f,'f3'));
        bincountHCTum=histc(100*tumorVector,0:100*tumorVector(1));
        sizeBinHC=size(bincountHCTum);
        cumHistHCTum=1-cumsum(bincountHCTum)./sizeTum(1);
        plot(linspace(0,100,sizeBinHC(1)),cumHistHCTum,color(1)); hold on


        %Plot tumor histogram with reference to maximum SAR in healthy tissue
        axes(getappdata(f,'f4'));
        bincountHealthy=histc(100*sortHealthyVector,0:100*sortHealthyVector(1));
        sizeBin=size(bincountHealthy);
        bincountTum=histc(100*tumorVector,0:100*sortHealthyVector(1));
        cumHistTum=1-cumsum(bincountTum)./sizeTum(1);
        plot(linspace(0,100,sizeBin(1)),cumHistTum,color(1)); hold on





        for i=1:length(tissuePlot)

            %Creating 0/1 tissue matrix
             plotTissue=B==tissuePlot(i);

            %Creating tissue plot matrix by multiplying SAR-matrix and tissue 0/-1 matrix
            plotMatrix=plotTissue.*SARmatrix;
            % Create sorted tissue vector
            [rowTissue, ~]=find(plotTissue);
            tissueVector=reshape(plotMatrix,sizeA(1).*sizeA(2).*sizeA(3),1);
            sortTissueVector=sort(tissueVector,'descend');
            tissueVector=sortTissueVector(1:size(rowTissue));


            %Plot histogram with tumor SAR as reference
            axes(getappdata(f,'f3'));

            bincountTiss=histc(100*tissueVector,0:100*tumorVector(1));
            cumHistTiss=1-cumsum(bincountTiss)./length(tissueVector);
            plot(linspace(0,100,sizeBinHC(1)),cumHistTiss,color(i+1)); hold on


            %Plot histogram with head SAR as reference
            axes(getappdata(f,'f4'));

            bincountTiss2=histc(100*tissueVector,0:100*sortHealthyVector(1));
            cumHistTiss2=1-cumsum(bincountTiss2)./length(tissueVector);
            plot(linspace(0,100,sizeBin(1)),cumHistTiss2,color(i+1)); hold on

        end

        axes(getappdata(f,'f3'));
        tissueLegendVector=zeros(size(tissuePlot));
        for i=1:length(tissuePlot)
            tissueLegendVector(i)=find(tissueData(:,1)==tissuePlot(i));
        end
        legend([tissueLegend(tumorIndex), tissueLegend{tissueLegendVector}])
        xlabel('Percentage of maximum SAR in tumor tissue');
        ylabel('Cumulative volume');
        title(['Maximum SAR in tumor = ',int2str(sortTumorVector(1))]);
        axes(getappdata(f,'f4'));
        legend([tissueLegend(tumorIndex), tissueLegend{tissueLegendVector}])
        xlabel('Percentage of maximum SAR in healthy tissue');
        ylabel('Cumulative volume');
        title(['Maximum SAR in healthy tissue = ',int2str(sortHealthyVector(1))]);
        axis([0,50,0,1]);


    end      
        
end
        
        
        
        
        
        
        
        
        
     