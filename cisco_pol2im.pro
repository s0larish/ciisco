function cisco_pol2im, polim, hdr
im=polim
sz=size(im, /dimension)
if hdr.NAXIS1 eq 512 then ax=1 else ax=512.0/hdr.NAXIS1
xsz=hdr.naxis1*ax & ysz=hdr.naxis2*ax
rectim=fltarr(xsz+1,ysz+1)

if sz(0) ge 2048 and sz(1) ge 2048 then begin
  sf_r=1. & sf_t=0.15
endif else begin
  sf_r=1. & sf_t=1.
endelse

for i1=0.,sz(0)-.1,0.05 do begin
  for j1=0,sz(1)-1 do begin
    i=float(i1*sf_t) & j=float(j1*sf_r)
    x=(j*cos(i*!PI/180.))
    y=(j*sin(i*!PI/180.))
    if abs(x) lt xsz/2. and abs(y) lt ysz/2. then begin
      rectim(x+(xsz/2.),y+(ysz/2.))=im(i1,j1)
    endif
  endfor
endfor
rectim=rotate(rectim(0:xsz-1,0:ysz-1),1)
return,rectim
end