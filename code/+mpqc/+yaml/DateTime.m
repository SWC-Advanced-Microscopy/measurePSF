classdef DateTime
        Copyright (c) 2011
        This program is a result of a joined cooperation of Energocentrum
        PLUS, s.r.o. and Czech Technical University (CTU) in Prague.
        The program is maintained by Energocentrum PLUS, s.r.o. and
        licensed under the terms of MIT license. Full text of the license
        is included in the program release.
        Author(s):
        Jiri Cigler, Dept. of Control Engineering, CTU Prague & Automatic Control Laboratory, ETH Zurich
        Jan  Siroky, Energocentrum PLUS s.r.o.
        Implementation and Revisions:
        Auth  Date        Description of change
        ----  ---------   -------------------------------------------------
        jc    01-Mar-11   First implementation
        jc    30-Sep-11   Added function colon
        jc    07-Jan-12   Added functions addtodate,datevec,weekday
    properties
        serialDate
    end
    methods
import mpqc.yaml.*;


function this = DateTime(varargin)            if numel(varargin)==1 && isa(varargin{1},'java.util.Date')
                    sec = varargin{1}.getTime/1000;
                    this.serialDate=datenum(1970,1,1,0,0,sec);
            else
                this.serialDate=datenum(varargin{:});
            end
        end
import mpqc.yaml.*;
function this = plus(this,val)            o =@plus;
            this = doFun(this,o,val);
        end
import mpqc.yaml.*;
function this = minus(this,val)            o =@minus;
            this = doFun(this,o,val);
        end
import mpqc.yaml.*;
function this = times(this,val)            o =@times;
            this = doFun(this,o,val);
        end
import mpqc.yaml.*;
function this = mtimes(this,val)            o =@mtimes;
            this = doFun(this,o,val);
        end
import mpqc.yaml.*;
function this = mrdivide(this,val)            o =@mrdivide;
            this = doFun(this,o,val);
        end
import mpqc.yaml.*;
function this = rdivide(this,val)            o =@rdivide;
            this = doFun(this,o,val);
        end
import mpqc.yaml.*;
function this = horzcat(this,varargin)            for i=1:numel(varargin)
                this.serialDate = [this.serialDate, varargin{i}.serialDate];
            end
        end
import mpqc.yaml.*;
function out = colon(this,step,to)            vect = [double(this):double(step):double(to)]';
            out =DateTime(vect);
        end
import mpqc.yaml.*;
function this = vertcat(this,varargin)            for i=1:numel(varargin)
                this.serialDate = [this.serialDate; varargin{i}.serialDate];
            end
        end
import mpqc.yaml.*;
function this = ctranspose(this)            this.serialDate = this.serialDate';
        end
import mpqc.yaml.*;
function this = transpose(this)            this.serialDate = this.serialDate';
        end
import mpqc.yaml.*;
function  disp(this)            disp([this.serialDate])
        end
import mpqc.yaml.*;
function out = double(this)            out = this.serialDate;
        end
import mpqc.yaml.*;
function out = length(this)            out = length(this.serialDate);
        end
import mpqc.yaml.*;
function out = size(this,varargin)            out = size(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function out = numel(this)            out = numel(this.serialDate);
        end
import mpqc.yaml.*;
function out = isreal(this)            out = isreal(this.serialDate);
        end
import mpqc.yaml.*;
function out = isnan(this)            out = isnan(this.serialDate);
        end
import mpqc.yaml.*;
function out = isfinite(this)            out = isfinite(this.serialDate);
        end
import mpqc.yaml.*;
function out = le(this,B)            if isa(B,'DateTime')
                out = le(this.serialDate,B.serialDate);
            else
                out = le(this.serialDate,B);
            end
        end
import mpqc.yaml.*;
function out = lt(this,B)            fun=@lt;
            if isa(B,'DateTime')
                out = fun(this.serialDate,B.serialDate);
            else
                out = fun(this.serialDate,B);
            end
        end
import mpqc.yaml.*;
function out = gt(this,B)            fun=@gt;
            if isa(B,'DateTime')
                out = fun(this.serialDate,B.serialDate);
            else
                out = fun(this.serialDate,B);
            end
        end
import mpqc.yaml.*;
function out = eq(this,B)            fun=@eq;
            if isa(B,'DateTime')
                out = fun(this.serialDate,B.serialDate);
            else
                out = fun(this.serialDate,B);
            end
        end
import mpqc.yaml.*;
function out = diff(this)            out = diff(this.serialDate);
        end
import mpqc.yaml.*;
function out = norm(this,varargin)            out = norm(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function [this k] = sort(this,varargin)            [this.serialDate k] = sort(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function this = subsref(this,S)            if isa(S.subs{1},'DateTime')
                S.subs{1}=double(S.subs{1});
            end
            this.serialDate =  subsref(this.serialDate,S);
        end
import mpqc.yaml.*;
function idx = subsindex(this)            idx = double(this)-1;
        end
import mpqc.yaml.*;
function endidx = end(this,k,n)              if size(this.serialDate,1)==1 || size(this.serialDate,2)==1
                endidx=numel(this.serialDate);
            else
                endidx = size(this.serialDate,k);
            end
        end
import mpqc.yaml.*;
function this = subsasgn(this, S, B)            if not(isa(B,'DateTime'))
                B=DateTime(B);
            end
            this.serialDate =subsasgn(this.serialDate, S, B);
        end
import mpqc.yaml.*;
function res = bsxfun(fun,A,B)            res = fun(A,B);
        end
import mpqc.yaml.*;
function out =superiorfloat (x,y,xi)            if isa(x,'DateTime') && isa(xi,'DateTime')
                out = superiorfloat(x.serialDate,y,xi.serialDate);
            elseif isa(x,'DateTime') && not(isa(xi,'DateTime'))
                out = superiorfloat(x.serialDate,y,xi);
            elseif not(isa(x,'DateTime')) && isa(xi,'DateTime')
                out = superiorfloat(x,y,xi.serialDate);
            else
                out = superiorfloat(x,y,xi);
            end
        end
import mpqc.yaml.*;
function this = floor(this)            this.serialDate = floor(this.serialDate);
        end
import mpqc.yaml.*;
function this = max(this,varargin)            this.serialDate = max(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function this = min(this,varargin)            this.serialDate = min(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function out = datestr(this,varargin)            out = datestr(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function out = addtodate(this,varargin)            out = addtodate(this.serialDate,varargin{:});
        end
import mpqc.yaml.*;
function varargout= datevec(this,varargin)            nout = nargout;
            if nout <=1
                varargout{1} = datevec(this.serialDate,varargin{:});
            elseif nout ==2
                [varargout{1} varargout{2}] = datevec(this.serialDate,varargin{:});
            elseif nout ==3
                [varargout{1} varargout{2} varargout{3}] = datevec(this.serialDate,varargin{:});
            elseif nout ==4
                [varargout{1} varargout{2} varargout{3} varargout{4}] = datevec(this.serialDate,varargin{:});
            elseif nout ==5
                [varargout{1} varargout{2} varargout{3} varargout{4} varargout{5} ] = datevec(this.serialDate,varargin{:});
            elseif nout ==6
                [varargout{1} varargout{2} varargout{3} varargout{4} varargout{5} varargout{6} ] = datevec(this.serialDate,varargin{:});
            else
                error('Unknown function call');
            end
        end
    end
    methods (Access = private)
import mpqc.yaml.*;
function this = doFun (this,o, val)
