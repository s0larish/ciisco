function im2pol, img, hdr

  ; Initializing
;  sz1 = floor(hdr.ZNAXIS1)
;  sz2 = floor(hdr.ZNAXIS2)
;  cx=floor(hdr.euxcen)
;  cy=floor(hdr.euycen)
;  rectimg = img
;  
  

rectimg=img ;read the image which is to be converted.
if hdr.NAXIS1 eq 512 then m=1 else m=512.0/hdr.NAXIS1
;m=1
cx=m*hdr.CRPIX1
cy=m*hdr.CRPIX2

;if (keyword_set(radius) ne 0) then begin
;    rad=radius
;endif else begin
;    rad=360
;endelse

;if (keyword_set(th) ne 0) then begin
;    th=theta
;endif else begin
;    th=720
;endelse

th=360
rad=round(hdr.NAXIS1/2*sqrt(2))  ;593

polimg=fltarr(th,rad)
for r=0,rad-1 do begin
  for theta=0,th-1 do begin
    if (round(m*hdr.NAXIS1/2+abs(r*cos((theta+90)*!pi/180.))) lt m*hdr.NAXIS1-1) and (round(m*hdr.NAXIS1/2+abs(r*sin((theta+90)*!pi/180.))) lt m*hdr.NAXIS1-1) then begin    ;theta+90 for solar north as zero
      polimg(theta,r)=rectimg(round(cx+r*cos((theta+90)*!pi/180.)),round(cy+r*sin((theta+90)*!pi/180.)))
    endif
   endfor
endfor

return, polimg[*,0:round(hdr.NAXIS1/2*sqrt(1.3))]

;window,1
;plot_image,polimg,/nosquare, min=0, max=10e-7

end