
% X  : is the timeseries
% N  : is the number of samples in timeseries
% Y  : is the calculated Entropy
function Entropy=Func1(X)
         %Data= xlsread('ST_01013500.xlsx','forcing');
         %X=Data(:,12);
         X1=sort(X);
         Min_X=min(X1);
         Max_X=max(X1);
         AVE=mean(X1);
         STDEV=std(X1);
         N=size(X1);
         for i=1:N
             X1_PDF(i,1)=(1/sqrt(2*pi*(STDEV^2)))*exp(-(X1(i)-AVE)^2/(2*STDEV^2));
         end


         syms x
         f=(1/sqrt(2*pi*(STDEV^2)))*exp(-(x-AVE)^2/(2*STDEV^2));
         %CDF=int(f,-100,100);
         %display('Area: '), disp(double(CDF));
         %plot(X1,X1_PDF)

         Entropy=0;
         for i=N
             Entropy=Entropy-X1_PDF(i,1)*log(X1_PDF(i,1))/log(10);
         end
end