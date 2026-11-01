# Αντικατάσταση ΜΟΝΟ του κελιού ορισμού της measure_line().
# Όταν line_bounds=None, η συμπεριφορά παραμένει ίδια με του εργαστηρίου.
def measure_line(star, line, dl=100, cont_left=None, cont_right=None,
                 plot=True, line_bounds=None):
    if cont_left is None:
        cont_left = lines[line]['cont_left']
    if cont_right is None:
        cont_right = lines[line]['cont_right']
    central_l = lines[line]['lam']

    wavelength_init, flux_init = spectra[star]
    selected_range = ((wavelength_init >= central_l-dl) &
                      (wavelength_init <= central_l+dl))
    wavelength = wavelength_init[selected_range]
    flux = flux_init[selected_range]

    in_left = ((wavelength > cont_left[0]) &
               (wavelength < cont_left[1]))
    in_right = ((wavelength > cont_right[0]) &
                (wavelength < cont_right[1]))
    cont = in_left | in_right
    if in_left.sum() < 2 or in_right.sum() < 2:
        raise ValueError('Ανεπαρκή pixels στα παράθυρα συνεχούς')

    slope = ((np.mean(flux[in_right]) - np.mean(flux[in_left])) /
             (np.mean(cont_right) - np.mean(cont_left)))
    continuum = (slope*(wavelength-np.mean(cont_left)) +
                 np.mean(flux[in_left]))

    if line_bounds is None:
        line_bounds = [cont_left[1], cont_right[0]]
    if not (cont_left[1] <= line_bounds[0] < line_bounds[1] <= cont_right[0]):
        raise ValueError('Τα όρια ολοκλήρωσης πρέπει να βρίσκονται μεταξύ των παραθύρων συνεχούς')
    in_line = ((wavelength > line_bounds[0]) &
               (wavelength < line_bounds[1]))
    if in_line.sum() < 2:
        raise ValueError('Ανεπαρκή pixels στο διάστημα ολοκλήρωσης')

    dlambda = np.gradient(wavelength)
    line_flux = np.abs(np.sum(
        (flux[in_line]-continuum[in_line])*dlambda[in_line]))
    noise = (np.sqrt(in_line.sum()) *
             np.std(flux[cont]-continuum[cont]) *
             np.mean(dlambda[cont]))
    EW = np.sum((1.0-flux[in_line]/continuum[in_line])*dlambda[in_line])
    snr = line_flux/noise if noise > 0 else np.nan

    if plot:
        plt.figure(figsize=(8,4))
        plt.plot(wavelength, flux, label='data')
        plt.plot(wavelength, continuum, color='orange', label='continuum fit')
        plt.plot(wavelength[in_left], flux[in_left], color='orange', lw=3,
                 label='continuum range')
        plt.plot(wavelength[in_right], flux[in_right], color='orange', lw=3)
        plt.fill_between(wavelength[in_line], flux[in_line], continuum[in_line],
                         alpha=0.17, color='teal', label='EW integration')
        plt.axvline(line_bounds[0], color='teal', ls='--', lw=1)
        plt.axvline(line_bounds[1], color='teal', ls='--', lw=1)
        plt.xlabel('Wavelength [Å]')
        plt.ylabel('Flux [1e-17 erg / (s * cm² * Å)]')
        plt.title(f'{star}, {line}: EW={EW:.2f} Å, S/N={snr:.0f}')
        plt.legend()
        plt.tight_layout()
        plt.show()

    print(f'{star} {line}: flux={line_flux:.3g} *1e-17 erg/s/cm², '
          f'S/N={snr:.1f}, EW={EW:.3f} Å')
    return EW
