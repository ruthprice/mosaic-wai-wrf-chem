import numpy as np
import pyproj

def extract_point_from_grid(lons, lats, target_lon, target_lat):
    '''
    For a single lat, lon point given by point_coords, function returns the indices of
    the closest point from gridded data output, using pyproj package.
    lons, lats: arrays of lon and lat grid to extract from. must have same length
    target_lon, target_lat: floats of coordinates to extract
    inds_min_dist: tuple of indices corresponding to a grid cell in gridded data
                   with minimum distance to target. coords are given as
                   (j, i).
    '''
    geod = pyproj.Geod(ellps="WGS84")
    _, _, dists = geod.inv(
        np.full(lons.shape, target_lon),
        np.full(lats.shape, target_lat),
        lons,
        lats,
    )
    inds_min_dist = np.unravel_index(np.argmin(dists), lons.shape)
    return inds_min_dist

def calc_mosaic_size_bins(nbins=4, verbose=False):
    # Constants (from WRF-Chem logic)
    dlo_1 = 3.90625e-8     # First bin lower diameter in meters (3.90625 nm)
    dhi_n = 10.0e-6        # Last bin upper diameter in meters (10 µm)

    # Calculate logarithmic spacing factor
    dum = np.log(dhi_n / dlo_1) / nbins

    # Initialize arrays
    dlo = np.zeros(nbins)
    dhi = np.zeros(nbins)
    dcen = np.zeros(nbins)

    # Set first lower diameter and last upper diameter
    dlo[0] = dlo_1
    dhi[-1] = dhi_n

    # Compute bin edges
    for n in range(1, nbins):
        dlo[n] = dlo[0] * np.exp(n * dum)
        dhi[n-1] = dlo[n]

    # Compute bin centers
    for n in range(nbins):
        dcen[n] = np.sqrt(dlo[n] * dhi[n])

    # Convert from meters to microns (µm)
    dlo_um = dlo * 1e6
    dhi_um = dhi * 1e6
    dcen_um = dcen * 1e6

    # Display results
    if verbose:
        print("MOSAIC 4-bin dry aerosol diameter bins (µm):")
        print("{:<6} {:>10} {:>10} {:>10}".format("Bin", "dlo", "dhi", "dcen"))
        for i in range(nbins):
            print(f"{i+1:<6} {dlo_um[i]:10.4f} {dhi_um[i]:10.4f} {dcen_um[i]:10.4f}")

    return np.array([dlo_um, dcen_um, dhi_um])