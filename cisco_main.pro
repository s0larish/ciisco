;goto, horizon
;; Identify the impact of change of cadence on the estimation of kinematics

inpath = '/Volumes/Helios/SolO/GIP/occulter/FSI174/'
fc=file_search(inpath,'*.fits')

sopath = '/Users/rpatel/ssw/vobs/ontology/binaries/darwin_x86_64/'
mreadfits_tilecomp, fc, hd, im, /use_shared_lib, /silent

;; Triangulation method:
;; scc_measure, imsuvi, imfsi, hdsuvi, hdfsi 
;stop

horizon:
rmin = 1.5
rmax = 3.0
impol = fltarr(360, 512, n_elements(fc))

; Determine the median cadence
tai=anytim2tai(hd.date_obs)
cad=median(tai-shift(tai,1))

IF uint(hd[0].wavelnth) eq 174 THEN wavln = 171 ELSE wavln = 304
aia_lct, wave=wavln, /load
outdir = '/Volumes/Helios/SolO/GIP/20230201/pngs/polar_1/'
!P.FONT = 1
DEVICE, SET_FONT='Helvetica', /TT_FONT
for i = 0, n_elements(fc)-1 do begin
  polimg = p2sw_polar_map(im[*,*,i], 360, 512, hd[i].euxcen, hd[i].euycen, $
    0, 360, hd[i].rsun_arc/hd[i].cdelt1*rmin, hd[i].rsun_arc/hd[i].cdelt1*rmax)
  ;p2sw_polar_map(img, theta_size, rho_size, xcenter, ycenter, theta_min, theta_max, amin , amax)  
  impol[*,*,i] = reverse(polimg)
endfor

;horizon:
for i = 0, n_elements(fc)-1 do begin
    impol[*,*,i] = sigma_filter(impol[*,*,i],7,n_sigma=3,/all_pixels,/iterate) ;/medimg_2 ; To remove any bright points present in the map.
    plot_image, (impol[*,*,i])^.2, background=255, color=0, title = hd[i].date_obs, $
      xticklen = -0.015, yticklen = -0.015, charsize=2;, min=0, max=10
  ;  write_png, outdir+strmid(ssw_jsoc_index2filenames(hd[i]),0,23)+'.png', tvrd(/true)
  wait, 0.1
endfor

;stop
medimg = mean(impol, dimension=3)*0.8
medvect = smooth(median(medimg, dimension=1),21)
medimg_2 = smooth(replicate_vector(medvect, 360, /columns),7)

for i =0,n_elements(fc)-1 do impol[*,*,i] = impol[*,*,i]/medimg_2
;impol_diff = impol^2-shift(impol^2,0,0,2)

;horizon:
;;generating height-time plot at each position angle
sz_pol = size(impol, /dimension)
st_map = fltarr(sz_pol[2], sz_pol[1], 360)
for i=0,359 do begin
  temp=reform(impol[i,*,*])
  st_map[*,*,i] = reverse(rotate(temp,1),1)
endfor
stop


window, 0 ,xs=700, ys=900
;aia_lct, wave=171, /load
;loadct, 0
;;writing the ht pngs
;for i=0,359 do begin
;  plot_image, (st_map[*,*,i])^.1, title = strcompress('PA = '+string(i)), charsize=2, background = 255, $
;    color=0, xticklen=-0.015, yticklen=-0.015, /nosquare;, min=0, max=10
;  filename = outdir+strcompress('rd_PA = '+string(i))+'.png'
;  write_png, filename, tvrd(/true)
;
;  ;  plot_image, (st_map[*,*,i]-median(st_map[*,*,i], 7))*mask_pol, /nosquare, title = strcompress('PA = '+string(i)), $
;  ;    charsize=2, background = 255, color=0, xticklen=-0.015, yticklen=-0.015, min=-10, max=20
;  ;    filename = out_path+'med_sub'+strcompress('PA = '+string(i))+'.png'
;  ;    write_png, filename, tvrd(/true)
;endfor

for i = 0, n_elements(fc)-1 do begin
  plot_image, alog10(impol_diff[*,*,i]), background=255, color=0, title = hd[i].date_obs, $
    xticklen = -0.015, yticklen = -0.015, charsize=2;, min=0, max=10
;    write_png, outdir+'rd_pol_'+strmid(ssw_jsoc_index2filenames(hd[i]),0,23)+'.png', tvrd(/true)
endfor

stop



rmsk = 1.05
rout = 4.00
cisco_mask_disk,hd[0],rmsk, imsk
;minbg,img, minimg1

polimg = p2sw_polar_map()

minimg=min(img, dimension=3)
mskpix=round(16*60*rmsk/hdr[0].CDELT1)
;iia:
pscl=hdr[0].cdelt1
minpol=im2pol(minimg, hdr[0])
radin1=mean(minpol, dimension=1)
rmask2=round(16.0*60*4.25/hdr[0].CDELT1)
radin=radin1[0:rmask2]
;TIC, /PROFILER
;clock = TIC()
;WAIT, 1
time_1 = (systime(/seconds))
radial_intensity, minimg1, hdr[0],pscl, radin, xaxs ;Getting the azimuthal average intensity along radial distances for minimum image
radin=reverse(smooth(radin,25))
uniform_bkg, radin, hdr[0], newBG  ;Making a uniform background based on input radial intensity profile.
;TOC, clock, REPORT=interimReport
;PRINT, interimReport[-1]
WAIT, 1
time_2 = (systime(/seconds))
print,'Time elapsed: '+string(time_2-time_1)+' seconds'
;stop
;iia:
;imsk=congrid(imsk1, hdr[0].naxis1, hdr[0].naxis2)
;minimg=congrid(minimg1, hdr[0].naxis1, hdr[0].naxis2)
;newbg=congrid(newbg1, hdr[0].naxis1, hdr[0].naxis2)
stop
iia:
;impol=fltarr(360,256, n_elements(fc))
window,0,xs=900,ys=900
for i=0, n_elements(fc)-1 do begin
    temp=((img[*,*,i]-minimg)/newbg*imsk)
    ;temp1=im2pol(temp,hdr[0])
    ;impol[*,*,i]=temp1[*,0:hdr[0].naxis1/2-1]
;    plot_image, impol[*,*,i]^.5
    plot_image, temp<0.025
    tvcircle, round(16*60/hdr[i].CDELT1), round(hdr[0].crpix1), round(hdr[0].crpix2), thick=2
    wait,0.1
endfor
stop
;iia:
icln=impol
mskpol=fltarr(360,256)+1
mskpol[*,0:100]=0
for i=0, n_elements(fc)-1 do begin
  iplx=(impol[*,*,i]^.5)*mskpol
  icln[*,*,i]=iplx<0.25
  plot_image, icln[*,*,i], title='STEREO/COR1A-'+hdr[i].DATE_D$OBS
  filename='COR1A_'+strmid(hdr[i].FILENAME,0,15)+'.png'
  ;write_png, filename, tvrd(/true)
  ;wait,0.1
endfor

end