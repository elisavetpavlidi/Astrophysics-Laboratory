clear all
clf
clc

%READ THE DATA FROM DATAfile.mat
DATR=load('DATAfile.mat');
x1=DATR.DAT(1,:);
y1=DATR.DAT(2,:);
tim=DATR.DAT(3,:);

No=length(tim);
%set(gca,'Ydir','Reverse');
% x1=flip(x1);
% y1=flip(y1);



% DRAW THE PROJECTTED ELLIPSE
figure(1)
    plot(x1,y1,'+k',0,0,'ob')
    text(x1(1),y1(1),['\leftarrow',num2str(tim(1))],'Color','black','FontSize',14)
    text(x1(7),y1(7),['\leftarrow',num2str(tim(7))],'Color','black','FontSize',14)
    text(x1(No),y1(No),['\leftarrow',num2str(tim(No))],'Color','black','FontSize',14)
    axis equal
    title('o: the BH position, +: the projected positions')
    set(gca,'Ydir','Reverse');
    drawnow
    disp('press any key to proceed')
    hold off
    pause

%ITERATIONS TO OBTAIN THE BEST LINEARIZATION 
quali=0;
MINquali=15; %COULD BE MADE HIGHER OR LOWER
trial=1;
disp('I will try to find a pair of inclination and phi that makes U-V linear')
%pause(3)

while quali<MINquali;
    %clf
    clc
    
disp(['Iteration:',num2str(trial)])
trial=trial+1;
    
% disp('PROCEED: press enter')
% pause

% CONSTRUCT A GRID FOR i AND phi
% AND COMPUTE THE U's and V's FOR EACH i,phi

%DIMENSIONS OF THE GRID
Nph=131;
Nin=131;
Nphs=70;
Nphf=100;
Nins=70;
Ninf=100;
Q=ones(Nphf,Ninf);

for i=Nphs:Nphf %i=1:Nph
for j=Nins:Ninf %j=1:Nin
      % THE GRID
      %cit=cos((pi/2)*(j-1)/Nin);
      %pht=(i-1)*pi/Nph;
      cit=cos((90*(j-1)/Nin)*pi/180);
      pht=(180*(i-1)/Nph)*pi/180;

      % THE U and V FOR EACH GRID POINT
      Ut(1:No)=cit./sqrt( x1.^2+(cit*y1).^2 );
      Vt(1:No)=cos( -pht+atan( cit*y1./x1 ) +(pi/2).*( 1-sign(x1) ) );
      %FOLLOWS A PROCEDURE TO SORT THE U's and V's 
      %IN AN ASCENDING FORM OF V's
      UV(1:No,1:2)=[Vt(1:No);Ut(1:No)]';
      UVs=sortrows(UV);
      V(i,j,1:No)=UVs(1:No,1);
      U(i,j,1:No)=UVs(1:No,2);
end
end

% NOW CONSTRUCT THE W VECTORS (No=# of W's)
% THE k-th W IS ( U(k+No/2)-U(k),V(k+No/2)-V(k) )
Noo=floor(No/2);
for k=1:Noo
    kup=ceil(Noo*(1-0.8*rand(1)));
    %kup=Noo-1;

    W(Nphs:Nphf,Nins:Ninf,k,1)=U(Nphs:Nphf,Nins:Ninf,k+kup)-U(Nphs:Nphf,Nins:Ninf,k);
    W(Nphs:Nphf,Nins:Ninf,k,2)=V(Nphs:Nphf,Nins:Ninf,k+kup)-V(Nphs:Nphf,Nins:Ninf,k);
end
% W(1:Nph,1:Nin,1,1)=U(1:Nph,1:Nin,No)-U(1:Nph,1:Nin,2);
% W(1:Nph,1:Nin,1,2)=V(1:Nph,1:Nin,No)-V(1:Nph,1:Nin,2);
% W(1:Nph,1:Nin,2,1)=U(1:Nph,1:Nin,No-1)-U(1:Nph,1:Nin,1);
% W(1:Nph,1:Nin,2,2)=V(1:Nph,1:Nin,No-1)-V(1:Nph,1:Nin,1);

% COMPUTE THE sin(ANGLE) BETWEEN TWO SUCCESSIVE W's
for i=Nphs:Nphf %i=1:Nph
for j=Nins:Ninf %j=1:Nin

% i=floor(133.28*Nph/(pi*180));
% j=floor(56.336*Nin/(pi*90));
    %figure(3)
        for k=1:Noo-1
        A(1:2)=W(i,j,k,1:2);
        B(1:2)=W(i,j,k+1,1:2);
        lam(k)=( A(1)*B(2)-B(1)*A(2) )./(norm(A)*norm(B));
       % plot(A,B)
       % hold on
        end
        % hold off
        %pause
       % A(1:2)=W(i,j,1,1:2);
       % B(1:2)=W(i,j,2,1:2);
       % lam=det([A(1:2)/norm(A(1:2));B(1:2)/norm(B(1:2))]);

        lav=sum(lam)/(Noo-1);
        l2av=sum(lam.^2)/(Noo-1);
        % Q IS MEASURING THE DISPERSION OF sin(ANGLE)'s 
        % FOR EACH GRID POINT
        
        Q(i,j)=l2av-lav^2;
        %Q(i,j)=lav^2;
        %"i=",i,"j=",j,"Q=",l2av-lav^2,min(min(Q))
        %Q(i,j)=lam^2;
       
end
end



% I1(I2),I2 IS THE GRID POINT WITH THE LOWEST DISPERSION
[C,I1] = min(Q);
[C,I2]=min(min(Q));

%pause

% COMPARING THE ESTIMATED VS REAL phi and i
%disp([' I found phi=',num2str((I1(I2)-1)*180/Nph),' degrees'])
phi=(I1(I2)-1)*180/(Nph);
%disp([' I found iota=',num2str(90*(I2-1)/Nin),' degrees'])
iota=90*(I2-1)/(Nin);

%disp('From the above most linear plot I will compute p and e')
% THE MOST LINEAR RELATION BETWEEN V an U 
%(the one with the lowest dispersion)
u1(1:No)=U(I1(I2),I2,1:No);
v1(1:No)=V(I1(I2),I2,1:No);
cf=fit(v1',u1','poly1');
       cf_coeff = coeffvalues(cf);
       cf_confint = confint(cf);
       a = cf_coeff(1);
       b = cf_coeff(2);
       a_uncert = (cf_confint(2,1) - cf_confint(1,1))/2;
       b_uncert = (cf_confint(2,2) - cf_confint(1,2))/2;
       quali=abs(a/a_uncert);
       
figure(4)
plot(v1,u1,'+k')
xlabel('V')
ylabel('U')
title('the best found linearized relation between U-V')
%FROM THIS PLOT ONE OBTAINS p and e
%1/p is the INTERCEPT  and e/p is the SLOPE

%TRY A LINEAR FIT
%THE FIRST NUMBER slin(1) is the SLOPE while 
%THE SECOND NUMBER slin(2) is the INTERCEPT
% slin=polyfit(v1,u1,1);
% e=slin(1)/slin(2);
% p=1/slin(2);
slo=(No*sum(u1.*v1)-sum(u1)*sum(v1))/(No*sum(v1.^2)-sum(v1)^2);
p=No/(sum(u1)-slo*sum(v1));
e=slo*p;

if quali>MINquali & e>0
    disp('')
    disp(['I have finally managed to obtain a linearity of ',num2str(quali),' with a normal e-value'])
break 
end

if quali<MINquali
disp(['The quality of linearity is unfortunately too low '])
end
if e<0 & quali<MINquali
    disp('and')
end
if e<0
    disp(['e=',num2str(e),' is irregular.'])
end
disp(['Not nice. I will try again...'])
%pause(3)

%closing while
end

disp(['I found phi=',num2str((I1(I2)-1)*180/Nph),' degrees'])
disp(['...and iota=',num2str(iota),' degrees.'])
disp('The best estimation for orbital characteristics is: ')
disp([    'e=',num2str(e),' and p=',num2str(p)])
disp('')
res=[phi iota e p];
save('MAT_DATA_phys','res')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RECONSTRUCT THE REAL AND PROJECTED ELLIPSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTRUCT THE RIGHT ELLIPSE
NR=200;
tth=linspace(0,2*pi,NR);
rr=p./(1+e.*cos(tth));
xr=rr.*cos(tth);
yr=rr.*sin(tth);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANSFORM IN RADIANS
phi=pi*phi/180;
inc=pi*iota/180;
r1=sqrt((x1./cos(inc)).^2+y1.^2);
th1=0.5.*((1-sign(x1)).*(pi-asin(y1./r1))+(sign(x1)+1).*asin(y1./r1))-phi;
x1r=r1.*cos(th1);
y1r=r1.*sin(th1);
% CONSTRUCT THE ROTATING MATRICES
cp=cos(phi);
sp=sin(phi);
ci=cos(inc);
si=sin(inc);
Rphi=[cp -sp;sp cp];
Ri=[ci 0;0 1];
% ROTATE THE ELLIPSE TO RECONSTRUCT THE PROJECTED ONE
Z=Ri*Rphi*[xr;yr];
xp=Z(1,:);
yp=Z(2,:);
%PLOT EVERYTHING
figure(2)
plot(x1,y1,'+k',xr,yr,'--r',xp,yp,'k',x1r,y1r,'xr',0,0,'ob')
text(x1(1),y1(1),['\leftarrow',num2str(tim(1))],'Color','black','FontSize',14)
text(x1(7),y1(7),['\leftarrow',num2str(tim(7))],'Color','black','FontSize',14)
text(x1(No),y1(No),['\leftarrow',num2str(tim(No))],'Color','black','FontSize',14)
text(x1r(1),y1r(1),['\leftarrow',num2str(tim(1))],'Color','red','FontSize',14)
text(x1r(7),y1r(7),['\leftarrow',num2str(tim(7))],'Color','red','FontSize',14)
text(x1r(No),y1r(No),['\leftarrow',num2str(tim(No))],'Color','red','FontSize',14)
set(gca,'Ydir','Reverse');
disp('Figure 2 depicts the projected (black-solid) and')
disp('the rectified-after-rotation (red-dashed) ellipse.')



