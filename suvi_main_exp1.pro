goto, vormir
;;reading data
inpath = '/Volumes/Helios/ECI_SUVI/all_data/SUVI_ECI_2022_Data/08/28/'
fc = file_search(inpath,'*.fits.gz')
szfc = n_elements(fc)
mreadfits, fc[0:szfc/2-1], hdr171, img171, /silent
mreadfits, fc[szfc/2:*], hdr195, img195, /silent

stop
;vormir:
;

img = img1
delvar, img1

stop

;vormir:


;vormir:
;;generating height-time plot at each position angle

;vormir:

window,0,xs=900,ys=900
for i = 0, sz_img[2]-1 do begin
    plot_image, impol[*,200:600,i], background=255, color=0, charsize=2, xticklen=-0.015, yticklen=-0.015, $
      title= strmid(hdr[i].date_obs,0,19), /nosquare
    write_png, 'crop_'+strmid(hdr[i].filename,0,31)+'.png', tvrd(/true)
endfor

vormir:
window,0,xs=1400, ys=800
img = img171+img195
szim = size(img, /dimensions)
img1 = rebin(img, szim[0]/2, szim[1]/2, szim[2])
img1 = img1[300:300+1263, *, *]
szimg1 = size(img1, /dimensions)

;vormir:
img2=img1
outdir = '/Volumes/Helios/ECI_SUVI/pngs/sub_bg/'
for i=0, n_elements(fc[0:szfc/2-1])-1 do begin
  mn1 = mean(img1[0:9, *,i], dimension=1)
  mn2 = mean(img1[1254:*, *,i], dimension=1)
  bg_mean = fltarr(szimg1[0], szimg1[1])
  temp = REPLICATE_VECTOR(mn1, 340, /columns)
  bg_mean[0:339,*] = temp
  temp = REPLICATE_VECTOR(mn2, 340, /columns)
  bg_mean[924:*,*] = temp
  
  img2[*,*,i] = img1[*,*,i]-bg_mean;minbg*.85
  plot_image, (img2[*,*,i])^.25, title= strmid(hdr195[i].date_obs,0,19), min=0, max=7
;  write_png, outdir+'bg_sides_'+strmid(hdr[i].filename,0,29)+'.png', tvrd(/true)
  wait, 0.1
endfor

;zero padding to make square arrays
sz_img = size(img2, /dimension)
img3 = fltarr(sz_img[0]-10, sz_img[0]-10, sz_img[2])

dx = (sz_img[0]-sz_img[1])/2
for i=0, sz_img[2]-1 do begin
  img3[*, dx-1:dx+sz_img[1]-10-2, i] = img2[5:sz_img[0]-5-1,5:sz_img[1]-5-1,i]
endfor

hdr = hdr195

;;; updating header for require info
hdr.crpix2 = hdr195.crpix2/2+dx-5
hdr.crpix1 = hdr195.crpix1/2-300-5
hdr.naxis1 = szimg1[0]-10
hdr.naxis2 = szimg1[1]
hdr.cdelt1 = 2*hdr.cdelt1
hdr.cdelt2 = hdr.cdelt1

;vormir:
window, 0, xs=900, ys=900
impol = fltarr(360, round(hdr[0].NAXIS1/2*sqrt(1.3)+1), sz_img[2])
aia_lct, wave=171, /load
for i =0, sz_img[2]-1 do begin
  ;    plot_image, rot(img[*,*,i] , -hdr[i].crota2)^.7
  ;    wait, 0.05
  impol[*,*,i] = shift(im2pol(img3[*,*,i], hdr[i]), round(hdr[i].crota2))
       plot_image, impol[*,*,i]^.8, /nosquare
endfor
;stop
;vormir:
sz_pol = size(impol, /dimension)
st_map = fltarr(sz_pol[2], sz_pol[1], 360)
mask_pol = fltarr(sz_pol[2], sz_pol[1])+1
mask_pol[*,0:190]=0

;;generating running difference datacube
impol_rd = fltarr(360, round(hdr[0].NAXIS1/2*sqrt(1.3)+1), sz_img[2])
for i = 0, sz_img[2]-1-4 do begin
  impol_rd[*,*,i] = impol[*,*,i+4]^.5 - impol[*,*,i]^.5
endfor

for i=0,359 do begin
  temp=reform(impol_rd[i,*,*])
  st_map[*,*,i] = reverse(rotate(temp,1),1)
endfor

window, 0 ,xs=700, ys=900
;aia_lct, wave=171, /load
loadct, 0
out_path = '/Volumes/Helios/ECI_SUVI/pngs/ht_sub/'
;;writing the ht pngs
for i=0,359 do begin
  plot_image, (st_map[*,*,i]*mask_pol), title = strcompress('PA = '+string(i)), charsize=2, background = 255, $
    color=0, xticklen=-0.015, yticklen=-0.015, /nosquare, min=-30, max=30
  filename = out_path+'rd_'+strcompress('PA = '+string(i))+'.png'
;  write_png, filename, tvrd(/true)

  ;  plot_image, (st_map[*,*,i]-median(st_map[*,*,i], 7))*mask_pol, /nosquare, title = strcompress('PA = '+string(i)), $
  ;    charsize=2, background = 255, color=0, xticklen=-0.015, yticklen=-0.015, min=-10, max=20
  ;    filename = out_path+'med_sub'+strcompress('PA = '+string(i))+'.png'
  ;    write_png, filename, tvrd(/true)
endfor
end