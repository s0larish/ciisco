;Finds the principle angle of CME.
;;
Icln=Icln
szcln=size(Icln)
yp=fltarr(szcln[1],szcln[3])
byarr = []

;;;Summing intensity at each angle.
;for k=0,szcln[3]-1 do begin
;    for j=0,szcln[1]-1 do begin
;        yp(j,k)=total(abs(Icln[j,*,k]))
;    endfor
;endfor
yp = total(abs(Icln), 2)
yp = sigma_filter(yp,15,n_sigma=4,/all_pixels,/iterate) ; To remove any bright points present in the map.

;; setting minimum and maximum speeds as 100 and 2000 km/s resp. to get corresponding number of frames
cme_duration_thresh_slow = ceil((rmax-rmin)*hd[0].rsun_ref/(cad*100*1000.)) 
cme_duration_thresh_fast = ceil((rmax-rmin)*hd[0].rsun_ref/(cad*2000*1000.))

;; identify and put threshold based on how many frames at max can go with slowest CME speed (say 100 km/s)

;; Identifing CME location.
edge_frames = 5
ker = szcln[3]/10-1
ypp=yp[*,edge_frames:szcln[3]-edge_frames-1]-gauss_smooth(yp[*,edge_frames:szcln[3]-edge_frames-1],ker, /edge_truncate)
thresh= ypp ge mean(ypp)+4*stdev(ypp) ; ypp ge 70; Need to work on this threshold
thresh=morph_close(dilate(thresh, REPLICATE(1,5,5)), REPLICATE(1,5,5)) ;morph_close(thresh, REPLICATE(1,10,10))
regions=label_region(thresh,/ALL_NEIGHBORS)
n_regions=max(regions)
yrx=fltarr(szcln[3],szcln[2])
yrx1=[]
cpa=[]
width=[]
kx=0
for k=1,n_regions do begin
    ax=where(regions eq k)
    ;axx=ax mod szcln[1]
    ;axy= ax/szcln[2]
    ind=array_indices(regions, ax)
    sidx=size(ind, /dimension)
    if sidx[1] ge 50 then begin
       arrind=ind[0,*]
       bx = arrind[UNIQ(arrind, SORT(arrind))]
       arrind=ind[1,*]
       by = arrind[UNIQ(arrind, SORT(arrind))]   
       
       ;; Minimum angular width of CME is set to 10 degrees and spanning in time determined by CME speed.   
       if n_elements(bx) ge 10 && n_elements(by) ge cme_duration_thresh_fast && n_elements(by) le cme_duration_thresh_slow then begin  
         cpax=floor((max(ind[0,*])-1+min(ind[0,*])-1)/2) ;Central PA of CME.
         cpa=[cpa,cpax]
         widthx=floor((max(ind[0,*])-min(ind[0,*]))+1) ;Angular width of CMEs.
         width=[width,widthx]
         byarr = [[byarr], [min(by), max(by)]] 
         
         ;;Summing intensity at each height for all angles containing CME.
         for kr=0,szcln[3]-1 do begin
             for j=0,szcln[2]-1 do begin                 
                 yrx(kr,j)=total(abs(Icln[min(ind[0,*])-1:max(ind[0,*])-1,j,kr]))  
;                  yrx(kr,j)=(abs(Icln[355,j,kr]))                
             endfor
         endfor
          yrx1=[yrx1,yrx]
          kx=kx+1
       endif        
    endif    
endfor

if kx gt 0 then begin
  ;; Preparing datacube of height-time maps at identified regions in CME map
  yr=fltarr(szcln[3],szcln[2],kx)
  syrx1=size(yrx1)
  if kx gt 1 then begin
    for ix=0,kx-1 do begin
      i=n_elements(yp)/360*ix
      yr[*,*,ix]=yrx1[i:i+n_elements(yp)/360-1,*]
    endfor
  endif else begin
    yr=yrx1
  endelse
endif else begin
  print, 'NO REGION FOUND IN CME MAP'
endelse


end