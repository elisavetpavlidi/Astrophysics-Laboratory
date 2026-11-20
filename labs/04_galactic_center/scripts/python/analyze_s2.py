"""Reproduce the S2 lab from the supplied blackholeimages ZIP."""
import argparse
import csv
import json
from pathlib import Path
from tempfile import TemporaryDirectory
from time import perf_counter
from zipfile import ZipFile
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import quad
from scipy.interpolate import PchipInterpolator
from scipy.io import savemat
from scipy.stats import linregress
from astro import measure
from fits_read import read_fits
from solve import AU, SCALE, SEC, YY, dynamics, ellipse, grid, phase_J, true_angles

COLOUR="#1e6091"
ACCENT="#b95227"
DARK="#18334e"
plt.rcParams.update({"font.family":"DejaVu Sans","font.size":10,"axes.spines.top":False,"axes.spines.right":False})
CURVE=np.linspace(0,2*np.pi,600)

def write_csv(path, columns, rows):
    with path.open("w",newline="",encoding="utf-8") as handle:
        writer=csv.writer(handle)
        writer.writerow(columns)
        writer.writerows(rows)

def grid_trials(obs):
    cross=np.array([129.,128.])
    shifts=np.array([(dx,dy) for dx in np.arange(-3,3.01,.5) for dy in np.arange(-3,3.01,.5) if dx**2+dy**2<=9])
    trials=[]
    for seed in (13,24,38,45):
        options=[]
        for xy0 in cross+shifts:
            relative=obs-xy0
            result=grid(relative,seed,course=True)
            if result is None:
                continue
            theta,_=true_angles(relative,result["phi"],result["inc"])
            model=ellipse(result["phi"],result["inc"],result["e"],result["p"],theta)
            rms=np.sqrt(np.mean(np.sum((model-relative)**2,axis=1)))
            result.update(seed=seed, center=xy0.tolist(),rms=rms)
            options.append(result)
        acceptable=[item for item in options if item["rms"]<=3]
        trials.append(max(acceptable,key=lambda item:item["qual"]))
    return trials

def uv_fit(xy,phi,inc):
    theta,r=true_angles(xy,phi,inc)
    v,u=np.cos(theta),1/r
    fit=linregress(v,u)
    return v,u,dict(phi=phi,inc=inc,p=1/fit.intercept,e=fit.slope/fit.intercept)

def sensitivity(obs,best):
    center=np.array(best["center"])
    masses=[]
    for dx,dy in [(-.5,0),(.5,0),(0,-.5),(0,.5)]:
        rel=obs-(center+[dx,dy])
        _,_,fit=uv_fit(rel,best["phi"],best["inc"])
        masses.append(dynamics(rel,fit)["M"])
    rel=obs-center
    use=np.arange(len(rel))!=7
    _,_,fit=uv_fit(rel[use],best["phi"],best["inc"])
    m_drop=dynamics(rel[use],fit,times=YY[use])["M"]
    possible=[uv_fit(rel,phi,0) for phi in np.linspace(0,180,361)]
    v,u,face=max(possible,key=lambda trio:abs(linregress(trio[0],trio[1]).rvalue))
    if face["e"]<0:
        face["e"]*=-1
        face["phi"]+=180
    return dict(center_masses=masses,drop1999=m_drop,projected=dynamics(rel,face)["M"],face=face)

def synthetic_run(p,e,phi,inc,n,arc,sigma,seed):
    before=perf_counter()
    theta=np.linspace(0,np.deg2rad(arc),n)
    actual=ellipse(phi,inc,e,p,theta)
    measured=actual+sigma*p*np.random.default_rng(seed).normal(size=actual.shape)
    answer=grid(measured,seed,synth=True)
    return dict(input=[p,e,phi,inc],n=n,arc=arc,sigma=sigma,seed=seed,
                output=answer,seconds=perf_counter()-before), measured

def synthetic(figdir):
    tests=[(1,.2,20,20,100,360,0),(1.5,.45,40,60,100,360,0),
           (2,.65,75,35,100,360,0),(1.2,.8,110,55,100,360,0),
           (2.2,.88,150,72,100,360,0),(1.2,.8,110,55,100,360,.01)]
    fig,panels=plt.subplots(2,3,figsize=(10,6),layout='constrained')
    summaries=[]
    for num,(case,ax) in enumerate(zip(tests,panels.flat),1):
        dat,points=synthetic_run(*case,26)
        summaries.append(dat)
        p,e,phi,inc=dat["input"]
        ax.plot(*ellipse(0,0,e,p,CURVE).T,color="#859bad",ls="--",lw=1.2)
        ax.plot(*ellipse(phi,inc,e,p,CURVE).T,color=COLOUR,lw=1.6)
        ax.scatter(*points[::3].T,s=8,fc="none",ec=ACCENT,lw=.7)
        ax.scatter(0,0,s=20,c=DARK,marker="+")
        ax.set(aspect="equal",title=f"Δοκιμή {num}   e={e:g}, ι={inc:g}°")
        if num==1:
            ax.text(.02,.02,"Πραγματική (– –) / προβολή (―)",transform=ax.transAxes,fontsize=8)
    fig.savefig(figdir/"01_synthetic.png",dpi=160)
    plt.close(fig)
    extra=[]
    for n,arc,noise in [(30,360,0),(60,360,0),(100,360,0),(200,360,0),(100,270,0),(100,180,0),(100,90,0),
                       (100,360,.003),(100,360,.01),(100,360,.03)]:
        one,_=synthetic_run(1.2,.8,110,55,n,arc,noise,26)
        extra.append(one)
    return summaries,extra

def calibration(files):
    values=[]
    for file in files:
        img=read_fits(file)
        ticks=np.flatnonzero(img[4,167:201]>170)+168
        assert len(ticks)==2
        values.append(int(np.diff(ticks)[0]))
    assert set(values)=={22}
    return values

def plot_frames(files,measurements,center,figdir):
    fig,axs=plt.subplots(3,4,figsize=(9.5,7.4),layout="constrained")
    for ax,path,epoch,positions in zip(axs.flat,files,YY,measurements):
        img=read_fits(path)
        ax.imshow(img,cmap="gray",origin="upper",extent=(.5,256.5,256.5,.5),vmin=6,vmax=245)
        ax.scatter(*positions.mean(0),s=103,facecolors="none",edgecolors="#febe5d",linewidths=1.1)
        ax.scatter(*center,c="#44dfed",marker="+",s=39,lw=1.1)
        ax.set(xlim=(106,151),ylim=(140,96),xticks=[],yticks=[],title=f"{epoch:g}")
    fig.savefig(figdir/"02_s2_frames.png",dpi=165)
    plt.close(fig)
    fig,ax=plt.subplots(figsize=(6.35,2.3),layout="constrained")
    img=read_fits(files[1])
    ax.imshow(img,cmap="gray",origin="upper",extent=(.5,256.5,256.5,.5),vmin=6,vmax=245)
    ax.set(xlim=(145,235),ylim=(24,1),xticks=[],yticks=[])
    for pos,label in [(175,"175"),(197,"197")]:
        ax.annotate(label,(pos,5),xytext=(pos,17),ha="center",color="#ffca70",
                    arrowprops={"arrowstyle":"->","color":"#ffca70"})
    fig.savefig(figdir/"03_plate_scale.png",dpi=150)
    plt.close(fig)

def plot_fit(obs,measurements,best,d,figdir):
    xy=obs-np.array(best["center"])
    fig,axs=plt.subplots(1,2,figsize=(10,3.4),layout="constrained")
    tt=np.linspace(YY[0],YY[-1],300)
    for k,ax in enumerate(axs):
        samples=measurements[:,:,k]-best["center"][k]
        ax.plot(tt,PchipInterpolator(YY,xy[:,k])(tt),color=COLOUR,lw=1.25)
        ax.scatter(np.repeat(YY,4),samples.ravel(),marker="+",c=ACCENT,s=18)
        ax.scatter(YY,xy[:,k],fc="white",ec=COLOUR,s=22,zorder=5)
        ax.set(xlabel="Έτος",ylabel=("Δx" if k==0 else "Δy")+" (pixel)")
        ax.grid(alpha=.18)
    fig.savefig(figdir/"04_mat0_checks.png",dpi=160)
    plt.close(fig)
    fig,axs=plt.subplots(1,3,figsize=(11,4.2),layout="constrained")
    theta=d["theta"]
    for j,ax in enumerate(axs[:2]):
        args=(best["phi"],best["inc"]) if j==0 else (0,0)
        model=ellipse(*args,best["e"],best["p"],CURVE)
        data=xy if j==0 else np.column_stack([d["r"]*np.cos(theta),d["r"]*np.sin(theta)])
        ax.plot(*model.T,color=COLOUR,linewidth=1.5)
        ax.scatter(*data.T,marker="+",c=ACCENT,s=36)
        ax.scatter(0,0,c=DARK,s=25)
        ax.scatter(*data[7],s=70,facecolors="none",edgecolors=ACCENT)
        for k in (0,5,7,10,11):
            ax.annotate(f"{YY[k]:g}",data[k],xytext=(4,4),textcoords="offset points",fontsize=8)
        ax.set(aspect="equal",xlabel="x (pixel)",ylabel="y (pixel)",
               title=["Προβαλλόμενη τροχιά","Τροχιακό επίπεδο"][j])
        ax.margins(.21)
        if j==0:
            ax.invert_yaxis()
    v,u,_=uv_fit(xy,best["phi"],best["inc"])
    ax=axs[2]
    ax.scatter(v,u,color=ACCENT,s=20)
    xv=np.linspace(-1,1,100)
    ax.plot(xv,(1+best["e"]*xv)/best["p"],color=COLOUR)
    ax.set(xlabel="V",ylabel="U (1/pixel)",title="Έλεγχος γραμμικότητας")
    fig.savefig(figdir/"05_orbit_and_uv.png",dpi=170)
    plt.close(fig)
    fig,(ax1,ax2)=plt.subplots(1,2,figsize=(9.8,3.8),layout="constrained")
    x=YY-YY[0]
    fit=linregress(x,d["J"])
    ax1.plot(x,fit.intercept+fit.slope*x,c=COLOUR)
    ax1.scatter(x,d["J"],c=ACCENT,s=24)
    ax1.set(xlabel="Χρόνος από το 1992 (έτη)",ylabel="J − J(1992)",title="Μάζα από τον ρυθμό σάρωσης")
    ax2.plot([0,360],[0,360],c="#7891a7",ls=":",label="Νευτώνεια πρόβλεψη")
    f=linregress(d["xx"],d["yy"])
    xx=np.array([min(d["xx"]),max(d["xx"])])
    ax2.plot(xx,f.intercept+f.slope*xx,c=COLOUR,label="Προσαρμογή")
    ax2.scatter(d["xx"],d["yy"],color=ACCENT,s=24)
    ax2.set(xlabel="θ₁ (°)",ylabel="θ₂ (°)",title="Έλεγχος μετάπτωσης")
    ax2.legend(fontsize=8)
    fig.savefig(figdir/"06_mass_and_precession.png",dpi=170)
    plt.close(fig)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("images_zip",type=Path)
    parser.add_argument("--output",type=Path,default=Path("results"))
    args=parser.parse_args()
    out=args.output
    figdir=out/"figures"
    figdir.mkdir(parents=True,exist_ok=True)
    with TemporaryDirectory() as scratch:
        with ZipFile(args.images_zip) as archive:
            files=[]
            for epoch in range(1,13):
                name=f"image{epoch:02}.fts"
                data=archive.read("blackholeimages_fts/"+name)
                file=Path(scratch)/name
                file.write_bytes(data)
                files.append(file)
        widths=calibration(files)
        measurements=measure(files)
        obs=measurements.mean(1)
        trials=grid_trials(obs)
        best=max(trials,key=lambda result:result["qual"])
        rel=obs-np.array(best["center"])
        result=dynamics(rel,best)
        theta=result["theta"]
        for val,expected in zip(theta,result["J"]):
            numerical=quad(lambda q:(1+best["e"]*np.cos(q))**-2,theta[0],val)[0]
            assert np.isclose(numerical,expected,atol=1e-9)
        synth,extra=synthetic(figdir)
        results=dict(best=best,trials=trials,dynamics=result,scale=SCALE,scale_pixels=widths,sen=sensitivity(obs,best),
                     synthetic=synth, extra=extra)
        with (out/"results.json").open("w",encoding="utf-8") as handle:
            json.dump(results,handle,default=lambda x:x.tolist(),indent=2)
        keys=["year"]+[f"{axis}{k}" for k in range(1,5) for axis in ("X","Y")]+["X_mean","Y_mean","DX","DY","scale_bar_px"]
        write_csv(out/"astrometry.csv",keys,np.column_stack((YY,measurements.reshape(12,8),obs,rel,widths)))
        write_csv(out/"orbit_dynamics.csv",["year","theta_unwrapped_rad","r_px","J_relative","theta1_deg","theta2_deg"],
                  np.column_stack((YY,theta,result["r"],result["J"],result["xx"],result["yy"])))
        savemat(out/"DATAfile.mat",{"DAT":np.vstack((rel.T,YY))})
        savemat(out/"MAT_DATA_phys.mat",{"res":[best["phi"],best["inc"],best["e"],best["p"]]})
        plot_frames(files,measurements,best["center"],figdir)
        plot_fit(obs,measurements,best,result,figdir)
        print(f'M = {result["M"]/1e6:.3f} million solar masses, e = {best["e"]:.3f}')

if __name__=="__main__":
    main()
