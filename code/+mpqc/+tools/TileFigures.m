function varargout = TileFigures(figs, Nrows, Ncols, monitor_id, spacer ,box)
% Tile figures over the desktop
%
% function TileFigures(figs, Nrows, Ncols, monitor_id, spacer ,box)
%
% Purpose
% Tile matlab figures, so that they can be viewed simultaneously, or just more easily managed.
%
% INPUT  :
%       figs : Handles (or indices) array of figures to arrange (default: all)
%      Nrows : Number of rows (vertical grid) of figures
%      Ncols : Number of columns (horizontal grid) of figures
% monitor_id : Monitor index to place images (default: same as matlab window)
%     spacer : Gap space between figures, specified as a ratio (0 <= spacer < 0.5),
%              either scalar or a 4-element vector:[left, down, right, up].
%              Should NOT exceed 0.5 in any direction, or sum to 1 (or more) in any dimension.
%        box : Define a subsection of the screen by [Woffset, Hoffset, Wportion, Hportion]
%              in which the figures will be confined.
%              All elements of 'box' are normalized i.e. in the range: (0 - 1)
%
%
%              - any or all of the above inputs can be manualy specified, or left
%                empty ([]) for default values.
%
% [config] = TileFigures(...)  - additionaly, returns the tile configuration for later re-use:
% TileFigures(config)          - reinstates figures to saved configuration.
%
%
% Examples
% TileFigures([], [], [], [], [], [])
% [config] = TileFigures(...)
% TileFigures(config)
%
% Or just run:
% TileFigures
%
%
% Created: Elimelech Schreiber 25/12/2018
% Edited:                      21/01/2019
% lemelech.bi@gmail.com
%
% inspired by leejaejun's code @:
% https://www.mathworks.com/matlabcentral/fileexchange/48480-automatically-arrange-figure-windows


%% Controls:
cascade = 20;      % cascade figures by this number of pixels (when too many figures), set to zero for total overlap.
maxGrid = [3, 6];  % maximum auto grid (doesn't apply to explicit values)
undock  = true;    % controls whether docked figures will be undocked or left docked.
task_bar_offset = [0, 50]; % [0, 50] : assumes bottom task bar.
%            use: [0, -50] for top task bar
%                 [50,  0] for left task bar
%                 [-50, 0] for Right task bar
%                 [0 ,  0] for no task bar
extendOnGrid = true; % controls whether figures will be automatically extended to empty grid slots.

%% Parse inputs:
if nargin < 6 || isempty(box)
    box = [0, 0, 1, 1];
end

if nargin < 5 || isempty(spacer)
    spacer  = [1, 1, 1, 1]/400;
else
    if numel(spacer) == 1
        spacer = ones(1,4) *spacer;
    end
    maxSpacer = 50;%percent
    assert(max(spacer(1:2) + spacer(3:4))<1,'The spacer specified leaves no space for figures.');
    assert(max(spacer(1:2) + spacer(3:4))<=maxSpacer/100,'Spacer must not exceed %d%.',maxSpacer);
end

if nargin < 4 || isempty(monitor_id)
    monitor_id = 1; % Force 1 by default because there is a bug in the original code here.
    % SEE:  https://github.com/lemelech/matlab-TileFigures/pull/1
end

if nargin < 3 || isempty(Ncols)
    Ncols = 0;
end

if nargin < 2 || isempty(Nrows)
    Nrows = 0;
end

if nargin < 1 || isempty(figs)
    figHandle = findobj('Type','figure');
    if isempty(figHandle)
        return
    end
    figHandle = sortFigureHandles(figHandle);
    figs = 1:length(figHandle);
elseif isnumeric(figs) && ~isempty(figs)   %figure indices
    if numel(figs) > length(figs) %matrix form
        if Ncols*Nrows == numel(figs) % provided correct size ->
            %convert to vector while preserving configuration:
            figs = figs';
            figs = figs(:)';
        else % just linearize;
            figs = figs(:)';
        end
    end
    figHandle = findobj('Type','figure');
    if isempty(figHandle)
        warning('No figures. Go figure...');
        return
    end
    figHandle = sortFigureHandles(figHandle);
    %h = ceil(h(h>0 & h <= length(figHandle))); % try to avoid errors
elseif isstruct(figs)
    TileFiguresStruct(figs);
    return
else
    figHandle = figs;
    figs = 1:length(figHandle);
end

n_fig = length(figs);

if n_fig <= 0
    warning('No figures. Go figure...');
    return
end


%% Get & set screen properties:
screen_sz = get(0,'MonitorPositions');
if monitor_id > size(screen_sz,1)
    warning('Matlab groot outdated, please restart matlab'); % Matlab graphic root is set at startup,
    %changes to screen setup after matlab has started are not tracked by
    %matlab and therefor cannot be accounted for.
    return;
end

screen_sz = screen_sz(monitor_id, :);
scn_w =  screen_sz(3) - abs(task_bar_offset(1));
scn_h =  screen_sz(4) - abs(task_bar_offset(2));
scn_w_begin = screen_sz(1) + max(0,task_bar_offset(1)) + box(1) * scn_w;
scn_h_begin = screen_sz(2) + max(0,task_bar_offset(2)) + box(2) * scn_h;
scn_w = box(3) * scn_w;
scn_h = box(4) * scn_h;

%% Determine grid size:
N_Grid = Nrows * Ncols;
if N_Grid == 0
    if Nrows == 0
        if Ncols == 0
            Nrows = max(floor(sqrt(n_fig)),1);
            Ncols = ceil(n_fig / Nrows);
        else
            Nrows = ceil(n_fig / Ncols);
        end
    elseif Ncols == 0
        Ncols = ceil(n_fig / Nrows);
    end


    if scn_w < scn_h
        tmp = Nrows;
        Nrows = min(Ncols,maxGrid(2));
        Ncols = min(tmp,maxGrid(1));
    else
        Nrows = min(Nrows,maxGrid(1));
        Ncols = min(Ncols,maxGrid(2));
    end
    N_Grid = Nrows * Ncols;
end


%% Extend figures to available grid slots:
extendOnGrid = extendOnGrid * 5;
while N_Grid > n_fig && extendOnGrid
    extra = N_Grid - n_fig;
    if  ~isnan(figs(end)) && figs(end)~= figs(end-1) %extend last row figures sideways
        xtend = min([extra, Ncols - extra, length(figs) - find(isnan(figs), 1, 'last')]);
        figXtend = repmat(unique(figs(end + 1 - xtend:end)), 2, 1);
        figs(end - xtend + (1:numel(figXtend))) = figXtend(:)';
    else %extend downwards
        figMat = zeros(Ncols, Nrows);
        figMat(1:n_fig) = figs;
        figMat = figMat';
        ind = find(figMat == 0);
        figMat(ind) = figMat(ind - 1);
        figs = figMat';
        figs = figs(:)';
    end
    n_fig = length(figs);
    extendOnGrid = extendOnGrid - 1; %prevent infinit loop
end

%% Calculate Tiled Figure positions:
spacer(3:4) = spacer(1:2) + spacer(3:4);
fig_width = scn_w / Ncols;
fig_height = scn_h / Nrows;
figsCopy = figs;

N_Grid = Ncols * Nrows;
for ii = 1:n_fig
    if isnan(figs(ii)) || figs(ii) < 1 || figs(ii) > length(figHandle) || ~isgraphics(figHandle(figs(ii)), 'figure')
        continue;
    end
    k = mod(ii-1, Ncols) +1; %column index (horizontal)
    l = mod((ii - k) / Ncols , Nrows) +1; %row index (vertical)
    overlap = floor((ii - 1) / (N_Grid));
    multiple = find(figs == figs(ii));
    last = multiple(end);
    nWidth = mod(last-1, Ncols) + 1;
    nHeight = max(mod((last - nWidth) / Ncols ,Nrows) +2 - l, 1);
    nWidth = max(nWidth + 1 - k, 1);
    fig_pos = [scn_w_begin + fig_width * (k-1) + overlap * cascade,...
        0,0,...
        min(nHeight * fig_height, scn_h - fig_height *(l + nHeight - 2) - overlap *cascade)];
    fig_pos(2:3) = [scn_h_begin + scn_h - fig_height *(l + nHeight - 2) - overlap *cascade - fig_pos(4),...
        min(nWidth * fig_width, scn_w - fig_pos(1) +  scn_w_begin)];
    fig_pos(1:2) = fig_pos(1:2) + spacer(1:2).*[fig_width, fig_height];
    fig_pos(3:4) = fig_pos(3:4) .* (1 - spacer(3:4));
    figs(multiple) = nan;
    fig_pos_cell{ii} = fig_pos;
end

TFstruct.figHandle = figHandle;
TFstruct.figs = figsCopy;
TFstruct.fig_pos_cell = fig_pos_cell;

% Tile figures:
TileFiguresStruct(TFstruct);

if nargout > 0
    varargout{1} = TFstruct;
end

%% Tile figures:
function TileFiguresStruct(TFstruct)
    for ii = 1:length(TFstruct.figs)
        if isnan(TFstruct.figs(ii)) || TFstruct.figs(ii)<1 || TFstruct.figs(ii)>length(TFstruct.figHandle) ||...
                ~isgraphics(TFstruct.figHandle(TFstruct.figs(ii)),'figure')
            continue;
        end
        if undock
            set(TFstruct.figHandle(TFstruct.figs(ii)),'WindowStyle','normal');
        end
        figure(TFstruct.figHandle(TFstruct.figs(ii)));
        originalUnits = get(TFstruct.figHandle(TFstruct.figs(ii)),'Units');
        set(TFstruct.figHandle(TFstruct.figs(ii)),'Units','Pixels','OuterPosition',TFstruct.fig_pos_cell{ii});
        set(TFstruct.figHandle(TFstruct.figs(ii)),'Units',originalUnits);
        multiple = find(TFstruct.figs == TFstruct.figs(ii));
        TFstruct.figs(multiple) = nan;
    end
end %TileFiguresStruct

end % Main


function figSorted = sortFigureHandles(figs)
    [~, idx] = sort([figs.Number]);
    figSorted = figs(idx);
end % sortFigureHandles
