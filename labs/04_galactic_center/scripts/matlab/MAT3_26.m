clear all
clf
clc

%READ THE DATA FROM DATAfile.mat
DATR=load('DATAfile.mat');
x1=DATR.DAT(1,:);
y1=DATR.DAT(2,:);
tim=DATR.DAT(3,:);

set(gca,'Ydir','Reverse');
No=length(tim);

%OPEN THE FILE WITH DATA. 
%p,e,phi,iota are also included in this file.
DATphys=load('MAT_DATA_phys');
res=DATphys.res;
phi=(res(1))*pi/180;
inc=(res(2))*pi/180;
e=res(3);
p=res(4);

c=cos(inc);

figure(1)
r1=sqrt((x1./c).^2+y1.^2);
th1=0.5.*((1-sign(x1./c)).*(pi-asin(y1./r1))+(sign(x1./c)+1).*asin(y1./r1))-phi;
x1r=r1.*cos(th1);
y1r=r1.*sin(th1);
r=[x1r;y1r];

%the best fitting ellipse
NR=200;
tth=linspace(0,2*pi,NR);
rr=p./(1+e.*cos(tth));
xr=rr.*cos(tth);
yr=rr.*sin(tth);
%%%%%%%%%%%%%%%%%%%%%%%%%
plot(x1r,y1r,'or',0,0,'ok',xr,yr,'--r')
axis equal
for i=1:No
text(x1r(i),y1r(i),['\leftarrow',num2str(tim(i))],'Color','black','FontSize',14,'Rotation',-20)
end
hold off

% Building the sequence of succesive angular positions.
% They could increase or decrease (on average).
% Bad observational data may may disrupt the monotonicity.
th(1)=th1(1);
for i=2:No
    Dth(i-1)=acos(r(:,i)'*r(:,i-1)/(norm(r(:,i))*norm(r(:,i-1))));
    S(i-1)=sign(r(1,i-1)*r(2,i)-r(2,i-1)*r(1,i));
    if Dth(i-1)>pi/2 & S(i-1)<0
        extr=1;
    else extr=0;
    end
    th(i)=th(i-1)+S(i-1)*(Dth(i-1)*(1-extr))+extr*(2*pi-Dth(i-1));
end
    
%USE THE FUNCTION J THAT COMPUTES J(theta,e,theta_in)
for i=1:No
    Jth(i)=J(th(i),e,th(1));
end

figure(2)
plot(tim,Jth,'ok')
hold on
xlabel('time (yrs)','FontSize',12,'FontWeight','bold','Color','k')
ylabel('J(\theta,e,\theta_0)','FontSize',12,'FontWeight','bold','Color','k')
drawnow;
for i=1:No
    text(tim(i),Jth(i),['\leftarrow',num2str(tim(i))],'Color','r')
end

%Linear fitting of J(theta) vs time
linea=polyfit(tim,Jth,1);
linea(1);
linea(2);

plot(tim,linea(1)*tim+linea(2),'k')
xlim([tim(1) tim(end)])
hold off

%disp(['slope=',num2str(linea(1))]);
scal1 = input('Give me the scale m/pixels: ');
scal2 = input('Give me the number 1/(1 year in s): ');
 %scal1=(3*864/22)*(1e11);
 %scal2=1/3e7;

%COMPUTES THE MASS OF BH in mega solar masses
M=((linea(1))^2)*(scal2^2)*(1/6.67e-11)*((p*scal1)^3);
Ms=M/(2e30*1e6);
disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
disp(['The mass of the BH is M=',num2str(Ms),' million solar masses'])
disp(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])

 