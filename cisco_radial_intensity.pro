pro radial_intensity, image, hdr, pscl, intensity, rad
  ;;Returns the azimuthal average intensity along radial distances.
  ;image = input image.
  ;pscl = pixel scale of the input image.
  ;intensity = azimuthal average intensity along radial distance.
  ;rad = vector containing radial distance info.
  ;img=congrid(minImg, 256, 256, /INTERP)
  ax=1024/float(hdr[0].naxis1)
  image=congrid(image, 1024, 1024, /interp)
  img=shift(image, 0, ax*hdr.CRPIX1-ax*hdr.CRPIX2)
  sz=size(img)
  cx=sz[1]/2-1
  cy=sz[2]/2-1
  up=sz[2]/2
  Inty=fltarr(up)
  pcnt=make_array(up)
  ix=0

  radin=fltarr(up)
  for k=0,sz[1]/2-1 do begin
    radin(sz[1]/2-1-k)=mean(img[cx-2:cx+2,sz[1]/2-1+k])
  endfor
  intensity=radin
;;=============================================================
;;convert to polar and get the radin intensity easily in there
;;=============================================================

  ;for i=0,up-1 do begin
  ;      for q=cx-1,cx+1 do begin
  ;          for z=cy-i-1,cy+i+1 do begin
  ;            if q ge 0 && q le sz[1]-1 and z ge 0 && z le sz[1]-1 then begin
  ;            if floor(sqrt((q-cx)^2+(z-cy)^2)) eq i then begin ;gt i-1 and round(sqrt((q-cx)^2+(z-cy)^2)) lt i+1 then begin
  ;              Inty(i)=Inty(i)+img[q,z]
  ;              pcnt(i)=pcnt(i)+1
  ;           endif
  ;           endif
  ;       endfor
  ;    endfor
  ;   ix=ix+1
  ;endfor
  ;
  ;intensity=Inty/pcnt
  ax=findgen(up)*pscl/960
  rad=ax
  plot,ax, intensity
  return
end
