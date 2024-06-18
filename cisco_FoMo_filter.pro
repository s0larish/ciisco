;goto, horizon
;;cd,'D:\Project\testidl\HT\', current=current
;impol=fltarr(360,256,sz1[3])
;r_mask=fix(0.5*16*60*2.3/hdr[0].CDELT1)
;imsk_pol=fltarr(360,256)+1
;imsk_pol[0:359, 0:r_mask]=0
;
;for k=0, sz1[3]-1 do begin
;    temp=im2pol(Ikcor[*,*,k],hdr(k))
;    nanInd = WHERE(~(FINITE(temp)))
;    snand=size(nanInd)
;    if snand[2] ge 0 then begin
;    temp[nanInd]=0.0
;    endif
;    impol[*,*,k]=temp*imsk_pol
;    plot_image, impol[*,*,k], min=0, max=0.12
;;    filename='COR1A_pol_'+string(k,format='(I04)')+'.png'
;;    write_png, filename, tvrd(/true)
;endfor

;; Initializing
Icln=fltarr(sz_pol[0],sz_pol[1],sz_pol[2])
Iht=fltarr(sz_pol[2],sz_pol[1],sz_pol[0])
window,0,xs=800,ys=800

;; Fourier motion filter
for k=0,sz_pol[0]-1 do begin
    temp=st_map[*,*,k]
    pad=replicate(0.0, sz_pol[1], sz_pol[1]) ;; FFT of square matices are better.
    xtmp=sz_pol[1]/2-1-floor(sz_pol[2]/2)
    pad[xtmp,0]=temp
    Imfft=fft((pad), /center)
    sft=size(Imfft)
;    plot_image, alog10(imfft)
;    write_png, outdir+'fft'+string(k)+'.png', tvrd(/true)
    ;val=abs(min(Imfft))
    val=0
    flt_mask=fltarr(sft[1],sft[2])+1
    flt_mask[0:floor(sft[1]/2),0:floor(sft[2]/2)-1]=val
    flt_mask[floor(sft[1]/2):sft[1]-1, floor(sft[2]/2):sft[2]-1]=val
;    flt_mask[0:4,sft[2]-4:sft[2]-1]=val
;    flt_mask[sft[1]-4:sft[1]-1,0:4]=val
    cent = 9 ;; Masking pixels for center powers
    flt_mask[floor(sft[1]/2)-cent:floor(sft[1]/2)+cent, floor(sft[2]/2)-cent:floor(sft[2]/2)+cent]=val
    flt_mask = gauss_smooth(flt_mask,2, /edge_truncate)
;    flt_mask=reverse(flt_mask,1)
    
    Ift=Imfft*flt_mask
    ;pad=replicate(0.0, sft[1]+2, sft[2])
    ;pad[1,0]=Ift
    ;temp=fft(pad, /inverse)   
    ;temp=temp[1:sft[1],0:sft[2]-1]
    temp=fft(Ift, /inverse, /center)
    temp=temp[xtmp:xtmp+sz_pol[2]-1,*]
    Iht[*,*,k]=temp
;    plot_image, temp, min=0, max=0.02
;    filename='COR1A_HT_'+string(k,format='(I04)')+'.png'
;    write_png, filename, tvrd(/true)
endfor
;stop
horizon:
;; Creating datacube of Foueir filtered images
window,0,xs=800,ys=800
for k=0,sz_pol[2]-1 do begin
    temp=reform(Iht[k,*,*])
    Icln[*,*,k]=fmedian(reverse(rotate(temp,1),1),3)
    plot_image, (Icln[*,*,k])^.2, min=0, max=2
    filename='fft_motion_'+strmid(ssw_jsoc_index2filenames(hd[k]),0,23)+'.png'
;    write_png, outdir+filename, tvrd(/true)
endfor

;for k=0,sz[3]-2 do begin
;    Icln[*,*,k]=impol(*,*,k+1)-impol(*,*,k)
;    plot_image,impol[*,*,k+1]-impol[*,*,k]
;    wait,0.5
;end

;cd,current
end