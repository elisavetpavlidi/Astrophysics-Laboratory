clear all
clf
clc
% GENERATE AN ELLIPSE
p = input('Give me the semi-latus rectum, p: ');
e = input('Give me the eccentricity, e: ');
No= 50;

for i=1:No;
    theta=linspace(0,2*pi,No);
    r=p./(1+e.*cos(theta));
end

% DRAW YOUR OWN ELLIPSE
x=r.*cos(theta);
y=r.*sin(theta);
    plot(x,y,'k',0,0,'or')
    axis equal
    hold on
    
disp(' ')   
disp('PROCEED: press enter')
pause

% ROTATE THE ELLIPSE
phi = input('Give me the rotation angle, phi (in degrees): ');
inc = input('Give me the inclination, in (in degrees): ');
% TRANSFORM IN RADIANS
phi=pi*phi/180;
inc=pi*inc/180;

% CONSTRUCT THE ROTATING MATRICES
cp=cos(phi);
sp=sin(phi);
ci=cos(inc);
si=sin(inc);
Rphi=[cp -sp;sp cp];
Ri=[ci 0;0 1];

% ROTATE THE ELLIPSE + ADD NOISE
err=0.2; %this is the fractional error in observational measurements
Z=Ri*Rphi*[x;y].*(1+err*randn(2,No));
x1=Z(1,:);
y1=Z(2,:);

% DRAW THE ROTATED ELLIPSE
figure(1)
    plot(x,y,'k',x1,y1,'b',0,0,'or')
    axis equal
    if err~=0
    xxx={'The distorted ellipse is','due to observational errors.'};
    else xxx='';       
    end
    text(.5*(min(x1)+min(x)),.5*(min(y1)+max(y1)),[xxx],'Color','blue','FontSize',14)
    title(['The right ellipse is black. The projected one is blue.'])
    
    hold off
    
disp(' ')   
disp('PROCEED: press enter')  
pause
disp('Now, I will try to find the inclination and phi...')

% CONSTRUCT A GRID FOR i AND phi
% AND COMPUTE THE U's and V's FOR EACH i,phi

%DIMENSIONS OF THE GRID
Nph=131;
Nin=131;

for i=1:Nph
    for j=1:Nin
      % THE GRID
      cit=cos((pi/2)*(j-1)/Nin);
      pht=(i-1)*pi/Nph;
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
% THE k-th W IS ( U(k+(<)No/2)-U(k),V(k+(<)No/2)-V(k) )
Noo=floor(No/2);
for k=1:Noo
    %kup=No*(1-sign(mod(k+Noo,No)))+mod(k+Noo,No);
    kup=floor(Noo*(1-.5*rand(1)));
    
    W(1:Nph,1:Nin,k,1)=U(1:Nph,1:Nin,k+kup)-U(1:Nph,1:Nin,k);
    W(1:Nph,1:Nin,k,2)=V(1:Nph,1:Nin,k+kup)-V(1:Nph,1:Nin,k);
end

% COMPUTE THE sin(ANGLE) BETWEEN TWO SUCCESSIVE W's
for i=1:Nph
for j=1:Nin
        for k=1:Noo-1
        A(1:2)=W(i,j,k,1:2);
        B(1:2)=W(i,j,k+1,1:2);
       lam(k)=( A(1)*B(2)-B(1)*A(2) )./(norm(A)*norm(B));
        end
        lav=sum(lam)/(Noo-1);
        l2av=sum(lam.^2)/(Noo-1);
        % Q IS MEASURING THE DISPERSION OF sin(ANGLE)'s 
        % FOR EACH GRID POINT
        Q(i,j)=l2av-lav^2;
end
end

% I1(I2),I2 IS THE GRID POINT WITH THE LOWEST DISPERSION
[C,I1] = min(Q);
[C,I2]=min(min(Q));

% COMPARING THE ESTIMATED VS REAL phi and i
disp(['Instead of ',num2str(phi*180/pi),...
    ' I found phi=',num2str((I1(I2)-1)*180/Nph),' degrees'])

disp(['Instead of ',num2str(inc*180/pi),...
    ' I found iota=',num2str(90*(I2-1)/Nin),' degrees'])
    disp(' ') 
    
disp('PROCEED: press enter')
pause


disp('From the above most linear plot I will compute p and e')
% THE MOST LINEAR RELATION BETWEEN V an U 
%(the one with the lowest dispersion)
u1(1:No)=U(I1(I2),I2,1:No);
v1(1:No)=V(I1(I2),I2,1:No);

figure(2)
plot(v1,u1,'+k')
xlabel('V')
ylabel('U')
title(['The most linear relation U vs V found.'])
hold off
%FROM THIS PLOT ONE OBTAINS p and e
%1/p is the INTERCEPT  and e/p is the SLOPE

%TRY A LINEAR FIT
%THE FIRST NUMBER slin(1) is the SLOPE while 
%THE SECOND NUMBER slin(2) is the INTERCEPT
slin=polyfit(v1,u1,1);
disp(['e=',num2str(abs(slin(1)/slin(2))),' and p=',num2str(1/slin(2))])
disp(['Remember the values of e, p you gave me were ',num2str(e),' and ',num2str(p),', respectively.'])



