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
x=x1;
y=y1;

%OPEN THE FILE WITH GEOMETRICAL DATA. 
DATphys=load('MAT_DATA_phys');
res=DATphys.res;
phi=(res(1))*pi/180;
inc=(res(2))*pi/180;
e=res(3);
p=res(4);

%CONSTRUCTING THE INVERSE ROTATIONS
cp=cos(phi);
sp=sin(phi);
ci=cos(inc);
si=sin(inc);
Rphi=[cp sp;-sp cp];
Ri=[1/ci 0;0 1];
%%%%%%%
r1=sqrt((x1./ci).^2+y1.^2);
th1=0.5.*((1-sign(x1./ci)).*(pi-asin(y1./r1))+(sign(x1./ci)+1).*asin(y1./r1))-phi;
x1r=r1.*cos(th1);
y1r=r1.*sin(th1);
r=[x1r;y1r];

th(1)=th1(1);
for i=2:No
    Dth(i-1)=acos(r(:,i)'*r(:,i-1)/(norm(r(:,i))*norm(r(:,i-1))));
    S(i-1)=sign(r(1,i-1)*r(2,i)-r(2,i-1)*r(1,i));
    if Dth(i-1)>pi/2 & S(i-1)<0
        extr=1;
    else extr=0;
    end
    th(i)=th(i-1)+S(i-1)*(Dth(i-1)*(1-extr)+extr*(2*pi-Dth(i-1)));
end

% Now I will try to linear fit the data for V and U
% assuming all cosU's are <1. 
bad=find(abs((p./r1-1)/e)>1);
if length(bad)~=0;
   disp(['BE CAREFUL!'])
   disp(['The data for the year(s) ',num2str(tim(bad)),' leads to unphysical value(s) for è1'])
end

% Zr=Rphi*Ri*[x;y];
% Rp=sqrt(Zr(1,:).^2+Zr(2,:).^2);
Rp=sqrt(x1r.^2+y1r.^2);
Tp=th;
coss=(1/e).*(p./Rp-1);

XX=(180/pi)*mod(Tp,2*pi);
over=[y1r>0];
YYtr=acos(coss).*over+(2*pi-acos(coss)).*(1-over);
YYtr=real(YYtr);
YY=(180/pi)*YYtr;

figure(1)
plot(XX,YY,'+')
xlabel(' $$\theta_1 (^\circ)$$ ','Interpreter','latex','FontSize',14)
ylabel(' $$\theta_2 (^\circ)$$','Interpreter','latex','FontSize',14)
hold on
for i=1:No
text(XX(i),YY(i),['\leftarrow',num2str(tim(i))],'Color','black','FontSize',14,'Rotation',-50)
end

%linea=polyfit(XX,YY,1)

cf = fit(XX',YY','poly1'); 
cf_coeff = coeffvalues(cf);
cf_confint = confint(cf);
a = cf_coeff(1);
b = cf_coeff(2);
a_uncert = (cf_confint(2,1) - cf_confint(1,1))/2;
b_uncert = (cf_confint(2,2) - cf_confint(1,2))/2;
thetas=linspace(min(XX),max(XX),10);

plot(thetas,a*thetas+b,'--k')
disp(['The slope came out ',num2str(a),' +/- ',num2str(a_uncert)])