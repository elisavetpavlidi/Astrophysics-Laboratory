from fits_read import read_fits
from pathlib import Path
import numpy as np
from scipy.optimize import least_squares

def measure(files):
    hints=np.array([[128,111],[129,110],[130,110],[131,110],[132,111],[134,112],[135,115],[136,118],[135,120],[134,124],[130,129],[124,122]])
    companions={0:(119,117),1:(120,118),2:(120,119),6:(137,123),8:(139,114)}
    out=[]
    for k,(f,(sx,sy)) in enumerate(zip(files,hints)):
        z=read_fits(f)
        fits=[]
        for size,loss in [(8,'soft_l1'),(9,'soft_l1'),(10,'soft_l1'),(9,'huber')]:
            y,x=np.mgrid[sy-size:sy+size+1,sx-size:sx+size+1]
            val=z[y-1,x-1]
            good=~(((x==129)&(abs(y-128)<=5))|((y==128)&(abs(x-129)<=5)))
            good &= val < 250
            x,y,val=x[good],y[good],val[good]
            def model(par):
                cx,cy,amp,wx,wy,base,gx,gy=par[:8]
                main=amp*np.exp(-.5*((x-cx)/wx)**2-.5*((y-cy)/wy)**2)
                if len(par)>8:
                    dx,dy,amp2=par[8:]
                    main+=amp2*np.exp(-.5*((x-dx)/wx)**2-.5*((y-dy)/wy)**2)
                return main+base+gx*(x-sx)+gy*(y-sy)
            seed=[sx,sy,200,4,4,10,0,0]
            low=[sx-3,sy-3,20,2.1,2.1,-40,-10,-10]
            high=[sx+3,sy+3,800,7,7,90,10,10]
            if k in companions:
                dx,dy=companions[k]
                seed +=[dx,dy,160];low+=[dx-2,dy-2,10];high+=[dx+2,dy+2,800]
            fit=least_squares(lambda par:model(par)-val,seed,bounds=(low,high),loss=loss,f_scale=13)
            fits.append(fit.x[:2])
        out.append(fits)
    return np.array(out)
