pro minbg, image1, minimumBG
;Making minimum background image.
;image = the image cube to make minimum image.
;minimumBG = output minimum background image.
img1 = image1
sz=size(img1)
len1=sz[3]
minImg=fltarr(sz[1],sz[2])
minImg=min(img1, dimension=3)
;;minImg=median(img1, dimension=3)
per=0.05
for i=0,sz[1]-1 do begin
    for j=0,sz[2]-1 do begin
;        take=fltarr(1,len1)
;        for k=0,len1-1 do begin
;            take(k)=abs(img1(i,j,k))        
;        endfor
       take=img1(i,j,*)
       srt=take(sort(take))
       sum=0
       px=0
       for p=0,ceil(per*len1) do begin
            if srt(p) gt 0 then begin
              sum=sum+srt(p)
              px=px+1
            endif ;else begin
              ;sum=sum+srt(p+2)
;           endelse
       endfor
       minImg(i,j)=sum/px
;      minImg(i,j)=median(srt)
    endfor
endfor
minimumBG=minImg
return
end