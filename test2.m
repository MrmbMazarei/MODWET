%%start of program
clc
clear
close all
tic
%%dataloading----------------------------------------------------------
r=1;%parameter for repeat training network
Data=xlsread('Data.xlsx'); %Input the data with Excel format

for i=1:6 %number of input series . inputs plus output
    l=1; %this is an counter
    if i<6
    for j=1:41 %the number of years wich we have data for 
        for k=1:12 %The number of monthes
            X(l,i)=Data(j,(i-1)*12+k); %a matrix that organize the input data series
            l=l+1;
        end
    end
    l=1;
    elseif i==6
    % in this section we want to organize output time series in Y matrix
    for j=1:41
        for k=1:12
            Y(l,1)=Data(j,(i-1)*12+k);
            l=l+1;
        end
    end
    end
end

DataNum=size(X,1); %all of data number
InputNum=size(X,2); %Number of input series
OutputNum=size(Y,2); %Number of output series5

%%normalization----------------------------------------------------
MinX=min(X); %matrix for finding the maximum of input time series
MaxX=max(X); %matrix for finding the minimum of input time series

MinY=min(Y); %matrix for finding the maximum of output time series
MaxY=max(Y); %matrix for finding the minimum of output time series

XN=X; %matrix for normalized input data
YN=Y; %matrix for normalized output data

%in this section we normalize the input time series
for ii=1:InputNum
    XN(:,ii)=Normalize_Fcn(X(:,ii),MinX(ii),MaxX(ii));
end

%in this section we normalize the output time series
for ii=1:OutputNum
    YN(:,ii)=Normalize_Fcn(Y(:,ii),MinY(ii),MaxY(ii));
end

%%test & train data------------------------------------------------
TrPercent=70; %percentage of allocation data for training
TrNum=round(DataNum*TrPercent/100); %Number of data for training
TsNum=DataNum-TrNum; %Number of data for test
R=randperm(DataNum); %random matrix
trIndex=R(1:TrNum); %random numbers for train matrix
tsIndex=R(1+TrNum:end); %random numbers for test matrix

Xtr=XN(trIndex,:); %train data that by random selection is selected for input
Ytr=YN(trIndex,:); %train data that by random selection is selected for output

Xts=XN(tsIndex,:); %test data that by random selection is selected for input
Yts=YN(tsIndex,:); %test data that by random selection is selected for output

train_size=size(Ytr,1);
test_size=size(Yts,1);

% by this section we find the mean of the out put train data
sum=0;
for i=1:train_size
    sum=sum+Ytr(i);
end
Ytr_mean=sum/train_size;

% by this section we find the mean of the out put test data
sum=0;
for i=1:test_size
    sum=sum+Yts(i);
end
Yts_mean=sum/test_size;

%define the network structure ------------------------------------------------
%a network with 2 layers. first layer has tangantSigmuid transfer function 
%and second layer has pureLine transfer function
pr=[-1 1];
PR=repmat(pr,InputNum,1);
Network=newff(PR,[5 OutputNum],{'tansig','purelin'},'traingd');
%we can adjust manualy the number of epochs:
Network.trainParam.epochs = 10000; 

%%training network with datas that get in
for o=1:r
Network=train(Network,Xtr',Ytr');

%%assesment
YtrNet=sim(Network,Xtr'); %Export of network for train periode
YtsNet=sim(Network,Xts'); %Export of network for test periode

%Mean calculation for train period
sum=0;
for i=1:train_size
    sum=sum+YtrNet(i);
end
YtrNet_mean=sum/train_size;

%Mean calculation for test period
sum=0;
for i=1:test_size
    sum=sum+YtsNet(i);
end
YtsNet_mean=sum/test_size;

%calculation MS Error for train and test period
MSEtr(o)=mse(YtrNet-Ytr');
MSEts(o)=mse(YtsNet-Yts');

sum=0;
sum1=0;
sum2=0;
sum3=0;
for i=1:train_size
    sum=sum+(Ytr(i)-YtrNet(i))^2;
    sum1=sum1+(Ytr(i)-Ytr_mean)^2;
    sum2=sum2+(YtrNet(i)-YtrNet_mean)^2;
    sum3=sum3+(Ytr(i)-Ytr_mean)*(YtrNet(i)-YtrNet_mean);
end
NSEtr(o)=1-sum/sum1; %Nash Satclif Error for train period
R2_Corr_tr(o)=(sum3/(sum1^0.5)/(sum2^0.5))^2; %R2 Error for train period

sum=0;
sum1=0;
sum2=0;
sum3=0;
for i=1:test_size
    sum=sum+(Yts(i)-YtsNet(i))^2;
    sum1=sum1+(Yts(i)-Yts_mean)^2;
    sum2=sum2+(YtsNet(i)-YtsNet_mean)^2;
    sum3=sum3+(Yts(i)-Yts_mean)*(YtsNet(i)-YtsNet_mean);
end
NSEts(o)=1-sum/sum1;
R2_Corr_ts(o)=(sum3/(sum1^0.5)/(sum2^0.5))^2;

end
%%Realization
YRtr=YtrNet;
YRts=YtsNet;

%reverse normal exports to the real condition for train period
for ii=1:OutputNum
    YRtr(ii,:)=Realization_Fcn(YtrNet(ii,:),MinY(ii),MaxY(ii));
end

%reverse normal exports to the real condition for test period
for ii=1:OutputNum
    YRts(ii,:)=Realization_Fcn(YtsNet(ii,:),MinY(ii),MaxY(ii));
end

%%Display
figure(1)
plot(Ytr,'-sb')
hold on
plot(YtrNet,'-or')
hold off

figure(2)
plot(Yts,'-sb')
hold on
plot(YtsNet,'-or')
hold off

figure(3)
t=-1:0.1:1;
plot(t,t,'b','linewidth',2)
hold on
plot(Ytr,YtrNet,'ok')
hold off

figure(4)
t=-1:0.1:1;
plot(t,t,'b','linewidth',2)
hold on
plot(Yts,YtsNet,'ok')
hold off
toc