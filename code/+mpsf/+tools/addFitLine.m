function varargout=addFitLine(poolFits,modelType,lineprops,ax)
% function varargout=addFitLine(poolFits,modelType,lineprops,ax)
%
% Purpose
% Add one or more fit lines to some or all data in axes "ax" or,
% without ax specified, to the current axes.
%
% Inputs
%  * poolFits [optional 0 by default] -
%    if 1 we fit a single line to all data series on the current
%    axes.
%  * modelType ['linear' by default] - If 'linear' it fits a straight line
%    using the regress function from the stats toolbox. If 'quadratic' it
%    fits a second-order polynomial using regress. The output from regress is
%    returned. If modelType is an integer, the function fit a polynomial of
%    this order using polyfit, which is not part of the stats toolbox. The
%    output of polyfit is then returned.
%  * lineprops [optional 'b-' by default]
%  * ax [optional - gca by default]
%
% Outputs
% out - the fit parameters and plot handles
%
%
%
% Examples
% clf
% %Fit two seperate lines
% subplot(1,3,1), hold on, x=-5:0.1:5;
% y=1+1*x+randn(size(x))*2; plot(x,y,'.k')
% y=2-4*x+randn(size(x))*2; plot(x,y,'.r')
% H=addFitLine;
%
% %Fit one line to two sets of data
% subplot(1,3,2), hold on
% x=-5:0.2:0; y=0.3*x+randn(size(x))*2; plot(x,y,'.k')
% x=0:0.2:5; y=0.3*x+randn(size(x))*2; plot(x,y,'.r')
% H=addFitLine(1);
%
% %Fit one quadratic
% subplot(1,3,3)
% x=-5:0.1:5;
% y=2+0.3*x+0.5*x.^2+randn(size(x))*2;
% plot(x,y,'.k')
% addFitLine([],'quadratic');
% OR:
% addFitLine([],2);
%
%
% Rob Campbell, CSHL, December 2009


if nargin<1 || isempty(poolFits),  poolFits=0;     end
if nargin<2 || isempty(modelType), modelType='linear'; end
if nargin<3 || isempty(lineprops), lineprops='b-'; end
if nargin<4 || isempty(ax),        ax=gca;         end

if ~iscell(lineprops)
    lineprops={lineprops};
end




%Get data
chil=get(ax,'children');

%Remove inappropriate axis elements
chil(strmatch('text',get(chil,'type')))=[];
chil(strmatch('patch',get(chil,'type')))=[];


xdata=get(chil,'xdata');
ydata=get(chil,'ydata');

COL=get(chil,'color');
if ~iscell(COL)
    COL={COL};
end


if poolFits
    xdata={[xdata{:}]};
    ydata={[ydata{:}]};
end

if ~iscell(xdata)
    xdata={xdata};
    ydata={ydata};
end


% Hold if needed
holdStatus=ishold;

if ~holdStatus
    hold on
end


% Do the plotting
for ii=1:length(xdata)

    % Get X and Y data for this data series
    x=xdata{ii}(:);
    y=ydata{ii}(:);

    switch lower(modelType)
        case 'linear'
            x=[ones(size(x)),x];
            [out(ii).b,out(ii).bint,out(ii).r,~,out(ii).stats]=regress(y,x);

            X=[min(x(:,2)),max(x(:,2))];
            out(ii).handles=plot(X,out(ii).b(1)+X*out(ii).b(2),lineprops{:},...
                'color',COL{ii});

        case 'quadratic'
            x=[ones(size(x)),x,x.^2];
            [out(ii).b,out(ii).bint,out(ii).r,~,out(ii).stats]=regress(y,x);

            X=[min(x(:,2)):1/length(x):max(x(:,2))];
            out(ii).handles=...
                plot(X, out(ii).b(1) + out(ii).b(2)*X + out(ii).b(3)*X.^2,...
                lineprops{:});

        otherwise
            if isnumeric(modelType)
                % For some reason we have to sort the data to get a sensible fit
                [x,ind]=sort(x);
                y = y(ind);
                [out(ii).b,out(ii).delta] = polyfit(x,y,modelType);

                f=polyval(out(ii).b,x);
                out(ii).handles=plot(x,f,lineprops{:},'color',COL{ii});
            end

    end % switch

end % for ii=1:length(xdata)

%Return hold status to what it was before this function was called
if ~holdStatus
    hold off
end

if nargout==1
  varargout{1}=out;
end
