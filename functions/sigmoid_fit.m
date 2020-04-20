function [params,errors,f] = sigmoid_fit(time,data)
% Fits sigmoid to data of shape [cells,timesteps] and corresponding time data of shape [timesteps]
%Inputs: 
%   time - time vector
%   data - data of shape [cells,timesteps]
% Returns:
%   params - 
%   errors - errors of paramters
%   f - the sigmoid function
% The fitted sigmoid function f has the equation of:
%   f = @(p,xdata) p1/(1+exp(-p2*(xdata-p3)))+p4 ,where:
%   p1 : amplitude
%   p2 : rate
%   p3 : offset / timepoint of inflexion point
%   p4 : baseline

time=time'; %transpose time to be compatible with lsqcurvefit function

f = @(p,xdata) p(1)./(1+exp(-p(2)*(xdata-p(3))))+p(4); %sigmoid function

% upper/lower boundaries notation: UB/LB
UB_baseline=100;
LB_baseline=-100;

for i=1:size(data,1)
    %find index that holds closes value to the half maximum of time series
    [~,mid_index]=min(abs(data(i,:)-(max(data(i,:))/2)));
    %convert to time
    guess_offset=time(mid_index);
    
    x0 = [data(i,end),0.001,guess_offset,0];   %initial parameters
    lb = [0,0.00001,guess_offset*0.5,LB_baseline];   %lower boundaries of parameters p(1,2,3,4)
    ub = [1.5*max(data(i,:)),1,guess_offset*1.5,UB_baseline];   %upper boundaries of parameters
    
    [params(i,:),errors(i)] = lsqcurvefit(f,x0,time,data(i,:),lb,ub);
end


end

