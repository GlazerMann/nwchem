
      subroutine integrate_kbppv3(version,rlocal,
     >                            nrho,drho,lmax,locp,zv,
     >                            vp,wp,rho,f,cs,sn,
     >                            nfft1,nfft2,nfft3,lmmax,
     >                            G,vl,vnl,vnlnrm,
     >                            semicore,rho_sc_r,rho_sc_k,
     >                            ierr)
*
* $Id: integrate_kbppv3.f,v 1.1 2001-08-30 00:38:58 edo Exp $
*
      implicit none
      integer          version
      double precision rlocal
      integer          nrho
      double precision drho
      integer          lmax
      integer          locp
      double precision zv
      double precision vp(nrho,0:lmax)
      double precision wp(nrho,0:lmax)
      double precision rho(nrho)
      double precision f(nrho)
      double precision cs(nrho)
      double precision sn(nrho)

      integer nfft1,nfft2,nfft3,lmmax
      double precision G(nfft1/2+1,nfft2,nfft3,3)
      double precision vl(nfft1/2+1,nfft2,nfft3)
      double precision vnl(nfft1/2+1,nfft2,nfft3,lmmax)
      double precision vnlnrm(lmmax)

      logical semicore
      double precision rho_sc_r(nrho,2)
      double precision rho_sc_k(nfft1/2+1,nfft2,nfft3,4)

      integer ierr

      integer np,taskid,MASTER
      parameter (MASTER=0)

*     *** local variables ****
      integer lcount,task_count,nfft3d
      integer k1,k2,k3,i,l
      double precision pi,twopi,forpi
      double precision p0,p1,p2,p3,p
      double precision gx,gy,gz,a,q,d

*     **** Error function parameters ****
      real*8 yerf,xerf
c     real*8 c1,c2,c3,c4,c5,c6,yerf,xerf
c     parameter (c1=0.07052307840d0,c2=0.04228201230d0)
c     parameter (c3=0.00927052720d0)
c     parameter (c4=0.00015201430d0,c5=0.00027656720d0)
c     parameter (c6=0.00004306380d0)

*     **** external functions ****
      double precision dsum,simp,util_erf
      external         dsum,simp,util_erf

      call Parallel_np(np)
      call Parallel_taskid(taskid)

      nfft3d = (nfft1/2+1)*nfft2*nfft3
      pi=4.0d0*datan(1.0d0)
      twopi=2.0d0*pi
      forpi=4.0d0*pi

      IF(LMMAX.GT.16) THEN
        IERR=1
        RETURN
      ENDIF
      IF((NRHO/2)*2.EQ.NRHO) THEN
        IERR=2
        RETURN
      ENDIF

      P0=DSQRT(FORPI)
      P1=DSQRT(3.0d0*FORPI)
      P2=DSQRT(15.0d0*FORPI)
      P3=DSQRT(105.0d0*FORPI)

*::::::::::::::::::  Define non-local pseudopotential  ::::::::::::::::
      do l=0,lmax
        if (l.ne.locp) then
          do I=1,nrho
            vp(i,l)=vp(i,l)-vp(i,locp)
          end do
        end if
      end do

*:::::::::::::::::::::  Normarization constants  ::::::::::::::::::::::
      lcount = 0
      do l=0,lmax
        if (l.ne.locp) then
          do i=1,nrho
            f(I)=vp(I,L)*wp(I,L)**2
          end do   
          a=simp(nrho,f,drho)
          do i=l**2+1,(l+1)**2
            lcount = lcount + 1
            vnlnrm(lcount)=a
          end do
        end if
      end do

*======================  Fourier transformation  ======================
      call dcopy(nfft3d,0.0d0,0,VL,1)
      call dcopy(lmmax*nfft3d,0.0d0,0,VNL,1)
      call dcopy(4*nfft3d,0.0d0,0,rho_sc_k,1)
      task_count = -1
      DO 700 k3=1,nfft3
      DO 700 k2=1,nfft2
      DO 700 k1=1,(nfft1/2+1)
        task_count = task_count + 1
        if (mod(task_count,np).ne.taskid) go to 700

        Q=DSQRT(G(k1,k2,k3,1)**2
     >         +G(k1,k2,k3,2)**2
     >         +G(k1,k2,k3,3)**2)

        if ((k1.eq.1).and.(k2.eq.1).and.(k3.eq.1)) go to 700

        
        GX=G(k1,k2,k3,1)/Q
        GY=G(k1,k2,k3,2)/Q
        GZ=G(k1,k2,k3,3)/Q
        DO I=1,NRHO
          CS(I)=DCOS(Q*RHO(I))
          SN(I)=DSIN(Q*RHO(I))
        END DO

        lcount = lmmax+1
        GO TO (500,400,300,200), LMAX+1


*::::::::::::::::::::::::::::::  f-wave  ::::::::::::::::::::::::::::::
  200   CONTINUE
        if (locp.ne.3) then
           F(1)=0.0d0
           do I=2,NRHO
             A=SN(I)/(Q*RHO(I))
             A=15.0d0*(A-CS(I))/(Q*RHO(I))**2 - 6*A + CS(I)
             F(I)=A*WP(I,3)*VP(I,3)
           end do
           D=P3*SIMP(NRHO,F,DRHO)/Q
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GX*(4.0d0*GX*GX-3.0d0*(1.0d0-GZ*GZ))
     >                          /dsqrt(24.0d0)
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GY*(3.0d0*(1.0d0-GZ*GZ)-4.0d0*GY*GY)
     >                          /dsqrt(24.0d0)
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GZ*(GX*GX - GY*GY)
     >                          /2.0d0
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GX*GY*GZ
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GX*(5.0d0*GZ*GZ-1.0d0)
     >                          /dsqrt(40.0d0)
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GY*(5.0d0*GZ*GZ-1.0d0)
     >                          /dsqrt(40.0d0)
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=D*GZ*(5.0d0*GZ*GZ-3.0d0)
     >                          /dsqrt(60.0d0)
        end if



*::::::::::::::::::::::::::::::  d-wave  ::::::::::::::::::::::::::::::
  300   CONTINUE
        if (locp.ne.2) then
          F(1)=0.0d0
          DO I=2,NRHO
            A=3.0d0*(SN(I)/(Q*RHO(I))-CS(I))/(Q*RHO(I))-SN(I)
            F(I)=A*WP(I,2)*VP(I,2)
          END DO
          D=P2*SIMP(NRHO,F,DRHO)/Q
          lcount = lcount-1
          VNL(k1,k2,k3,lcount)=D*(3.0d0*GZ*GZ-1.0d0)
     >                          /(2.0d0*dsqrt(3.0d0))
          lcount = lcount-1
          VNL(k1,k2,k3,lcount)=D*GX*GY
          lcount = lcount-1
          VNL(k1,k2,k3,lcount)=D*GY*GZ
          lcount = lcount-1
          VNL(k1,k2,k3,lcount)=D*GZ*GX
          lcount = lcount-1
          VNL(k1,k2,k3,lcount)=D*(GX*GX-GY*GY)/(2.0d0)
        end if

*::::::::::::::::::::::::::::::  p-wave  ::::::::::::::::::::::::::::::
  400   CONTINUE
        if (locp.ne.1) then
           F(1)=0.0d0
           DO I=2,NRHO
             F(I)=(SN(I)/(Q*RHO(I))-CS(I))*WP(I,1)*VP(I,1)
           END DO
           P=P1*SIMP(NRHO,F,DRHO)/Q
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=P*GX
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=P*GY
           lcount = lcount-1
           VNL(k1,k2,k3,lcount)=P*GZ
        end if

*::::::::::::::::::::::::::::::  s-wave  :::::::::::::::::::::::::::::::
  500   CONTINUE
        if (locp.ne.0) then
          DO I=1,NRHO
            F(I)=SN(I)*WP(I,0)*VP(I,0)
          END DO
          lcount = lcount-1
          VNL(k1,k2,k3,lcount)=P0*SIMP(NRHO,F,DRHO)/Q
        end if

*::::::::::::::::::::::::::::::  local  :::::::::::::::::::::::::::::::
  600   CONTINUE


        if (version.eq.3) then
        DO  I=1,NRHO
          F(I)=RHO(I)*VP(I,locp)*SN(I)
        END DO
        VL(k1,k2,k3)=SIMP(NRHO,F,DRHO)*FORPI/Q-ZV*FORPI*CS(NRHO)/(Q*Q)
        end if
 
        if (version.eq.4) then
        DO I=1,NRHO

          xerf=RHO(I)/rlocal
*         yerf = (1.0d0
*    >           + xerf*(c1 + xerf*(c2
*    >           + xerf*(c3 + xerf*(c4
*    >           + xerf*(c5 + xerf*c6))))))**4
*         yerf = (1.0d0 - 1.0d0/yerf**4)
          yerf = util_erf(xerf)
          F(I)=(RHO(I)*VP(I,locp)+ZV*yerf)*SN(I)
c         F(I)=(RHO(I)*VP(I,locp)+ZV*ERF(RHO(I)/RC(locp)))*SN(I)
        END DO
        VL(k1,k2,k3)=SIMP(NRHO,F,DRHO)*FORPI/Q
        end if


*::::::::::::::::::::: semicore density :::::::::::::::::::::::::::::::
        if (semicore) then
           do i=1,nrho
              f(i) = rho(i)*dsqrt(rho_sc_r(i,1))*sn(i)
           end do
           rho_sc_k(k1,k2,k3,1) = SIMP(nrho,f,drho)*forpi/Q

           do i=1,nrho
             f(i)=(sn(i)/(Q*rho(i))-cs(i))*rho_sc_r(i,2)*rho(i)
           end do
           P = SIMP(nrho,f,drho)*forpi/Q
           rho_sc_k(k1,k2,k3,2)=P*GX
           rho_sc_k(k1,k2,k3,3)=P*GY
           rho_sc_k(k1,k2,k3,4)=P*GZ

        end if
    
  700 CONTINUE

      call D3dB_Vector_SumAll(4*nfft3d,rho_sc_k)
      call D3dB_Vector_SumAll(nfft3d,VL)
      call D3dB_Vector_Sumall(lmmax*nfft3d,VNL)
*:::::::::::::::::::::::::::::::  G=0  ::::::::::::::::::::::::::::::::      

      if (version.eq.3) then
      DO I=1,NRHO
        F(I)=VP(I,locp)*RHO(I)**2
      END DO
      VL(1,1,1)=FORPI*SIMP(NRHO,F,DRHO)+TWOPI*ZV*RHO(NRHO)**2
      end if

      if (version.eq.4) then
      DO I=1,NRHO
        xerf=RHO(I)/rlocal
c       yerf = (1.0d0
c    >         + xerf*(c1 + xerf*(c2
c    >         + xerf*(c3 + xerf*(c4
c    >         + xerf*(c5 + xerf*c6))))))**4
c       yerf = (1.0d0 - 1.0d0/yerf**4)
        yerf = util_erf(xerf)
        F(I)=(VP(I,locp)*RHO(I)+ZV*yerf)*RHO(I)
c       F(I)=(VP(I,locp)*RHO(I)+ZV*ERF(RHO(I)/RC(locp)))*RHO(I)
      END DO
      VL(1,1,1)=FORPI*SIMP(NRHO,F,DRHO)
      end if

*     **** semicore density ****
      if (semicore) then
         do i=1,nrho
            f(i) = dsqrt(rho_sc_r(i,1))*rho(i)**2
         end do
         rho_sc_k(1,1,1,1) = forpi*SIMP(nrho,f,drho)
         rho_sc_k(1,1,1,2) = 0.0d0
         rho_sc_k(1,1,1,3) = 0.0d0
         rho_sc_k(1,1,1,4) = 0.0d0
      end if

      do l=1,lmmax
        vnl(1,1,1,l)=0.0d0
      end do
*     *** only j0 is non-zero at zero ****
      if (locp.ne.0) then
         DO  I=1,NRHO
           F(I)=RHO(I)*WP(I,0)*VP(I,0)
         END DO
         VNL(1,1,1,1)=P0*SIMP(NRHO,F,DRHO)
      end if


      IERR=0
      RETURN
      END

      double precision function simp(n,y,h)
      implicit none
      integer n
      double precision y(n)
      double precision h,s
      integer ne,no
      double precision dsum
      external         dsum

      ne=n/2
      no=ne+1
      S=2.0d0*dsum(no,y(1),2) + 4.0d0*dsum(ne,y(2),2)-y(1)-y(n)
      simp=s*h/3.0d0
      return
      end


