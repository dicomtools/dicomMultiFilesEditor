function dicomMultiFilesEditor(varargin)
%function dicomMultiFilesEditor(varargin)
%DICOM Multi-Files Editor.
%See dicomMultiFilesEditor.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the dicomMultiFilesEditor development team.
% 
% This file is part of The DICOM Multi-Files Editor (dicomMultiFilesEditor).
% 
% dicomMultiFilesEditor development has been led by: Daniel Lafontaine
% 
% dicomMultiFilesEditor is distributed under the terms of the Lesser GNU Public License. 
% 
%     This version of dicomMultiFilesEditor is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
% dicomMultiFilesEditor is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with dicomMultiFilesEditor.  If not, see <http://www.gnu.org/licenses/>.

    initEditorGlobal();
    
    editorLbBackgroundColor('set', [0.149 0.149 0.149]);
    editorLbForegroundColor('set', [0.98 0.98 0.98]);
    editorBackgroundColor('set', [0.16 0.18 0.20]);
    editorForegroundColor('set', [0.94 0.94 0.94]);
    editorHighlightColor ('set', [0.94 0.94 0.94]);
    editorShadowColor    ('set', [0.94 0.94 0.94]);
    editorButtonBackgroundColor('set', [0.53 0.63 0.40]);
    editorButtonForegroundColor('set', [0.10 0.10 0.10]);       
    editorWriteTagLineColor('set', [1 0 0]);       
   
    dIsCommandLine = false;
    
    argMainDirOrFileName = '';
    argMultiFiles        = true;
    argSeriesUID         = false;
    argTragetDir         = '';
    argDicomDict         = ''; 
    argHeaderNumber      = '';
    argSortFiles         = ''; 
    argInternal          = false;
    
    dOutputDirOffset = 0;
        
    varargin = replace(varargin, '"', '');
    varargin = replace(varargin, ']', '');
    varargin = replace(varargin, '[', '');

    for k=1:length(varargin)
        
        sSwitchAndArgument = varargin{k};

        cSwitch = sSwitchAndArgument(1:2);
        sArgument = sSwitchAndArgument(3:end);
        
        switch cSwitch
                
            case '-m'
                argMultiFiles = true; 
         
            case '-u'
                argSeriesUID = true;      
                
            case '-r'
                
                if k+1 <= length(varargin)
                    if dOutputDirOffset == 0
                        sOutputPath = varargin{k+1};
                        if sOutputPath(end) ~= '/'
                            argTragetDir = [sOutputPath '/'];   
                            dOutputDirOffset = k+1;
                        end               
                    end
                end                
                            
            case '-d'
                argDicomDict = sArgument; 
                
            case '-h'
                argHeaderNumber = sArgument;   
                
            case '-l'
                argSortFiles = sArgument;   
                
            case '-i'
                argInternal = true;              
                
            otherwise
                if k ~= dOutputDirOffset % The output dir is set before
               
                    if ~(sSwitchAndArgument(end) == '\') || ...
                       ~(sSwitchAndArgument(end) == '/')    
                        argMainDirOrFileName = [sSwitchAndArgument '/'];
                    else
                        argMainDirOrFileName = sSwitchAndArgument;
                    end    
                    dIsCommandLine = true;
                end
                
        end                          
    end
    
    initEditorDcm4che3();

    editorTargetDir    ('set', argTragetDir   );
    editorCustomDict   ('set', argDicomDict   );
    editorMultiFiles   ('set', argMultiFiles  );
    editorAutoSeriesUID('set', argSeriesUID   );
    editorIntegrateToBrowser('set', argInternal);
        
    if numel(argHeaderNumber)
        editorSaveHeaderNumber('set', argHeaderNumber);
    else
        editorSaveHeaderNumber('set', '1');
    end    
 
    if editorMultiFiles('get') == false               
        editorDicomFileName('set', argMainDirOrFileName);
        editorMainDir('set', '');
    else        
        editorDicomFileName('set', '');        
        editorMainDir('set', argMainDirOrFileName);
    end
    
    if ~numel(argDicomDict)
        editorDefaultDict('set', true);    
    else
        editorDefaultDict('set', false);  
    end
    
    if ~numel(argTragetDir)
        editorDefaultPath('set', true);
    else
        editorDefaultPath('set', false);
    end
    
    if ~numel(argHeaderNumber)
        editorSaveAllHeader('set', true);
    else    
        editorSaveAllHeader('set', false);
    end    
    
    if ~numel(argSortFiles)
        editorSortFiles('set', false);
    else    
        editorSortFiles('set', true);
    end  
    
    initEditorRootPath()
  
    dicomdict('factory');            

    dScreenSize  = get(groot, 'Screensize');

    dMainWindowSizeX = dScreenSize(3);
    dMainWindowSizeY = dScreenSize(4);    
    
    dPositionX = (dScreenSize(3) /2) - (dMainWindowSizeX /2);
    dPositionY = (dScreenSize(4) /2) - (dMainWindowSizeY /2);  
    
    dlgWindows = ...
        figure('Position', [dPositionX ...
                            dPositionY ...
                            dMainWindowSizeX ...
                            dMainWindowSizeY ...
                            ],...
               'Name'    , 'DICOM Multi-Files Editor',...
               'NumberTitle', 'off',...                           
               'units'   , 'normalized',...
               'resize'     , 'on',...
               'MenuBar'    , 'none',...
               'Toolbar'    , 'none',...
               'Color'      , editorBackgroundColor('get'), ...
               'SizeChangedFcn',@editorResizeDialog...
               );
    dlgEditorWindowsPtr('set', dlgWindows);
    
    dDlgPosition = get(dlgWindows, 'position');

    dDialogSize = dScreenSize(4) * dDlgPosition(4); 
    yPosition   = dDialogSize - 30;

    xSize = dScreenSize(3) * dDlgPosition(3); 
    ySize = dDialogSize - 30;        
                    
    uiMainWindow = ...
        uipanel(dlgWindows,...
                'Units'   , 'pixels',...
                'position', [0 ...
                             30 ...
                             xSize ...
                             ySize-30 ...
                             ],...
                'BackgroundColor', editorBackgroundColor('get'), ...
                'ForegroundColor', editorForegroundColor('get'), ...      
                'ShadowColor'    , editorShadowColor('get'), ...     
                'HighlightColor' , editorHighlightColor('get'), ...                    
                'title'   , 'DICOM Source'...
                );
    uiEditorMainWindowPtr('set', uiMainWindow);
                    
    uiProgressWindow = ...
        uipanel(dlgWindows,...
                'Units'   , 'pixels',...
                'position', [0 ...
                             0 ...
                             xSize ...
                             30 ...
                             ],...
                'BackgroundColor', editorBackgroundColor ('get'), ...
                'ForegroundColor', editorForegroundColor('get'), ...
                'ShadowColor'    , editorShadowColor('get'), ...     
                'HighlightColor' , editorHighlightColor('get'), ...                              
                'title'   , 'Ready'...
                );
    uiEditorProgressWindowPtr('set', uiProgressWindow);
                                           
    lbFilesWindow = ...
        uicontrol(uiMainWindow,...
                  'style'   , 'listbox',...
                  'position', [0 ...
                               20 ...
                               250 ...
                               uiMainWindow.Position(4)-30-20 ...
                               ],...
                  'fontsize', 10,...
                  'Fontname', 'Monospaced',...
                  'Value'   , 1 ,...
                  'Selected', 'on',...
                  'enable'  , 'on',...
                  'string'  , ' ',...              
                  'Callback', @lbEditorFilesWindowCallback...
                  );
    lbEditorFilesWindowPtr('set', lbFilesWindow);
                    
    btnSortFiles = ...
        uicontrol(uiMainWindow,...
                  'Position', [0 ...
                               0 ...
                               250 ...
                               20 ...
                               ],...
                  'enable'  , 'off',...
                  'String'  , 'Sort',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                  
                  'Callback', @editorSortFilesCallback...
                  );                 
    btnEditorSortFilesPtr('set', btnSortFiles);
                    
    lbMainWindow = ...
        uicontrol(uiMainWindow,...
                  'style'   , 'listbox',...
                  'position', [250 ...
                               0 ...
                               uiMainWindow.Position(3)-250 ...
                               uiMainWindow.Position(4)-30 ...
                               ],...
                  'fontsize', 10,...
                  'Fontname', 'Monospaced',...
                  'Value'   , 1 ,...
                  'Selected', 'on',...
                  'enable'  , 'on',...
                  'string'  , ' ',...                   
                  'Callback', @lbEditorMainWindowCallback...
                  );    
    lbEditorMainWindowPtr('set', lbMainWindow);
                    
    btnOpen = ...
        uicontrol(dlgWindows,...
                  'Position', [5 ...
                               yPosition ...
                               100 ...
                               25 ...
                               ],...
                  'String'  , 'Open',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                   
                  'Callback', @editorSetSourceCallback...
                  );                                 
    btnEditorOpenPtr('set', btnOpen);
        
    btnWriteHeader = ...
        uicontrol(dlgWindows,...
                  'Position', [327 ...
                               yPosition ...
                               100 ...
                               25 ...
                               ],...
                  'enable'  , 'off',...
                  'String'  , 'Write Tag',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                   
                  'Callback', @editorWriteHeaderCallback...
                  );     
    btnEditorWriteHeaderPtr('set', btnWriteHeader);
                
    btnOptions = ...
         uicontrol(dlgWindows,...
                   'Position', [116 ...
                                yPosition ...
                                100 ...
                                25 ...
                                ],...
                   'String'  , 'Options',...
                   'BackgroundColor', editorBackgroundColor('get'), ...
                   'ForegroundColor', editorForegroundColor('get'), ...                    
                   'Callback', @setEditorOptionsCallback...
                   ); 
    btnEditorOptionsPtr('set', btnOptions);
                   
    btnGenUID = ...
        uicontrol(dlgWindows,...
                  'Position', [217 ...
                               yPosition ...
                               100 ...
                               25 ...
                               ],...
                  'String'  , 'Generate UID',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                   
                  'Callback', @editorGenerateUIDCallback...
                  );    
    btnEditorGenUIDPtr('set', btnGenUID);
                    
    btnSaveHeader = ...
        uicontrol(dlgWindows,...
                  'Position', [529 ...
                               yPosition ...
                               100 ...
                               25 ...
                               ],...
                  'enable'  , 'off',...
                  'String'  , 'Save Header',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                   
                  'Callback', @editorSaveDicomHeaderCallback...
                  );  
    btnEditorSaveHeaderPtr('set', btnSaveHeader);

     btnResetHeader = ...
        uicontrol(dlgWindows,...
                  'Position', [428 ...
                               yPosition ...
                               100 ...
                               25 ...
                               ],...
                  'enable'  , 'off',...
                  'String'  , 'Reset Header',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                   
                  'Callback', @editorResetHeaderCallback...
                  );  
    btnEditorResetHeaderPtr('set', btnResetHeader);   
    
     btnExportDicom = ...
        uicontrol(dlgWindows,...
                  'Position', [630 ...
                               yPosition ...
                               100 ...
                               25 ...
                               ],...
                  'enable'  , 'off',...
                  'String'  , 'Export Dicom',...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                   
                  'Callback', @editorExportDicomCallback...
                  );  
    btnEditorExportDicomPtr('set', btnExportDicom);       
    
    edtFindValue = ...
        uicontrol(dlgWindows,...
                  'enable'    , 'on',...
                  'style'     , 'edit',...
                  'Background', 'white',...
                  'string'    , '',...
                  'position'  , [xSize-256 ...
                                 yPosition+1 ...
                                 200 ...
                                 23 ...
                                 ],...
                  'BackgroundColor', editorBackgroundColor('get'), ...
                  'ForegroundColor', editorForegroundColor('get'), ...                                  
                  'Callback'  , @editorSearchTagCallback...
                  );   
    edtEditorFindValuePtr('set', edtFindValue);
                    
    btnSearchTag = ...
        uicontrol(dlgWindows,...
                  'Position', [xSize-55 ...
                               yPosition ...
                               50 ...
                               25 ...
                               ],...
                  'enable'  , 'on',...
                  'String'  , 'Find',...
                  'BackgroundColor', editorButtonBackgroundColor('get'), ...
                  'ForegroundColor', editorButtonForegroundColor('get'), ...                   
                  'Callback', @editorSearchTagCallback...
                  ); 
    btnEditorSearchTagPtr('set', btnSearchTag);
    
    editorMainWindowMenu();
                  
    dlgWindows.Resize = 'on';
    dlgWindows.WindowState = 'maximized';
    waitfor(dlgWindows, 'WindowState', 'maximized');
        
%    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    
%    if argInternal == true
%        sLogoPath = './dicomMultiFilesEditor/logo.png';
%    else
%        sLogoPath = './logo.png';
%    end
    
%    javaFrame = get(dlgWindows,'JavaFrame');
%    javaFrame.setFigureIcon(javax.swing.ImageIcon(sLogoPath));
    
    uiBar = uipanel(uiEditorProgressWindowPtr('get'));
    set(uiBar, 'BackgroundColor', editorBackgroundColor('get'));
    set(uiBar, 'ForegroundColor', editorForegroundColor('get'));     
    set(uiBar, 'ShadowColor'    , editorBackgroundColor('get'));
    set(uiBar, 'HighlightColor' , editorBackgroundColor('get'));     
    uiEditorProgressBarPtr('set', uiBar);
        
    if dIsCommandLine == true
        editorSetSource(true);                
    end                    
end