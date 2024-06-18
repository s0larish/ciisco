;Fits parabola in the height-time plots and give velocity and acceleration values.

acc_max = []
;acc_med = []
;acc_avg = []
cme_pa = []

pscl = hd[0].cdelt1
r_mask=20; fix(0.5*16*60*.1/pscl)

for i = 0, kx-1 do begin
  ;i = 7
  print, i
  xbuff = (cme_duration_thresh_slow+cme_duration_thresh_fast)/3. ;; Buffer pixels for height-time map in case some part is missed in previous step
  if edge_frames+byarr[0,i]-xbuff le edge_frames || $
    edge_frames+byarr[1,i]+xbuff ge szcln[3]-edge_frames then xbuff = 0

  yr1 = yr[edge_frames+byarr[0,i]-xbuff:edge_frames+byarr[1,i]+xbuff,*,i] ;abs(st_map[*,25:*,i]);*mask_pol;

  ;yr1 = (yr1-gauss_smooth(yr1,11, /edge_truncate))
  ;Ithresh=yr1 ge mean(yr1)+2.5*stdev(yr1)
  syr=size(yr1)
  Ithresh= sobel(yr1) gt mean(sobel(yr1))+1.75*stddev(sobel(yr1)); yr1 gt mean(yr1)+1.5*stddev(yr1) ;canny(yr1)
  ;parabola: (x-x1)^2=4a(y-y1)
  y0=0.;floor(0.5*16*60/pscl)
  km_pxl= (rmax-rmin)/sz_pol[1]*hd[0].rsun_ref/1000. ;km per pixel
  ;pscl/hd[0].rsun_arc*hd[0].rsun_ref/1000. ;km per pixel

  ;; Determine the range for which aval is valied based on y=ax^2 relation.
  ;; Cross-check with poly_fit for 2nd order?
  aval=arrgen(.01,10, nstep=1000, /log); findgen(500)*0.01;
  n_aval=n_elements(aval)
  acc=intarr(syr[1],n_aval)
  idx=where(Ithresh eq 1)
  idx1=array_indices(Ithresh, idx)
  vel_arr = []
  acc_arr = []

  for cnt=0,n_elements(idx)-1 do begin
    for r=0,n_aval-1 do begin
      xidx=idx1[0,cnt]
      yidx=idx1[1,cnt]
      x0=xidx-sqrt((yidx-y0)/aval(r))
      x0=round(x0)
      if x0 lt syr[1] and x0 ge 0 then begin
        acc(x0,r)=acc(x0,r)+1
      endif
    endfor
  endfor
  acc_max = [acc_max, max(acc)]
  ;acc_med = [acc_med, median(acc)]
  ;acc_avg = [acc_avg, mean(acc)]
  ;if max(acc) ge 50 then cme_pa = [cme_pa, i]
  ;endfor

  ;stop
  if max(acc) ge 150 then begin ; TODO: check for this threshold by considering more eruptions
    acc_th = acc ge .85*max(acc) ;Setting threshold in Hough space.
    acc_mr=morph_close(acc_th, REPLICATE(1,5,5))
    acc_reg=label_region(acc_mr,/ALL_NEIGHBORS)
    n_accreg=max(acc_reg)

    window, 0, xs=500, ys=700
    aia_lct, wave=wavln, /load
    ;    plot_image,(yr1-median(yr1,13)), /nosquare, min=0, max=5, charsize=2
    plot_image, yr[edge_frames:-edge_frames,*,i]^.2, /nosquare, min=0, charsize=2, $
      title = strmid(hd[0].date_obs,0,10)

    for kp=1,n_accreg do begin
      ac_x=where(acc_reg eq kp)
      acc_ind=array_indices(acc, ac_x)
      sacc=size(acc_ind)
      ;      print,sacc
      if sacc[2] gt 20 then begin
        x0=median(acc_ind[0,*])
        ap=median(aval(acc_ind[1,*]))
        y=[] & x=[]
        for j=0,syr[1]-1 do begin
          y1= round(y0+ap*(j-x0)^2)
          if y1 lt syr[2] && y1 ge 0 then begin
            y=[y,y1]
            x=[x,j]
          endif
        endfor

        yvel=[] & xvel=[]
        xdsp=[] & ydsp=[]
        for k=0,n_elements(y)-1 do begin
          if y(k) ge y0 and x(k) ge fix(x0+0.5) then begin
            xdsp=[xdsp,x(k)]
            ydsp=[ydsp,y(k)]
          endif
          if y(k) ge r_mask and x(k) ge fix(x0+0.5) then begin
            yvel=[yvel,y(k)]
            xvel=[xvel,x(k)]
          endif
        endfor
        ;        v_avg=round(2*km_pxl*(max(yvel)-min(yvel))/((floor(n_elements(yvel))-1)*cad))
        v_coef = poly_fit(xvel*cad, yvel*km_pxl, 1) ; Average speed based linear fitting of identified points

        ;ac_avg=2*1000*v_avg/((floor(n_elements(yvel)/2)-1)*cad*60)
        ac_avg=round(2*ap*km_pxl*1000.0/(cad)^2)

        vel_arr = [vel_arr, round(v_coef[1])]
        acc_arr = [acc_arr, ac_avg]
        ;print,ap  &  print,round(x0) ;& print,xvel

        ;      plot_image,yr1;,/nosquare
        ;      print, ydsp & print, 'X0=', x0
        loadct,2, /silent
        oplot, xdsp+byarr[0,i]-xbuff, ydsp, color=cgcolor('cyan'),thick=2
      endif
    endfor
    y0x=y0*(fltarr(syr[1],1)+1)
    oplot,y0x, color=255, thick=2

    print,strcompress('Onset Time: '+strmid(hd[byarr[0,i]].date_obs,0,19))
    print,strcompress('Central Position Angle:'+string(cpa[i])+' degree')
    print,strcompress('Eruption Width:'+string(width[i])+' degrees')
    print,strcompress('Average Speed:'+string(round(mean(vel_arr)))+' km/s')
    print,strcompress('1-sigma Speed:'+string(round(stddev((vel_arr))))+' km/s')
    print,strcompress('Average Acceleration:'+string(round(mean(acc_arr)))+' m/s^2')
    print,strcompress('1-sigma Acceleration:'+string(round(stddev((acc_arr))))+' m/s^2')

    window, 1, xs=500, ys=700
    aia_lct, wave=wavln, /load
    plot_image, acc, /nosquare, charsize=2, title = 'Hough Space', xtitle = 't!d0!n', ytitle = 'S'
  endif else begin
    print, 'NO ERUPTION FOUND IN THIS REGION!'
  endelse

endfor

;;for just single case;old
;ht_mx=where(acc ge 0.9*max(acc))
;ind_mx=array_indices(acc,ht_mx)
;x0=mean(acc_ind[0,*])
;ap=mean(aval(acc_ind[1,*]))
;y=[]
;x=[]
;for j=0,syr[1]-1 do begin
;    y1= round(y0+ap*(j-x0)^2)
;    if y1 lt syr[2] && y1 ge 0 then begin
;          y=[y,y1]
;          x=[x,j]
;    endif
;endfor
;
;yvel=[]
;xvel=[]
;for k=0,n_elements(y)-1 do begin
;    if y(k) ge 100 and x(k) ge fix(x0+0.5) then begin
;          yvel=[yvel,y(k)]
;          xvel=[xvel,k]
;    endif
;endfor
;v_avg=2*5468.75*(max(yvel)-min(yvel))/((floor(n_elements(yvel))-1)*cad*60)
;print,'Average velocity of the CME:',v_avg,' Km/s'
;
;;ac_avg=2*1000*v_avg/((floor(n_elements(yvel)/2)-1)*cad*60)
;ac_avg=2*ap*2*5468.75*1000/(cad*60)^2
;print,'Average acceleration of the CME:',ac_avg,' m/s^2'
;
;plot_image,yr1;,/nosquare
;oplot, y, color=867,thick=2

;lasco thing
;motion filter
;catenary function; y = a*cosh(x/a) = a*(exp(x/a)+exp(-x/a))/2
end