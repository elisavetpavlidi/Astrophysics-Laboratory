"""Reproducible calculations for NGC 300 ULX-1, following Vasilopoulos (2026), eqs. (3),(5)-(7).
Input dotnu and nu0 are taken from user's exported notebook (not refitted without raw time/frequency points).
All values in cgs unless indicated. No catalogue 4XMM measurements are assumed.
"""
import json, csv
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

HERE=Path(__file__).resolve().parent
G=6.67430e-8               # cm^3 g^-1 s^-2
MSUN=1.98847e33            # g
PC=3.0856775814913673e18 # cm
YEAR=365.25*86400          # s
MPC=1e6*PC

# The user's time-analysis notebook output (frequency is at t_ref, not at first photon).
NU0=0.0316177; NU0_ERR=3.9e-7
NUDOT=5.4140e-10; NUDOT_ERR=4.12e-12
T_REF=164077
F=1.10e-11            # broad-band bolometric proxy, erg cm^-2 s^-1
DF_REL=0.10           # systematic spectral-model choice, NOT an independent photon counting uncertainty
D0=1.880; DSTAT=0.040; DSYST=0.030
D_ALT=1.967; D_ALT_STAT=0.058; D_ALT_SYST=0.046
XI=0.5
M0=1.4*MSUN; R0=1e6

def evaluate(d_mpc=D0, flux=F, nu_dot=NUDOT, mass=M0, radius=R0, xi=XI):
    d=d_mpc*MPC
    moi=0.4*mass*radius**2
    lum=4*np.pi*d*d*flux
    mdot=lum*radius/(G*mass)
    nacc=2*np.pi*moi*nu_dot
    rm=(nacc/mdot)**2/(G*mass)
    bs=2**0.25*(2*np.pi)**3.5*G**-1.5*mass**-1.5*radius**-3*moi**3.5*xi**-1.75*nu_dot**3.5*mdot**-3
    ra=rm/xi
    b_independent=(2*G*mass*mdot**2*ra**7)**0.25/radius**3
    p=1/NU0
    rco=(G*mass*p*p/(4*np.pi*np.pi))**(1/3)
    fastness=(rm/rco)**1.5
    return dict(L_erg_s=lum,Mdot_g_s=mdot,Mdot_Msun_yr=mdot*YEAR/MSUN,Rm_cm=rm,Rm_km=rm/1e5,
                RA_km=ra/1e5,Rco_km=rco/1e5,B_G=bs,B_independent_G=b_independent,fastness=fastness)

base=evaluate()
assert np.isclose(base['B_G'],base['B_independent_G'],rtol=5e-14)
P=1/NU0
Pdot=-NUDOT/NU0**2
Pdot_err=np.hypot(NUDOT_ERR/NU0**2,2*NUDOT*NU0_ERR/NU0**3)

# Linearized propagation, independent input contributions. These do NOT cover xi or M.
stat_rel_L=2*DSTAT/D0
syst_rel_L=np.hypot(2*DSYST/D0,DF_REL)
stat_rel_B=np.hypot(3.5*NUDOT_ERR/NUDOT,6*DSTAT/D0)
syst_rel_B=np.hypot(6*DSYST/D0,3*DF_REL)
stat_rel_Rm=np.hypot(2*NUDOT_ERR/NUDOT,4*DSTAT/D0)
syst_rel_Rm=np.hypot(4*DSYST/D0,2*DF_REL)

# Evaluate full nonlinear relations at each extreme (not symmetrical linearized errors).
sens={
 'NUDOT_1sigma': [evaluate(nu_dot=NUDOT-NUDOT_ERR)['B_G'],evaluate(nu_dot=NUDOT+NUDOT_ERR)['B_G']],
 'd_stat_pm0p040_Mpc': [evaluate(d_mpc=D0-DSTAT)['B_G'],evaluate(d_mpc=D0+DSTAT)['B_G']],
 'd_syst_pm0p030_Mpc': [evaluate(d_mpc=D0-DSYST)['B_G'],evaluate(d_mpc=D0+DSYST)['B_G']],
 'F_pm10percent': [evaluate(flux=F*(1-DF_REL))['B_G'],evaluate(flux=F*(1+DF_REL))['B_G']],
 'xi_0p3_to_1': [evaluate(xi=0.3)['B_G'],evaluate(xi=1.0)['B_G']],
 'M_1p4_to_2p8_Msun': [evaluate(mass=1.4*MSUN)['B_G'],evaluate(mass=2.8*MSUN)['B_G']],
 'D_Gieren_to_Zgirski': [evaluate(d_mpc=D0)['B_G'],evaluate(d_mpc=D_ALT)['B_G']]
}
summary={
 'input':dict(NU0=NU0,NU0_err=NU0_ERR,NUDOT=NUDOT,NUDOT_err=NUDOT_ERR,t_ref_s=T_REF,F=F,D0_Mpc=D0,xi=XI),
 'baseline':base, 'alternative_Zgirski':evaluate(d_mpc=D_ALT),
 'P_s':P,'Pdot_s_per_s':Pdot,'Pdot_sigma_s_per_s':Pdot_err,
 'L_stat_erg_s':base['L_erg_s']*stat_rel_L,'L_syst_erg_s':base['L_erg_s']*syst_rel_L,
 'Mdot_stat_g_s':base['Mdot_g_s']*stat_rel_L,'Mdot_syst_g_s':base['Mdot_g_s']*syst_rel_L,
 'B_stat_G':base['B_G']*stat_rel_B,'B_syst_F_d_G':base['B_G']*syst_rel_B,
 'B_formal_quadrature_G':base['B_G']*np.hypot(stat_rel_B,syst_rel_B),
 'Rm_stat_km':base['Rm_km']*stat_rel_Rm,'Rm_syst_km':base['Rm_km']*syst_rel_Rm,
 'endpoints_B_G':sens,
 'mass_upper_fastness':evaluate(mass=2.8*MSUN)['fastness']
}
(HERE/'NGC300_ULX1_checked_numbers.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False),encoding='utf-8')
with open(HERE/'NGC300_ULX1_sensitivity.csv','w',newline='') as fp:
    writer=csv.writer(fp)
    writer.writerow(['variable','B_at_lower_parameter_G','B_at_upper_parameter_G','B_min_G','B_max_G'])
    for k,(a,b) in sens.items():writer.writerow([k,a,b,min(a,b),max(a,b)])

labels=[r'$\dot\nu\pm1\sigma$',r'$d\pm0.040$ Mpc (stat.)',r'$d\pm0.030$ Mpc (syst.)',r'$F\pm10\%$',r'$\xi\in[0.3,1]$',r'$M\in[1.4,2.8]M_\odot$']
keys=['NUDOT_1sigma','d_stat_pm0p040_Mpc','d_syst_pm0p030_Mpc','F_pm10percent','xi_0p3_to_1','M_1p4_to_2p8_Msun']
fig,ax=plt.subplots(figsize=(7.1,2.95),layout='constrained')
for k,key in enumerate(keys):
    a,b=sorted(sens[key]);y=len(keys)-k-1
    ax.plot([a/base['B_G'],b/base['B_G']],[y,y],linewidth=2.5)
    ax.plot([a/base['B_G'],b/base['B_G']],[y,y],'.',markersize=8)
ax.axvline(1,linewidth=1,linestyle='--',label=r'Reference $B_s$')
ax.set_yticks(range(len(labels)),labels[::-1],fontsize=9)
ax.set_xscale('log');ax.set_xlim(.18,40)
ax.set_xlabel(r'$B_s/B_{s,0}$   (endpoints evaluated with other inputs fixed)',fontsize=9)
ax.tick_params(axis='x',labelsize=9)
ax.grid(axis='x',alpha=.2)
ax.legend(loc='lower right',fontsize=8)
fig.savefig(HERE/'NGC300_ULX1_sensitivity.png',dpi=220)
plt.close(fig)

print('P=%.6f s, Pdot=%.6e +/- %.2e s/s' % (P,Pdot,Pdot_err))
for k in ['L_erg_s','Mdot_g_s','Mdot_Msun_yr','Rm_km','B_G','Rco_km','fastness']:
    print(k,base[k])
print('B stat/syst/formal',summary['B_stat_G'],summary['B_syst_F_d_G'],summary['B_formal_quadrature_G'])
for k,v in sens.items():print(k,[f'{q/1e13:.4f}' for q in v],'x10^13 G')
