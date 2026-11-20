function[Jt]=J(x,e,xin);
%This function computes the integral
%of 1/(1+e*cos(x))^2
%from xmin to x.
%It could be xmin>x
s=0;
N=10000;
tt=linspace(xin,x,N);
dt=tt(2)-tt(1);
f=1./(1+e*cos(tt)).^2;
f(1)=f(1)/2;
f(N)=f(N)/2;
Jt=f*ones(N,1)*dt;
