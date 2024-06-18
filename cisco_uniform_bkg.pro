pro uniform_bkg, radin, hdr1, newbg
;pro uniform_bkg, radin, rout, hdr1, newBG
;;Returns a uniform background based on input radial intensity profile.
;radin : input radial intensity profile.
;newBG : output uniform background image.
if hdr1.NAXIS1 eq 512 then ax=1 else ax=512.0/hdr1.NAXIS1
len=n_elements(radin)
ubg=fltarr(360, len)
for i=0, 360-1 do begin
  ubg[i,*] = radin
endfor
newbg = cisco_pol2im(ubg, hdr1)
return

;;old code based on cartesian coordinates
;;hdr1=hdr[0]
;
;;ax=1024/float(hdr1.naxis1)
;r_mask2=round(16.0*60*rout/hdr1.CDELT1*ax)
;;sz=floor(hdr1.NAXIS1*ax*sqrt(2)); hdr1.NAXIS1*ax
;;lim=floor((sz-hdr1.NAXIS1*ax)/2)
;
;len=n_elements(radin)
;newBG1=fltarr(2*len, 2*len);+10e-8
;lim=round((2*len-(hdr1.naxis1*ax))/2)
;cx=round(hdr1.crpix1*ax+lim);len-1; 
;cy= round(hdr1.crpix2*ax+lim);len-1;
;;ix=0


;for i=0,len-1 do begin
;      for q=0,2*len/2-1 do begin
;          for z=0,2*len/2-1 do begin
;            ;if q ge 0 && q le 2*len-1 && z ge 0 && z le 2*len-1 then begin
;            if floor(sqrt((q-cx)^2+(z-cy)^2)) eq i then begin ;gt i-1 and round(sqrt((q-cx)^2+(z-cy)^2)) lt i+1 then begin 
;                ;if radin(ix) ne 0 then begin
;                    newBG1(q,z)=radin(i)
;                ;endif
;            endif
;           ;endif               
;       endfor
;    endfor
;;   ix=ix+1
;endfor
;newBG=newBG1[lim:lim+hdr1.NAXIS1*ax-1, lim:lim+hdr1.NAXIS1*ax-1]
;newBG=fmedian(reverse(newbg+reverse(newbg),2)+newbg+reverse(newbg),5);fmedian(newBG,3)
;;szbg=size(newbg, /dimension)
;;newbg[szbg[0]/2:*,0:szbg[1]/2]=reverse(newbg[0:szbg[0]/2, 0:szbg[1]/2])
;;plot_image,newBG
;;return
end