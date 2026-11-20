import numpy as np
from scipy.stats import t, linregress

YY=np.r_[np.arange(1992.,2003.),2002.9]
SEC=365.25*86400
SCALE=10/22*86400*299792458.
G=6.67430e-11
SUN=1.98847e30
AU=149597870700.
C=299792458.
def grid(XY, seed=26, dims=131, course=False, synth=False):
    n=len(XY)
    ip=np.arange(69,100) if course else np.arange(dims)
    ii=np.arange(69,100) if course else np.arange(dims)
    ps=np.pi*ip/dims
    ins=np.pi/2*ii/dims
    x,y=XY.T
    xp=x/np.cos(ins[:,None])
    r=np.hypot(xp,y)
    u=np.broadcast_to(1/r,(len(ps),len(ins),n))
    v=np.cos(np.arctan2(y,xp)[None,:,:]-ps[:,None,None])
    ids=np.argsort(v,axis=-1)
    u,v=[np.take_along_axis(a,ids,axis=-1) for a in (u,v)]
    rng=np.random.default_rng(seed)
    k=np.arange(n//2)
    hop=rng.random(len(k))
    hop=np.floor((n//2)*(1-.5*hop)) if synth else np.ceil((n//2)*(1-.8*hop))
    dest=k+np.maximum(hop.astype(int),1)
    du=u[:,:,dest]-u[:,:,k]
    dv=v[:,:,dest]-v[:,:,k]
    den=np.hypot(du,dv)
    with np.errstate(invalid='ignore',divide='ignore'):
        lam=(du[:,:,:-1]*dv[:,:,1:]-du[:,:,1:]*dv[:,:,:-1])/(den[:,:,:-1]*den[:,:,1:])
    q=np.var(lam,axis=-1)
    res=[]
    for j,k in zip(*np.unravel_index(np.argsort(q.ravel())[:50],q.shape)):
        w=linregress(v[j,k],u[j,k])
        p=1/w.intercept
        e=w.slope*p
        if not course or 0<e<1:
            quality=abs(w.slope)/(t.ppf(.975,n-2)*max(w.stderr,1e-15))
            res.append(dict(phi=np.degrees(ps[j]),inc=np.degrees(ins[k]),e=e,p=p,q=q[j,k],qual=quality))
            break
    return res[0] if res else None
def ellipse(phi,inc,e,p,theta):
    f,i=np.deg2rad([phi,inc])
    r=p/(1+e*np.cos(theta))
    return np.array([np.cos(i)*r*np.cos(theta+f),r*np.sin(theta+f)]).T
def true_angles(xy,phi,inc):
    xp=xy[:,0]/np.cos(np.deg2rad(inc)); y=xy[:,1]
    angle=np.arctan2(y,xp)-np.deg2rad(phi)
    dif=np.angle(np.exp(1j*np.diff(angle)))
    # Same large-gap branch as MAT3, with a positive sense in these image coordinates.
    dif=np.where(dif < -np.pi/2,dif+2*np.pi,dif)
    return np.r_[angle[0],angle[0]+np.cumsum(dif)], np.hypot(xp,y)
def phase_J(theta,e):
    # Continuous eccentric anomaly, including the orbit count.
    E=np.arctan2(np.sqrt(1-e*e)*np.sin(theta),e+np.cos(theta))
    E+=2*np.pi*np.round((theta-E)/(2*np.pi))
    return (E-e*np.sin(E))/(1-e*e)**1.5
def dynamics(xy,d,scale=SCALE,times=YY):
    theta,r=true_angles(xy,d['phi'],d['inc'])
    e,p=d['e'],d['p']
    J=phase_J(theta,e)
    J-=J[0]
    fit=linregress(times,J)
    mass=(p*scale)**3*(fit.slope/SEC)**2/G
    kGR=np.sqrt(1-6*G*mass/(p*scale*C*C))
    cs=(p/r-1)/e
    xx=np.rad2deg(theta % (2*np.pi))
    cosang=np.arccos(np.clip(cs,-1,1))
    yy=np.rad2deg(np.where(np.sin(theta)>0,cosang,2*np.pi-cosang))
    gr=linregress(xx,yy)
    ok=np.abs(cs)<=1
    valid=linregress(xx[ok],yy[ok]) if ok.sum()>2 else None
    return dict(theta=theta,r=r,J=J,M=mass/SUN,s=fit.slope,s_err=fit.stderr,
                stat=2*mass/SUN*fit.stderr/abs(fit.slope),tperi=-fit.intercept/fit.slope + phase_J(theta[0],e)/fit.slope*(-1),
                R2=fit.rvalue**2, k=gr.slope,dk=t.ppf(.975,len(xx)-2)*gr.stderr,
                bad=list(np.where(~ok)[0]),k_filtered=valid.slope if valid else np.nan,
                dk_filtered=t.ppf(.975,ok.sum()-2)*valid.stderr if valid else np.nan,
                kGR=kGR,GR_arcmin=np.degrees(2*np.pi*(1/kGR-1))*60,
                rp=p*scale/(1+e)/AU,rs=2*G*mass/(C*C*AU),xx=xx,yy=yy)
