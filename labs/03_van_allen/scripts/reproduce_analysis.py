"""Numerical reproduction of the course MATLAB Fourier helpers in Python.

Inputs: GEOMAG.mat, RBSP.mat, RBSPenergy.mat in --data-dir.
The original MATLAB helpers assume 1 s sampling, a rectangular window,
mean removal in fourierPower and amplitude-squared normalization 4|FFT/N|^2.
CSV/JSON outputs retain the exact convention and also give the physically
normalized one-sided PSD and integrated band power. Numerical formulas and
time intervals follow the supplied reproduction script; paths and command-line
options are adapted to the repository layout.
"""
from pathlib import Path
import argparse, json
from datetime import datetime, timedelta
import numpy as np
from scipy.io import loadmat
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

LAB_ROOT = Path(__file__).resolve().parents[1]
plt.rcParams.update({'font.family':'DejaVu Serif','font.size':10,
    'mathtext.fontset':'cm','axes.spines.top':False,'axes.spines.right':False,
    'axes.grid':True,'grid.alpha':.2,'savefig.dpi':240})
COLORS=['#183c8e','#c85120']
BANDS=[(.002,.007),(.002,.1)]
NAMES=['2–7 mHz (Pc5)','2–100 mHz (Pc5, Pc4, Pc3)']

def dn(y,m,d,h=0): return datetime(y,m,d).toordinal()+366+h/24
def dates(t): return np.asarray(t)-dn(1970,1,1)
def stamp(t):
    return (datetime(1970,1,1)+timedelta(seconds=round((float(t)-dn(1970,1,1))*86400))).isoformat(timespec='seconds')
def spectrum(x):
    n=len(x)
    a2=4*np.abs(np.fft.rfft(x-np.mean(x))/n)**2
    f=np.arange(n//2+1)/n
    psd=a2*n/2
    psd[0]/=2
    if n%2==0: psd[-1]/=2
    return f,a2,psd
def verify():
    n=1000;t=np.arange(n);x=10+5*np.cos(2*np.pi*.004*t)
    f,a,s=spectrum(x);j=np.argmin(abs(f-.004))
    assert np.isclose(a[j],25,rtol=1e-12)
    assert np.isclose(np.sum(s)/n,12.5,rtol=1e-12)
    rng=np.random.default_rng(31)
    for n in [1000,3600,3599]:
        x=rng.normal(size=n);f,a,s=spectrum(x)
        assert np.isclose(np.sum(s)/n,np.var(x),rtol=1e-12)
        for lo,hi in BANDS:
            k=(f>=lo)&(f<=hi)
            assert np.isclose(np.mean(s[k]),n/2*np.mean(a[k]))
    return 'Analytical sinusoid and Parseval checks passed for even/odd lengths.'
def save(fig,path):
    fig.savefig(path.with_suffix('.png'),bbox_inches='tight')
    fig.savefig(path.with_suffix('.pdf'),bbox_inches='tight')
    plt.close(fig)
def phases(ax):
    ax.axvspan(dates(dn(2013,3,17,6)),dates(dn(2013,3,17,20)),color='#f2be70',alpha=.18)
    ax.axvspan(dates(dn(2013,3,17,20)),dates(dn(2013,3,21)),color='#80b7a7',alpha=.10)
    ax.set_xlim(dates([dn(2013,3,16),dn(2013,3,21)]))
    ax.xaxis.set_major_locator(mdates.DayLocator())
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%d Mar'))

def main(data_dir, output_dir):
    data_dir=data_dir.expanduser().resolve()
    output_dir=output_dir.expanduser().resolve()
    output_dir.mkdir(parents=True,exist_ok=True)
    out=output_dir/'computed';out.mkdir(exist_ok=True)
    figdir=output_dir/'figures';figdir.mkdir(exist_ok=True)
    D=loadmat(data_dir/'GEOMAG.mat',squeeze_me=True)
    x=D['Bgr'];t=D['Bgr_time']
    assert len(x)==len(t) and np.isfinite(x).all()
    assert np.max(np.abs(np.diff(t)*86400-1))<2e-5
    results={};summary={'validation':verify(),'sampling_seconds':1,'profiles':{},'fits':{}}
    for n in [1000,3600]:
        count=len(x)//n
        a=x[:count*n].reshape(count,n)
        tm=np.median(t[:count*n].reshape(count,n),axis=1)
        y=np.fft.rfft(a-a.mean(axis=1)[:,None],axis=1)/n
        power=4*abs(y)**2
        f=np.arange(n//2+1)/n
        result={'t':tm}
        for b,(lo,hi) in enumerate(BANDS):
            k=(f>=lo)&(f<=hi)
            raw=power[:,k].mean(axis=1)
            psd=raw*n/2
            integrated=power[:,k].sum(axis=1)/2
            result[b]={'raw':raw,'psd':psd,'integrated':integrated}
            mask=(tm>=dn(2013,3,16))&(tm<dn(2013,3,21))
            j=np.flatnonzero(mask)[np.argmax(raw[mask])]
            summary['profiles'][f'{n}s_{lo:g}_{hi:g}']={
                'bins':int(k.sum()),'actual_band_mHz':[float(f[k][0]*1000),float(f[k][-1]*1000)],
                'peak_time_UT':stamp(tm[j]),'peak_raw_nT2':float(raw[j]),
                'peak_psd_nT2_per_Hz':float(psd[j]),'peak_integrated_nT2':float(integrated[j])}
            np.savetxt(out/f'power_{n}s_band{b+1}.csv',np.c_[tm,raw,psd,integrated],delimiter=',',
                       header='matlab_datenum,mean_amplitude_squared_nT2,mean_PSD_nT2_per_Hz,integrated_power_nT2',comments='')
        assert np.all(result[1]['integrated']>=result[0]['integrated']-1e-12)
        results[n]=result

    # Exact laboratory normalization, both ranges and both time resolutions.
    fig,axs=plt.subplots(3,1,figsize=(10.8,8.0),sharex=True,gridspec_kw={'height_ratios':[1,1,.7]})
    for ax,n in zip(axs[:2],[1000,3600]):
        r=results[n]
        for b in range(2): ax.plot(dates(r['t']),r[b]['raw'],color=COLORS[b],lw=1,label=NAMES[b])
        ax.set_yscale('log');ax.set_ylim(1e-5,40);ax.set_ylabel(r'$\overline{a_k^2}$ (nT$^2$)')
        ax.set_title(f'Original lab normalization | window {n} s',loc='left',fontsize=11)
        ax.legend(loc='upper right',fontsize=9);phases(ax)
    axs[2].plot(dates(D['Dst_time']),D['Dst'],color='k',lw=1)
    axs[2].set_ylabel('Dst (nT)');phases(axs[2]);axs[2].set_xlabel('Time (UT), March 2013')
    fig.tight_layout();save(fig,figdir/'Bands_OriginalNormalization')

    # Comparable physical normalization: fixed hourly window.
    fig,axs=plt.subplots(3,1,figsize=(10.8,8),sharex=True,gridspec_kw={'height_ratios':[1,1,.7]})
    r=results[3600]
    for b in range(2):
        axs[0].plot(dates(r['t']),r[b]['psd'],color=COLORS[b],label=NAMES[b])
        axs[1].plot(dates(r['t']),r[b]['integrated'],color=COLORS[b],label=NAMES[b])
    axs[0].set_ylabel(r'Mean PSD (nT$^2$/Hz)');axs[0].set_yscale('log');axs[0].set_ylim(.03,3e4)
    axs[1].set_ylabel(r'Band power (nT$^2$)');axs[1].set_yscale('log');axs[1].set_ylim(.001,120)
    axs[0].set_title('Same 3600 s window | band mean and integrated power',loc='left')
    for ax in axs[:2]:ax.legend(loc='upper right',fontsize=9);phases(ax)
    axs[2].plot(dates(D['Dst_time']),D['Dst'],'k',lw=1);axs[2].set_ylabel('Dst (nT)');phases(axs[2])
    axs[2].set_xlabel('Time (UT), March 2013');fig.tight_layout();save(fig,figdir/'Bands_HourlyPhysical')

    # Same band, different window lengths: PSD eliminates trivial 1/N scaling.
    fig,axs=plt.subplots(3,1,figsize=(10.8,8),sharex=True,gridspec_kw={'height_ratios':[1,1,.7]})
    for b,ax in enumerate(axs[:2]):
        for n,c in zip([1000,3600],['#b2b6bc',COLORS[b]]):
            r=results[n];ax.plot(dates(r['t']),r[b]['psd'],color=c,lw=1,label=f'{n} s')
        ax.set_yscale('log');ax.set_ylim(.03,3e4);ax.set_ylabel(r'Mean PSD (nT$^2$/Hz)')
        ax.set_title(NAMES[b],loc='left');ax.legend(loc='upper right');phases(ax)
    axs[2].plot(dates(D['Dst_time']),D['Dst'],'k',lw=1);axs[2].set_ylabel('Dst (nT)');phases(axs[2])
    axs[2].set_xlabel('Time (UT), March 2013');fig.tight_layout();save(fig,figdir/'Bands_WindowSensitivity')

    cases=[('Pre-storm',dn(2013,3,16,14),dn(2013,3,16,15)),
           ('Main phase',dn(2013,3,17,14),dn(2013,3,17,15)),
           ('Recovery',dn(2013,3,18,18),dn(2013,3,18,19))]
    fig,axs=plt.subplots(3,2,figsize=(10.8,8.4),sharey=True)
    for row,(name,start,end) in enumerate(cases):
        # Same strict temporal inequalities as fourierSpectrum.m.
        sel=(t>start)&(t<end);f,a,p=spectrum(x[sel]);n=int(sel.sum())
        for b,(lo,hi) in enumerate(BANDS):
            k=(f>=lo)&(f<=hi);ax=axs[row,b]
            ax.loglog(f[k]*1000,p[k],color=COLORS[b],lw=1)
            ax.set_xlim(lo*1000,hi*1000);ax.set_ylim(1e-6,2e4)
            from matplotlib.ticker import FixedLocator, ScalarFormatter, NullFormatter
            ax.xaxis.set_major_locator(FixedLocator([2,3,4,5,7] if b==0 else [2,7,10,30,100]))
            ax.xaxis.set_major_formatter(ScalarFormatter())
            ax.xaxis.set_minor_formatter(NullFormatter())
            ax.set_title(f'{name} | {stamp(start)[8:10]} Mar {stamp(start)[11:16]}–{stamp(end)[11:16]} UT',fontsize=10)
            if b==0:ax.set_ylabel(r'PSD (nT$^2$/Hz)')
            if row==2:ax.set_xlabel('Frequency (mHz)')
            if b==1:ax.axvspan(2,7,color=COLORS[0],alpha=.07)
            np.savetxt(out/f'fft_phase{row+1}_band{b+1}.csv',np.c_[f[k],a[k],p[k]],delimiter=',',
                       header='frequency_Hz,amplitude_squared_nT2,PSD_nT2_per_Hz',comments='')
        summary.setdefault('fft_cases',[]).append({'phase':name,'start':stamp(start),'end':stamp(end),'N':n})
    fig.tight_layout();save(fig,figdir/'Bands_FFT_Phases')

    # Electron spectra: explicit new log-space OLS, not an assumed fitPowerLaw implementation.
    R=loadmat(data_dir/'RBSP.mat',squeeze_me=True);E=loadmat(data_dir/'RBSPenergy.mat',squeeze_me=True)
    flux=R['CountRate']/((E['Emax']-E['Emin'])*E['G'])
    ecases=[('Pre14',dn(2013,3,16,14),dn(2013,3,17)),
            ('Main',dn(2013,3,17,13),dn(2013,3,17,15)),
            ('Recovery',dn(2013,3,18,16),dn(2013,3,18,20)),
            ('Pre12',dn(2013,3,16,12),dn(2013,3,17))]
    for name,start,end in ecases:
        sel=(R['T']>start)&(R['T']<end)
        mean=np.nanmean(flux[sel],axis=0)
        row={'samples':int(sel.sum()),'Lstar_range':[float(np.nanmin(R['Lstar'][sel])),float(np.nanmax(R['Lstar'][sel]))],
             'mean_flux':mean.tolist(),'gamma':[],'R2':[]}
        for ch in [slice(0,6),slice(6,10)]:
            xx=np.log10(E['E'][ch]);yy=np.log10(mean[ch]);slope,intercept=np.polyfit(xx,yy,1)
            row['gamma'].append(float(-slope));row['R2'].append(float(1-np.sum((yy-slope*xx-intercept)**2)/np.sum((yy-yy.mean())**2)))
        common=sel&(R['Lstar']>=5.1)&(R['Lstar']<=5.5)
        row['common_L_samples']=int(common.sum())
        if common.any():row['common_L_mean_flux']=np.nanmean(flux[common],axis=0).tolist()
        summary['fits'][name]=row
        np.savetxt(out/f'electron_{name}.csv',np.c_[E['E'],mean],delimiter=',',header='energy_keV,mean_differential_flux',comments='')
    (out/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2))
    print(json.dumps(summary,ensure_ascii=False,indent=2))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data-dir',type=Path,
                        help='Folder containing GEOMAG.mat, RBSP.mat and RBSPenergy.mat.')
    parser.add_argument('--output-dir',type=Path,default=LAB_ROOT/'generated',
                        help='Output folder; defaults to labs/03_van_allen/generated/.')
    parser.add_argument('--self-check',action='store_true',
                        help='Run analytical sinusoid and Parseval checks without input files.')
    args=parser.parse_args()
    if args.self_check:
        print(json.dumps({'validation':verify()},indent=2))
    else:
        if args.data_dir is None:
            parser.error('--data-dir is required unless --self-check is used')
        missing=[name for name in ['GEOMAG.mat','RBSP.mat','RBSPenergy.mat']
                 if not (args.data_dir.expanduser()/name).is_file()]
        if missing:
            parser.error('missing required input files: '+', '.join(missing))
        main(args.data_dir,args.output_dir)
