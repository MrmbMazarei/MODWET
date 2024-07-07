clear all
close all
clc

Data_s1 = xlsread('ST_01013500.xlsx','Mon_Normal');
N=size(Data_s1,1);
Data=Data_s1(:,4);
J=3;
[Lo,Hi] = wfilters('fk4');
L=size(Lo,2);
for J2=1:J
LJ=((2^J2)-1)*(L-1)+1;
MODWT_Dec=modwt(Data,Lo,Hi,J2);

grid on
hold on
for i=1:J2
    plot(1:N,MODWT_Dec(i,:),'g');
end
plot(1:N,Data(:),'r');
plot(1:N,MODWT_Dec(J2+1,:),'b');
xlabel('t')
ylabel('Runoff','fontsize',14)
title('MODWT')

for j=1:J2+1
       x=MODWT_Dec(j,:);
       x=x';
       ENTROPY(j)=Func1(x);
end

x=Data(:);
ENTROPY(J2+2)=Func1(x);

if ENTROPY(J2+2)>mean(ENTROPY(1:J2+1))
   disp('Do the next level')
   J2
   ENTROPY(J2+2)
   mean(ENTROPY(1:J2+1))
   Dec(J2)=1;
else
   disp('This level doesnt help')
   J2
   ENTROPY(J2+2)
   mean(ENTROPY(1:J2+1))
   Dec(J2)=0;
end

end