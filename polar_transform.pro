;; written by vaibhav pant on 15 sept,2014
;; SYNTAX:- polar=polar_transform(image,header)
;; Description:- convert a given image to polar image. 
;; keyword :- inverse:- If set then do inverse polar transform. Change r-theta fov to x-y fov
;;            x_size & y_size:- set x_size & y_size to the x coordinates and y coordinates of desired image in x-y fov. For eg if one wants to make 1024,1024 image from polar image then set x_size and y_size to 1024 and 1024. Must set with INVERSE keyword
;;            limb   : set this keyword to see only off limb portion.
;;  xyimage=polar_transform(polar,/inverse,x_size=1024,y_size=1024)
;; 21 Nov : Modified by Vaibhav Pant : added the keywords sf_r and sf_t for scale factor and preserving resolution
;;                                   : added keyword limb for offlimb operation
;; don't use limb with LASCO c2 and c3 images
;;================================================================================================

FUNCTION polar_transform,im,h,inverse=inverse,x_size=x_size,y_size=y_size,limb=limb

;; define scale factor for r and theta
sz=size(im)
if sz(1) ge 2048 and sz(2) ge 2048 then begin
sf_r=1. & sf_t=0.15
endif else begin
sf_r=1. & sf_t=1.
endelse

;cen_x = h.crpix1
;cen_y = h.crpix2
if not keyword_set(inverse) then begin

t1=systime(1)

sz=size(im)
im=float(im)
;; size of lasco images are 1024 X 1024 . so first make center 512,512 as 0,0

rmax=sqrt((sz(1)/2)^2+(sz(2)/2)^2) & ysize=round(rmax/sf_r)+1
thetamax=360 & xsize=round(thetamax/sf_t)+1
;thetar=fltarr(360,rmax+1)
thetar=fltarr(xsize,ysize)
for i=0.,sz(1)-1 do begin
 for j=0.,sz(2)-1 do begin
i1=float(i-(sz(1)/2.)) & i2=float(j-(sz(2)/2.))
r=float(sqrt(i1^2+i2^2))

r=float(r/sf_r)

if r gt 0. then begin
theta=float(atan(i2/i1)*(180./!PI)) ;; in degrees
if i1 lt 0. and theta le 0. then theta1=theta+180.
if i1 lt 0. and i2 lt 0. and theta gt 0 then theta1=theta+180.
if i2 lt 0. and theta lt 0. then theta1=360.+theta
if i2 ge 0. and i1 ge 0. then theta1=theta

theta1=float(theta1/sf_t)
;print,theta1
;print,i
thetar(theta1,r)=im(i,j)
endif
 endfor
;print,i
endfor

if keyword_set(limb) then begin
r_sun=963./h.cdelt1 ;; 963 arcsec is the distance of limb from sun center
thetar(*,0:r_sun)=0.
endif
thetar=thetar(0:xsize-2,0:ysize-2)

print,'time spent is',systime(1)-t1,' seconds'

return,thetar

endif else begin

t1=systime(1)

sz=size(im)
im=float(im)

xyimage=fltarr(x_size+1,y_size+1)

for i1=0.,sz(1)-.1,0.05 do begin
 for j1=0,sz(2)-1 do begin

i=float(i1*sf_t) & j=float(j1*sf_r)

 x=(j*cos(i*!PI/180.))
 y=(j*sin(i*!PI/180.))
if abs(x) lt x_size/2. and abs(y) lt y_size/2. then begin

 xyimage(x+(x_size/2.),y+(y_size/2.))=im(i1,j1)
endif
endfor
;print,i
;stop
endfor
xyimage=xyimage(0:x_size-1,0:y_size-1)
print,'time spent is',systime(1)-t1,' seconds'
return,xyimage
endelse

end
