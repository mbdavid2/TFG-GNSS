c234567
c
c20101110[MHP]: Main diff. of this program regarding to program
c spherical_harmonic_fit.v7.f is the target: general sph. harm. fitting
c from a series of lon/ra/azimuth, lat/dec/ele, value, sigma_value
c given directly in the standard input.
c
c080730: Main diff. of v7 regarding to v6 is the adaptation for
c being use in VTEC map prediction
      implicit double precision (a-h,o-z)
      parameter(PI=3.141592653589793d0)
      parameter(maxobs=100000,maxunk=2)
      dimension a(maxobs,maxunk),y(maxobs),x(maxunk)
      dimension ata(maxunk*(maxunk+1)/2),aty(maxunk)
      dimension yp(maxobs),res(maxobs)
      dimension sx(maxunk)
      logical accept_obs(maxobs)
      dimension sy2(maxobs)
      logical debug
      character arg1_res_max_sigmas*16,arg2_max_iter_outliers*16
c Tolerance to consider integer the longitude (used just in
c the IONEX output).
c      parameter(xlonzerotol=0.01d0)
      parameter(debug=.FALSE.)

      common /constants/d2r
      dimension rb(3),r(3),rs(3),ri(3),rj(3),rlonlat(3),rsm(3)


      namelist /parameters/res_max_sigmas,max_iter_outliers

      open(1,
     1   file='x_y_sigmay_2_linear_fit.log')

c      open(2,status='old',
c     1   file='x_y_sigmay_2_linear_fit.nml',
c     1   err=9002)
c      read(2,NML=parameters,err=9003)

c nargs() available in ifort compiler
c      narg=nargs()-1
c command_argument_count() available in gfortran compiler
      narg=command_argument_count()
c
      if(narg.ne.2)then
       stop 'Usage: x_y_sigmay_2_linear_fit.v2  res_max_sigmas (e.g. 2.5
     1d0) max_iter_outliers (e.g. 5)'
      else
       call getarg(1,arg1_res_max_sigmas) 
       read(arg1_res_max_sigmas,*)res_max_sigmas
       write(1,*)
       write(1,*)'arg1_res_max_sigmas = ',arg1_res_max_sigmas
       write(1,*)'res_max_sigmas = ',res_max_sigmas
       call getarg(2,arg2_max_iter_outliers) 
       read(arg2_max_iter_outliers,*)max_iter_outliers
       write(1,*)
       write(1,*)'arg2_max_iter_outliers = ',arg2_max_iter_outliers
       write(1,*)'max_iter_outliers = ',max_iter_outliers
      endif

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      nunk=2
      nobs=0

      do k=1,maxobs
       accept_obs(k)=.TRUE.
      enddo

      iter_outliers=0

 10   continue

      read(*,*,end=99,err=999)x1,y1,sy1

      nobs=nobs+1

      if(nobs.gt.maxobs)then
       write(1,*)'ERROR: nobs > maxobs, please increase maxobs & recom.'
       stop 'ERROR: nobs.gt.maxobs, please increase maxobs & recom.'
      endif

      y(nobs)=y1
      sy2(nobs)=sy1*sy1

      a(nobs,1)=x1
      a(nobs,2)=1.d0

      goto 10


  99  continue
      iter_outliers=iter_outliers+1

      write(1,*)'nobs,nunk=',nobs,nunk

      do k=1,maxobs
       yp(k)=0.d0
      enddo
      do j=1,maxunk
       aty(j)=0.d0
       do i=1,j
        lij=i+j*(j-1)/2
        ata(lij)=0.d0
       enddo
      enddo

c Computing AtA Aty

      nobs_sel=0
      do k=1,nobs
       if(accept_obs(k))then
        nobs_sel=nobs_sel+1
        do j=1,nunk
         aty(j)=aty(j)+a(k,j)*y(k)/sy2(k)
         do i=1,j
          lij=i+j*(j-1)/2
          ata(lij)=ata(lij)+a(k,i)*a(k,j)/sy2(k)
         enddo
        enddo
       else
        write(1,*)'Warning: iter_outliers,rejected obs. # ',
     1         iter_outliers,k
       endif
      enddo

      write(1,*)'iter_outliers,nobs_sel=',iter_outliers,nobs_sel

c      write(1,*)'(At.A) =',(ata(ii),ii=1,6)
      write(1,*)'(At.A) =',(ata(ii),ii=1,3)

      write(1,*)
      write(1,*)' INVERTING At.A'
      write(1,*)
      write(1,*)' Cholesky decomposition...'
      call dpptrf('U',nunk,ata,ier1)
      write(1,*)'Error status dpptrf=',ier1
      write(1,*)' Inversion...'
      call dpptri('U',nunk,ata,ier2)
      write(1,*)'Error status dpptri=',ier2
 
      write(1,*)'(At.A)**-1 =',(ata(ii),ii=1,3)

c
      write(1,*)
      write(1,*)' COMPUTING x=(At.A)^-1 * (At.y)'
      write(1,*)
      call dspmv('U',nunk,1.d0,ata,aty,1,0.d0,x,1)

      write(1,*)'x=(At.A)^-1 * (At.y)=',(x(ii),ii=1,2)
 
c
      write(1,*)
      write(1,*)' COMPUTING residuals: (y-A.x) and X**2'
      write(1,*)

      restot=0.d0
      restot_sel=0.d0
      noutliers0=0
      chi2=0.d0
      do i=1,nobs
       yp(i)=0.d0
       do j=1,nunk
        yp(i)=yp(i)+a(i,j)*x(j)
       enddo
       res(i)=y(i)-yp(i)
       if(iter_outliers.eq.max_iter_outliers)then
         write(*,123)a(i,1),y(i),yp(i),res(i),
     1            iter_outliers,accept_obs(i),'FITTED'
       endif
       restot=restot+res(i)*res(i)
       if(accept_obs(i))then
         restot_sel=restot_sel+res(i)*res(i)
         chi2=chi2+restot_sel/sy2(i)
       else
         noutliers0=noutliers0+1
       endif
      enddo

      chi2=chi2/(nobs-nunk+1)

 123  format(4(e23.15,1x),i2,1x,l1,1x,a)

      sigma=dsqrt(restot/(nobs-nunk))
      sigma_sel=dsqrt(restot_sel/(nobs-nunk-noutliers0))

      write(1,*)'Chi**2 = ',chi2

      if(iter_outliers.eq.max_iter_outliers)then
        write(1,*)'Final SIGMA,nobs, iter_outliers=',sigma,
     1            nobs,iter_outliers
        write(1,*)'Final filtered SIGMA & nobs=',
     1        sigma_sel,nobs-noutliers0
        write(*,234)sigma_sel,nobs-noutliers0,sigma,nobs,iter_outliers,
     1             'SIGMA'

        do j=1,nunk
         ljj=j*(j+1)/2
         sx(j)=dsqrt(ata(ljj))
         stdev_x=sx(j)*sigma_sel
         write(*,345)j,x(j),stdev_x,
     1                'COEF'
         do i=1,j-1
          lij=i+j*(j-1)/2
          corr=ata(lij)/sx(i)/sx(j)
          write(*,355)i,j,corr,'CORR'
         enddo
        enddo

      endif

 234  format(2(f9.3,1x,i7),1x,i2,1x,a)
 345  format(i2,1x,e23.13,1x,e18.8,1x,a)
 355  format(2i2,1x,e18.8,1x,a)


      write(1,*)'iter_outliers, Std.Dev.=',iter_outliers,sigma
      write(1,*)'iter_outliers, Std.Dev.Sel.=',iter_outliers,sigma_sel

c      resmax=sigma*res_max_sigmas
c      resmax2=resmax*resmax
      resmax=sigma_sel*res_max_sigmas
      resmax2=resmax*resmax
      noutliers=0
      do i=1,nobs
       if(res(i)*res(i).gt.resmax2)then
        noutliers=noutliers+1
        accept_obs(i)=.FALSE.
        write(1,*)a(i,1),y(i),yp(i),res(i),
     1            iter_outliers,'outlier'
       else
        accept_obs(i)=.TRUE.
       endif
      enddo
 
      write(1,*)'iter_outliers,noutliers=',iter_outliers,noutliers


      if(iter_outliers.lt.max_iter_outliers)goto 99
 
      stop
 9002 stop 'ERROR: opening x_y_sigmay_2_linear_fit.nml'
 9003 stop 'ERROR: reading x_y_sigmay_2_linear_fit.nml'
 999  stop 'ERROR: reading standard input'
      end
