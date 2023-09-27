function [figHandle] = CirHeatmap(Data, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   CircHeatmap written by Joshua A. Welsh
%   Created: 1 June 2018
%   Last Edit: 13 June 2018
%   Modified by Reno Filla on 13 September 2023
%
% INPUTS:
%
%   'CircType' - 'o' full circle,'tq' 3/4 circle, 'half' semi-circle
%                'compass' for a full circle where North = 0, East = 90, South = 180, West = 270
%     
%   'OuterLabels' - follow by 1 x n cell array of strings
%   'OuterLabelFontSize' - follow by single numeric value
%   'OuterLabelFontWeight' - 'normal', 'bold'
%
%   'GroupLabels' - follow by 1 x n cell array of strings
%   'GroupLabelsOffset' - follow by single  value
%   'GroupLabelTextSize' - follow by single numeric value
%   'GroupLabelFontWeight' - 'normal', 'bold'
%
%   'InnerSpacerSize' - follow by numeric value (recommend between 0.1-1)
%                       (default: 0.4)
%   
%   'Colormap' - follow by colormap name (default: 'Jet')
%   'EdgeColor' - follow by color e.g. 'k'. (default: 'none')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Mandatory Variable Check

if ~exist('Data','var') || isempty(Data)
    error('Data Array Input mandatory');
end


%% Obtain input variables

[~, ~, args] = parseplotapi(varargin{:},'-mfilename',mfilename);

[p] = InputParamCheck(args,Data);

%%
Data_L = size(Data,1); % determine the number of circular heatmap rings from cell array length

for jj = 1:Data_L
    
    Tot_Samples_L(jj) = size(Data{jj},2); % total number of samples
    
end
p.CentOffset;
Sample_Space_E = p.CentOffset; % starting spacer from the middle
index = 1;

for jj = 1:Data_L
    
    if jj>1
        index = jj-1;
    else
    end
    
    Sample_Space_S(jj) = Sample_Space_E(index) + 2.5; % group start
    Sample_Space_E(jj) = (Sample_Space_S(jj) + Tot_Samples_L(jj)); % group end
    
end

Colors = lines(Data_L); % group label colors
%% Fixed Variables

n = size(Data{1},1);    % number of markers

switch p.CircleType
    case 'compass'
        theta = pi*(-1/2-(-(n/2):(1*(n/2)))/(n/2));  % theta coordinates for number of columns
    case 'o'
        theta = pi*(-(n/2):(1*(n/2)))/(n/2);  % theta coordinates for number of columns
    case 'tq'
        min = deg2rad(90);
        max = deg2rad(360);
        theta = linspace(min,max,n+1);  % theta coordinates for number of columns
    case 'half'
        min = deg2rad(90);
        theta = linspace(min,min+deg2rad(180),n+1);  % theta coordinates for number of columns
end


%% Plotting Loop
figHandle = figure('units','normalized','outerposition',[0 0 0.5 1]);
ax = axes();
hold(ax,'on')

for jj = 1:Data_L
    
    PlotDataX = zeros(size(Data{jj},1)+1,size(Data{jj},2)+1);   % add a zero column to data array
    PlotDataX(1:end-1,1:end-1) = Data{jj};                      % merge data array with zero column
    
    n2 = size(Data{jj},2);    % number of samples
    
    r = (Sample_Space_S(jj):Sample_Space_E(jj))'; % number of rows
    
    Plot_X = r*cos(theta);
    Plot_Y = r*sin(theta);
    
    Plot_C = r*cos(2*theta);
    Plot_C2 = (PlotDataX)';
    
    heatmapHandle(jj) = pcolor(ax, Plot_X, Plot_Y, Plot_C2(:,1:end));
    axis equal tight
    
    switch p.Colormap
        case {'thermal','haline','solar','ice','gray','oxy','deep',...
                'dense','algae','matter','turbid','speed','amp','tempo'}
            cmocean(p.Colormap)
        case {'balance', 'delta', 'curl'}
            cmocean(p.Colormap,'pivot',0)
        otherwise
            colormap(p.Colormap)
    end
    
    xticklabels('');
    yticklabels('');

    set(ax,'XColor','none','YColor','none','color','none')
    set(heatmapHandle(jj), 'EdgeColor', p.EdgeColor,'Tag','Heatmap');
    
    hold on
    
    switch p.CircleType
        case {'o', 'compass'}
        case {'tq', 'half'}
            switch p.ShowGroupLabels
                case 'on'
                    plot(ones(1,numel(r))+p.GroupLabelOffset-1.5, Plot_Y(:,1), 'LineWidth', p.GroupLabelLineWidth,'Color', Colors(jj,:))
                    text(p.GroupLabelOffset, mean(Plot_Y(:,1)), p.GroupsLabels(jj), 'FontWeight',p.GroupLabelFontWeight,'FontSize',p.GroupLabelFontSize)
                case 'off'
            end
    end
    
end

switch p.CircleType
    case {'o', 'compass'}
        c=colorbar('manual');
        c.Position = [0.95 0.78 0.01 0.2];
    case {'tq', 'half'}
        c=colorbar('manual');
        c.Position = [0.9 0.70 0.01 0.2];
end

%% plot labels
switch p.ShowYLabels
    case 'on'
        
        Plot_T_X = Plot_X(end,1:end) * 1.01; % Label X position + fudge factor for space
        Plot_T_Y =  Plot_Y(end,1:end) * 1.01; % Label Y position + fudge factor for space
        
        for i = 1:numel(Plot_T_X)-1
            if i == numel(Plot_T_X)
                T_X(i) = mean([Plot_T_X(i), Plot_T_X(1)]);
                T_Y(i) = mean([Plot_T_Y(i), Plot_T_Y(1)]);
            else
                T_X(i) = mean([Plot_T_X(i), Plot_T_X(i+1)]);
                T_Y(i) = mean([Plot_T_Y(i), Plot_T_Y(i+1)]);
            end
        end
        
        t = text(T_X, T_Y, (p.Ylabels(:)), 'FontSize', p.OuterLabelFontSize, 'FontWeight', p.OuterLabelFontWeight);
        textrotate=(theta(2:end)'*180/pi);
        
        for ii = 1:numel(textrotate)
            if textrotate(ii) < -90 || textrotate(ii) > 90
                textpos(ii) = textrotate(ii) - 180;
                set(t(ii), {'Rotation'},num2cell(textpos(ii)), 'HorizontalAlignment', 'right')
            else
                textpos(ii) = textrotate(ii);
                set(t(ii), {'Rotation'},num2cell(textpos(ii)))
            end
        end
        
    case 'off'
end


end


function [p] = InputParamCheck(args, Data)

CharInputs=[];

for ii = 1:numel(args)
    if ischar(args{ii}) == 1
        CharInputs{numel(CharInputs)+1} = args{ii};
        CharPosition(numel(CharInputs)) = ii;
    else
    end
end

%% Check for Circular Specification
if max(strcmp('CircType', CharInputs)) == 1
    p.CircleType = args{CharPosition(strcmp('CircType', CharInputs))+1};
    switch p.CircleType
        case {'o','compass','tq','half'}
        otherwise
            error('CircType must be ''o'',''compass'', ''tq'', or ''half''')
    end
else
    p.CircleType = 'tq';
end

%% Check for Y Labels
if  max(strcmp('OuterLabels', CharInputs)) == 1
    p.ShowYLabels = 'on';
    p.Ylabels = args{CharPosition(strcmp('OuterLabels', CharInputs))+1};
    
    
else
    p.ShowYLabels = 'off';
end

%% Check for Y Label Font Size
if  max(strcmp('OuterLabelFontSize', CharInputs)) == 1
    p.OuterLabelFontSize = args{CharPosition(strcmp('OuterLabelFontSize', CharInputs))+1};
    if isnumeric(p.Ylabels) == 1
    else
        error('OuterLabelFontSize must be numeric input')
    end
else
    p.OuterLabelFontSize = 10;
end

%% Check for Y Label Font Weight
if  max(strcmp('OuterLabelFontWeight', CharInputs)) == 1
    p.OuterLabelFontWeight = args{CharPosition(strcmp('OuterLabelFontSize', CharInputs))+1};
    switch p.OuterLabelFontWeight
        case {'normal','bold'}
        otherwise
            error('OuterLabelFontWeight must be ''normal'', or ''bold''')
    end
else
    p.OuterLabelFontWeight = 'normal';
end

%% Check for Group Labels
if  max(strcmp('GroupLabels', CharInputs)) == 1
    p.ShowGroupLabels = 'on';
    p.GroupsLabels = args{CharPosition(strcmp('GroupLabels', CharInputs))+1};
else
    p.ShowGroupLabels = 'off';
end

%% Check for Group Label Line Width
if  max(strcmp('GroupLabelLineWidth', CharInputs)) == 1
    p.GroupLabelLineWidth = args{CharPosition(strcmp('GroupLabelLineWidth', CharInputs))+1};
    if isnumeric(p.GroupLabelLineWidth) == 1
    else
        error('GroupLabelLineWidth must be numeric input')
    end
else
    p.GroupLabelLineWidth = 4;
end

%% Check for Group Label LineWdith
if  max(strcmp('GroupLabelsOffset', CharInputs)) == 1
    p.GroupLabelOffset = args{CharPosition(strcmp('GroupLabelsOffset', CharInputs))+1};
    if isnumeric(p.GroupLabelOffset) == 1
    else
        error('GroupLabelsOffset must be numeric input')
    end
else
    p.GroupLabelOffset = 1;
end

%% Check for Group Label Text Size
if  max(strcmp('GroupLabelTextSize', CharInputs)) == 1
    p.GroupLabelFontSize = args{CharPosition(strcmp('GroupLabelTextSize', CharInputs))+1};
    if isnumeric(p.GroupLabelFontSize) == 1
    else
        error('GroupLabelTextSize must be numeric input')
    end
else
    p.GroupLabelFontSize = 14;
end

%% Check for Group Label Font Weight
if  max(strcmp('GroupLabelFontWeight', CharInputs)) == 1
    p.GroupLabelFontWeight = args{CharPosition(strcmp('GroupLabelFontWeight', CharInputs))+1};
    switch p.GroupLabelFontWeight
        case {'normal','bold'}
        otherwise
            error('GroupLabelFontWeight must be ''normal'', or ''bold''')
    end
else
    p.GroupLabelFontWeight = 'bold';
end

%% Check for Inner Space Size Specification
if  max(strcmp('InnerSpacerSize', CharInputs)) == 1
    p.CentOffset = args{CharPosition(strcmp('InnerSpacerSize', CharInputs))+1};
    if isnumeric(p.CentOffset) == 1
           Data_L = size(Data,1); % determine the number of circular heatmap rings from cell array length
    for jj = 1:Data_L
        Tot_Samples_L(jj) = size(Data{jj},2); % total number of samples
    end
    p.CentOffset = round((sum(Tot_Samples_L))*p.CentOffset);
    else
        error('InnerSpacerSize must be numeric input')
    end
    
else
    Data_L = size(Data,1); % determine the number of circular heatmap rings from cell array length
    for jj = 1:Data_L
        Tot_Samples_L(jj) = size(Data{jj},2); % total number of samples
    end
    p.CentOffset = round((sum(Tot_Samples_L))*0.4);
end

%% Check for Colormap Input
if  max(strcmp('Colormap', CharInputs)) == 1
    p.Colormap = args{CharPosition(strcmp('Colormap', CharInputs))+1};

else
    p.Colormap = 'jet';
end

%% Check for EdgeColor Input
if  max(strcmp('EdgeColor', CharInputs)) == 1
    p.EdgeColor = args{CharPosition(strcmp('EdgeColor', CharInputs))+1};

else
    p.EdgeColor = 'none';
end
end

