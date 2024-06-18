  ; NAME: 
  ;   cisco_mask_disk
  ;   
  ; PURPOSE:
  ;   To generate binary mask to mask out the solar disk or outer FOV
  ;   
  ; INPUTS:
  ;   hdr: Header of the image for which the mask has to be generated
  ;   r_mask: Input radius in Rsun up to which image has to be masked (e.g. 1.2 Rsun)
  ;
  ; OUTPUT:
  ;   imask: Binary mask generated
FUNCTION REPLICATE_VECTOR, vector, numberReplicates, COLUMNS=columns

  IF KEYWORD_SET( columns ) THEN BEGIN
    RETURN, vector ## REPLICATE( 1, numberReplicates, 1 )
  ENDIF ELSE BEGIN
    RETURN, REPLICATE( 1, numberReplicates ) ## vector
  ENDELSE

END

pro cisco_mask_disk, hdr, r_mask, imask
     
  ; Convert the masking radius to number of pixels
  r_mask1=hdr.rsun_obs*r_mask/hdr.CDELT1
  
  ; Initializing
  if strcmp(hdr.INSTRUME, 'EUI') eq 1  then begin
    sz1 = floor(hdr.ZNAXIS1)
    sz2 = floor(hdr.ZNAXIS2)
    cx=floor(hdr.euxcen)
    cy=floor(hdr.euycen)
  endif else begin
    sz1 = floor(hdr.NAXIS1)
    sz2 = floor(hdr.NAXIS2)
    cx=floor(hdr.crpix1)
    cy=floor(hdr.crpix2)
  endelse

  img_mask = fltarr(sz1,sz2)*0+1
  
  
  ; Creating x and y arrays  
  xarr = replicate_vector(indgen(sz1),sz2)
  yarr = replicate_vector(indgen(sz2),sz1, /columns)
  
  ; Creating Mask
  img_mask = sqrt((yarr-cy)^2+(xarr-cx)^2) ge r_mask1
  imask=img_mask
  
  return

end