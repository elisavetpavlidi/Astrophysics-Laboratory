# ΕΚΠΑ • Εργαστήριο φασματοσκοπίας • F0: Hδ και Paδ
# Εκτέλεση ως ΕΝΑ νέο κελί, αφού έχουν οριστεί spectra, lines, np, plt.
# Ίδια ακριβώς ευθεία συνεχούς και όρια ολοκλήρωσης με τη measure_line().
import numpy as np
import matplotlib.pyplot as plt

WINDOWS_F0 = {
    'Hd':  ([4050, 4058], [4160, 4169]),
    'Pa7': ([10020, 10029], [10094, 10100]),
}

def report_line_F0(key, symbol, save_as):
    wl, flux = spectra['F0']
    center = lines[key]['lam']
    L, R = WINDOWS_F0[key]
    cut = (wl >= center - 100) & (wl <= center + 100)
    x, f = np.asarray(wl[cut], float), np.asarray(flux[cut], float)
    left  = (x > L[0]) & (x < L[1])
    right = (x > R[0]) & (x < R[1])
    inside = (x > L[1]) & (x < R[0])
    cont_mask = left | right
    assert min(left.sum(), right.sum(), inside.sum()) >= 3

    xL, xR = np.mean(L), np.mean(R)  # ο οδηγός χρησιμοποιεί τα μέσα των ορίων
    meanL, meanR = f[left].mean(), f[right].mean()
    a = (xR - x) / (xR - xL)
    b = 1 - a
    cont = a * meanL + b * meanR
    dl = np.gradient(x)  # δεν είναι σταθερό, επειδή η κλίμακα FITS είναι log λ
    W = np.sum((1 - f[inside] / cont[inside]) * dl[inside])
    F = abs(np.sum((f[inside] - cont[inside]) * dl[inside]))

    # Εκτίμηση σ ανά pixel από τα υπολείμματα στα παράθυρα, όπως στον οδηγό.
    residual = f - cont
    sig_pixel = np.std(residual[cont_mask], ddof=1)
    sigL = np.std(residual[left], ddof=1) / np.sqrt(left.sum())
    sigR = np.std(residual[right], ddof=1) / np.sqrt(right.sum())

    # Διάδοση πρώτης τάξης. Οι δύο μέσοι όροι του συνεχούς είναι
    # ΚΟΙΝΟΙ για όλα τα pixels της γραμμής (όχι ανεξάρτητοι ανά pixel).
    e = dl[inside]
    sigma_W_pixels = np.sqrt(np.sum((sig_pixel * e / cont[inside])**2))
    dW_dmeanL = np.sum(f[inside] * e * a[inside] / cont[inside]**2)
    dW_dmeanR = np.sum(f[inside] * e * b[inside] / cont[inside]**2)
    sigma_W_cont = np.hypot(dW_dmeanL * sigL, dW_dmeanR * sigR)
    sigma_W = np.hypot(sigma_W_pixels, sigma_W_cont)

    # S/N ορισμού εργαστηρίου (συμβατό με measure_line)
    SNR = F / (np.sqrt(inside.sum()) * np.std(residual[cont_mask])
               * np.mean(dl[cont_mask]))

    fig, ax = plt.subplots(figsize=(7, 3.6))
    ax.plot(x, f, lw=1.0, label='Observed spectrum')
    ax.plot(x, cont, lw=1.8, ls='--', label='Linear continuum')
    ax.scatter(x[left], f[left], s=9, alpha=.8, label='Continuum windows')
    ax.scatter(x[right], f[right], s=9, alpha=.8)
    ax.fill_between(x, f, cont, where=inside & (f < cont),
                    interpolate=True, alpha=.18, label='Integrated absorption')
    ax.axvline(center, lw=.8, ls=':', alpha=.7)
    ax.axvline(L[1], lw=.8, ls=':', alpha=.35)
    ax.axvline(R[0], lw=.8, ls=':', alpha=.35)
    ax.set_xlim((4038, 4180) if key == 'Hd' else (10010, 10110))
    ax.set_xlabel(r'Wavelength $\lambda$ ($\mathrm{\AA}$)')
    ax.set_ylabel(r'$f_\lambda$ ($10^{-17}$ erg s$^{-1}$ cm$^{-2}$ $\mathrm{\AA}^{-1}$)')
    ax.set_title(f'F0 | {symbol}: EW = {W:.2f} ± {sigma_W:.2f} Å')
    ax.legend(frameon=False, fontsize=8, loc='best')
    fig.tight_layout()
    fig.savefig(save_as, dpi=240, bbox_inches='tight')
    plt.show()
    return {'EW':W,'sigma_EW':sigma_W, 'sigma_pixels':sigma_W_pixels,
            'sigma_continuum':sigma_W_cont,'SNR':SNR, 'F':F,
            'N_left':left.sum(), 'N_right':right.sum(), 'N_line':inside.sum()}

res_Hd = report_line_F0('Hd', 'Hδ', 'F0_Hdelta_report.png')
res_Pa = report_line_F0('Pa7', 'Paδ', 'F0_Padelta_report.png')
print('F0 • Μετρήσεις και τυπικές (όχι συστηματικές) αβεβαιότητες:')
for line, res in [('Hδ',res_Hd),('Paδ',res_Pa)]:
    print(f'{line}: EW = ({res["EW"]:.3f} ± {res["sigma_EW"]:.3f}) Å; '
          f'S/N={res["SNR"]:.1f}; '
          f'σ_pixel={res["sigma_pixels"]:.3f} Å, '
          f'σ_cont={res["sigma_continuum"]:.3f} Å')
