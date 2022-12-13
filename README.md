# PolarizationMicroscopy
An overview of how we measure fluorescence polarization in living cells.
Note: Fluorescence polarization and anisotropy represent the same property but are calculated slightly differently:
polarization = (ch1 - ch2) / ch1 + ch2)
anisotropy = (ch1 - ch2) / (ch1 + 2*ch2)

'Read_Agar_Images_rotation.m' is set up to read in the whole-image pixel intensity sum for 8 image fields of 2 samples at 9 different polarizing filter angles.
The whole-image pixel intensity sum values are then plotted for either fluorescence channel.

'Read_Agar_Images_final.m' is set up to compute and plot the whole-image fluorescence anisotropy difference between two samples. (8 fields per sample).

'Display_Agar_images.m' reads and displays fluorescent cells from a selected file.

Raw images are available as a set of 10 compressed folders. Filenames include 'processed', which indicates channel registration only.
