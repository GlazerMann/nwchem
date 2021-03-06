#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if !defined(NWAD_PRINT)
C> \ingroup nwxc
C> @{
C>
C> \file nwxc_c_vs98.F
C> Implementation of the VS98 correlation functional
C>
C> @}
#endif
#endif
C>
C> \ingroup nwxc_priv
C> @{
C>
C> \brief The Voorhis and Scuseria correlation functional
C>
C> The VS98 functional [1,2] is a meta-GGA. This routine implements
C> the correlation component.
C>
C> Due to the form of the meta-GGAs we need to screen on the kinetic
C> energy density to ensure that LDA will be obtained when the kinetic
C> energy density goes to zero [3].
C>
C> ### References ###
C>
C> [1] T van Voorhis, GE Scuseria,
C>     "A novel form for the exchange-correlation energy functional",
C>     J.Chem.Phys. <b>109</b>, 400-410 (1998), DOI:
C>     <a href="http://dx.doi.org/10.1063/1.476577">
C>     10.1063/1.476577</a>.
C>
C> [2] T van Voorhis, GE Scuseria,
C>     Erratum: "A novel form for the exchange-correlation energy
C>     functional",
C>     J.Chem.Phys. <b>129</b>, 219901-219901 (2008), DOI:
C>     <a href="http://dx.doi.org/10.1063/1.3005348">
C>     10.1063/1.3005348</a>.
C>
C> [3] J. Gr&auml;fenstein, D. Izotov, D. Cremer,
C>     "Avoiding singularity problems associated with meta-GGA exchange
C>     and correlation functionals containing the kinetic energy
C>     density", J. Chem. Phys. <b>127</b>, 214103 (2007), DOI:
C>     <a href="http://dx.doi.org/10.1063/1.2800011">
C>     10.1063/1.2800011</a>.
C>
c    VSXC correlation functional          
c           META GGA
C         utilizes ingredients:
c                              rho   -  density
c                              delrho - gradient of density
c                              tau (tauN)- K.S kinetic energy density
c                              ijzy - 1  VS98
c                              ijzy - 2  M06-L  
c                              ijzy - 3  M06-HF
c                              ijzy - 4  M06
c                              ijzy - 5  M06-2X
c
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
      Subroutine nwxc_c_vs98_p(param, tol_rho, ipol, nq, wght, rho,
     &                         rgamma, tau, func)
#else
      Subroutine nwxc_c_vs98(param, tol_rho, ipol, nq, wght, rho,
     &                       rgamma, tau, func)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
      Subroutine nwxc_c_vs98_d2(param, tol_rho, ipol, nq, wght, rho,
     &                          rgamma, tau, func)
#else
      Subroutine nwxc_c_vs98_d3(param, tol_rho, ipol, nq, wght, rho,
     &                          rgamma, tau, func)
#endif
c
c$Id$
c
c  Reference
c   [a] T. V. Voorhis and G. E. Scuseria, J. Chem. Phys. 109, 400 (1998). 
c   [b] Y. Zhao and D. G. Truhlar, J. Chem. Phys. 125, 194101 (2006).
 
c
#include "nwad.fh"
c
      implicit none
c
#include "intf_nwxc_c_lsda.fh"
#include "intf_nwxc_vs98ss.fh"
c
#include "nwxc_param.fh"
c
c     Input and other parameters
c
#if defined(NWAD_PRINT)
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
      type(nwad_dble)::param(*) !< [Input] Parameters of functional (table 1)
      type(nwad_dble)::r7, r8, r9, r10, r11, r12
      type(nwad_dble)::r13, r14, r15, r16, r17, r18
#else
      double precision param(*) !< [Input] Parameters of functional (table 1)
      double precision r7, r8, r9, r10, r11, r12
      double precision r13, r14, r15, r16, r17, r18
#endif
#else
      double precision param(*) !< [Input] Parameters of functional (table 1)
                                !< - param(1): \f$ a_{\sigma\sigma'} \f$
                                !< - param(2): \f$ b_{\sigma\sigma'} \f$
                                !< - param(3): \f$ c_{\sigma\sigma'} \f$
                                !< - param(4): \f$ d_{\sigma\sigma'} \f$
                                !< - param(5): \f$ e_{\sigma\sigma'} \f$
                                !< - param(6): \f$ f_{\sigma\sigma'} \f$
                                !< - param(7): \f$ a_{\sigma\sigma} \f$
                                !< - param(8): \f$ b_{\sigma\sigma} \f$
                                !< - param(9): \f$ c_{\sigma\sigma} \f$
                                !< - param(10): \f$ d_{\sigma\sigma} \f$
                                !< - param(11): \f$ e_{\sigma\sigma} \f$
                                !< - param(12): \f$ f_{\sigma\sigma} \f$
      double precision r7, r8, r9, r10, r11, r12
      double precision r13, r14, r15, r16, r17, r18
#endif
      double precision tol_rho !< [Input] The lower limit on the density
      integer nq               !< [Input] The number of points
      integer ipol             !< [Input] The number of spin channels
      double precision wght    !< [Input] The weight of the functional
c
c     Charge Density 
c
      type(nwad_dble)::rho(nq,*) !< [Input] The density
c
c     Charge Density Gradient Norm
c
      type(nwad_dble)::rgamma(nq,*) !< [Input] The density gradient norm
c
c     Kinetic Energy Density
c
      type(nwad_dble)::tau(nq,*) !< [Input] The kinetic energy density
c
c     Functional values
c
      type(nwad_dble)::func(*) !< [Output] The functional value
c
c     Sampling Matrices for the XC Potential
c
c     double precision Amat(nq,*) !< [Output] Derivative wrt density
c     double precision Cmat(nq,*) !< [Output] Derivative wrt rgamma
c     double precision Mmat(nq,*) !< [Output] Derivative wrt tau
c
c     Threshold parameters
c
      double precision DTol,F1, F2, F3, F4, gab, cf 
      Data F1/1.0d0/,F2/2.0d0/,
     & F3/3.0d0/,F4/4.0d0/,gab/0.00304966d0/,
     & cf/9.115599720d0/ 
c
c     Local
c 
      integer n
      double precision tauN

c    call to the vs98css subroutine
      type(nwad_dble)::PA,GAA,TA,FA,EUA,ZA,ChiA
      double precision FPA,FGA,FTA,EUEGA,EUPA,ChiAP,ChiAG,
     &                 ZAP,ZAT
      type(nwad_dble)::PB,GBB,TB,FB,EUB,ZB,ChiB
      double precision FPB,FGB,FTB,EUEGB,EUPB,ChiBP,ChiBG,
     &                 ZBP,ZBT
c
      type(nwad_dble)::RS,Zeta,gcab,P,PotLC,EUEG,ZAB
      double precision Pi, F43, F13, Pi34, F6,
     &RSP,dZdA,dZdB,dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ
      type(nwad_dble)::XAB, kab, xk, zk
      double precision dgdx,dgdz,dgdPA,dgdGA,dgdTA,dgdPB,dgdGB,dgdTB
      double precision EUEGPA,EUEGPB

      
c
c     ======> BOTH SPIN-RESTRICETED AND UNRESTRICTED <======
c
c     DTol=1.0d-7
      dtol=tol_rho
C     Parameters for VS98 / M06-L / M06-HF / M06 / M06-2X
      r7=   param(1)
      r8=   param(2)
      r9=   param(3)
      r10=  param(4)
      r11=  param(5)
      r12=  param(6)
      r13=  param(7)
      r14=  param(8)
      r15=  param(9)
      r16=  param(10)
      r17=  param(11)
      r18=  param(12)
c
      Pi = F4*ATan(F1)
      F6=6.0d0
      F43 = F4 / F3
      Pi34 = F3 / (F4*Pi)
      F13 = F1 / F3
c
      do 20 n = 1, nq
        if (ipol.eq.1) then
          if (rho(n,R_A).lt.DTol) goto 20
        else
          if (rho(n,R_A)+rho(n,R_B).lt.DTol) goto 20
        endif
        if (ipol.eq.1) then
c
c         get the density, gradient, and tau for the alpha spin
c         from the total 
c
          PA   = rho(n,R_A)/F2
          PB   = 0.0d0
          EUA  = 0.0d0
          ChiA = 0.0d0
          EUB  = 0.0d0
          ChiB = 0.0d0
          GAA  = rgamma(n,G_AA)/4.0d0
c         In the bc95css subroutine, we use 2*TA as the tau, so we do
c         not divide the tau by 2 here

          TA = tau(n,T_A) 
          if(ta.lt.dtol) goto 20
                  
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
          Call nwxc_vs98ss_p(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                     ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                     r13,r14,r15,r16,r17,r18)
#else
          Call nwxc_vs98ss(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                     ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                     r13,r14,r15,r16,r17,r18)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
          Call nwxc_vs98ss_d2(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                     ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                     r13,r14,r15,r16,r17,r18)
#else
          Call nwxc_vs98ss_d3(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                     ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                     r13,r14,r15,r16,r17,r18)
#endif
          PB = PA
          GBB = GAA
          TB = TA
          FB = FA
          FPB = FPA
          FGB = FGA
          FTB = FTA
          EUB = EUA
          ZB = ZA
          ChiB = ChiA
          EUPB = EUPA
          ChiBP = ChiAP
          ChiBG = ChiAG
          ZBP = ZAP
          ZBT = ZAT
 
          func(n)        = func(n)        + 2.0d0*FA*wght
c         Amat(n,D1_RA)  = Amat(n,D1_RA)  + FPA*wght
c         Cmat(n,D1_GAA) = Cmat(n,D1_GAA) + FGA*wght
c         Mmat(n,D1_TA)  = Mmat(n,D1_TA)  + FTA*wght
 
 
c UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUnrestricted
      else  ! ipol=2
c
c        ======> SPIN-UNRESTRICTED <======
c
c
c       alpha
c
         
         PA   = 0.0d0
         GAA  = 0.0d0
         TA   = 0.0d0
         EUA  = 0.0d0
         ChiA = 0.0d0
         ZA   = 0.0d0
         if (rho(n,R_A).le.0.5d0*DTol) go to 25
         PA  = rho(n,R_A)
c
c        In the bc95css subroutine, we use 2*TA as the tau 
c
         if (tau(n,T_A).le.0.5d0*DTol) go to 25
         GAA = rgamma(n,G_AA)
         TA = tau(n,T_A)*2.0d0

#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
         Call nwxc_vs98ss_p(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                    ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                    r13,r14,r15,r16,r17,r18)
#else
         Call nwxc_vs98ss(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                    ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                    r13,r14,r15,r16,r17,r18)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
         Call nwxc_vs98ss_d2(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                    ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                    r13,r14,r15,r16,r17,r18)
#else
         Call nwxc_vs98ss_d3(tol_rho,PA,GAA,TA,FA,FPA,FGA,FTA,EUA,ZA,
     &                    ChiA,EUPA,ChiAP,ChiAG,ZAP,ZAT,
     &                    r13,r14,r15,r16,r17,r18)
#endif
         func(n)        = func(n)        + FA*wght
c        Amat(n,D1_RA)  = Amat(n,D1_RA)  + FPA*wght
c        Cmat(n,D1_GAA) = Cmat(n,D1_GAA) + FGA*wght
c        2*0.5=1.0 for Mmat
c        Mmat(n,D1_TA)  = Mmat(n,D1_TA)  + FTA*wght

c
c        In the vs98ss subroutine, we use 2*TA as the tau, 
c
c
c       Beta 
c
 25      continue
         PB   = 0.0d0
         GBB  = 0.0d0
         TB   = 0.0d0
         EUB  = 0.0d0
         ChiB = 0.0d0
         ZB   = 0.0d0

         if(rho(n,R_B).le.0.5d0*DTol) go to 30

         PB = rho(n,R_B)

         if(tau(n,T_B).le.0.5d0*DTol) go to 30
         GBB = rgamma(n,G_BB)
         TB = tau(n,T_B)*2.0d0

#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
         Call nwxc_vs98ss_p(tol_rho,PB,GBB,TB,FB,FPB,FGB,FTB,EUB,ZB,
     &                    ChiB,EUPB,ChiBP,ChiBG,ZBP,ZBT,
     &                    r13,r14,r15,r16,r17,r18)
#else
         Call nwxc_vs98ss(tol_rho,PB,GBB,TB,FB,FPB,FGB,FTB,EUB,ZB,
     &                    ChiB,EUPB,ChiBP,ChiBG,ZBP,ZBT,
     &                    r13,r14,r15,r16,r17,r18)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
         Call nwxc_vs98ss_d2(tol_rho,PB,GBB,TB,FB,FPB,FGB,FTB,EUB,ZB,
     &                    ChiB,EUPB,ChiBP,ChiBG,ZBP,ZBT,
     &                    r13,r14,r15,r16,r17,r18)
#else
         Call nwxc_vs98ss_d3(tol_rho,PB,GBB,TB,FB,FPB,FGB,FTB,EUB,ZB,
     &                    ChiB,EUPB,ChiBP,ChiBG,ZBP,ZBT,
     &                    r13,r14,r15,r16,r17,r18)
#endif
         func(n)        = func(n)        + FB*wght
c        Amat(n,D1_RB)  = Amat(n,D1_RB)  + FPB*wght
c        Cmat(n,D1_GBB) = Cmat(n,D1_GBB) + FGB*wght
c        Mmat(n,D1_TB)  = Mmat(n,D1_TB)  + FTB*wght
         
#if 0
      write (0,'(A,3F20.6)') "BAmat Cmat Mmat",FPB,FGB,FTB
#endif
      endif
 30   continue
      P = PA + PB
      If(PA.gt.DTol.or.PB.gt.DTol) then
          RS = (Pi34/P) ** F13 
c         RSP = -RS/(F3*P)
          Zeta = (PA-PB)/P
c         dZdA = (F1-Zeta)/P
c         dZdB = (-F1-Zeta)/P
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
          Call nwxc_c_lsda_p(tol_rho,RS,Zeta,PotLC,
     &               dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#else
          Call nwxc_c_lsda(tol_rho,RS,Zeta,PotLC,
     &               dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
          Call nwxc_c_lsda_d2(tol_rho,RS,Zeta,PotLC,
     &               dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#else
          Call nwxc_c_lsda_d3(tol_rho,RS,Zeta,PotLC,
     &               dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#endif
          EUEG = P*PotLC - EUA - EUB
          ZAB = ZA + ZB
          XAB = ChiA+ChiB
          kab = F1 + gab*(XAB+ZAB)
          xk = XAB/kab
          zk = ZAB/kab
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
          call nwxc_gvt4_p(gcab,dgdx,dgdz,xk,zk,kab,gab,gab,
     &                   r7,r8,r9,r10,r11,r12)
#else
          call nwxc_gvt4(gcab,dgdx,dgdz,xk,zk,kab,gab,gab,
     &                   r7,r8,r9,r10,r11,r12)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
          call nwxc_gvt4_d2(gcab,dgdx,dgdz,xk,zk,kab,gab,gab,
     &                   r7,r8,r9,r10,r11,r12)
#else
          call nwxc_gvt4_d3(gcab,dgdx,dgdz,xk,zk,kab,gab,gab,
     &                   r7,r8,r9,r10,r11,r12)
#endif
          func(n) = func(n) + gcab*EUEG*wght
c         dgdPA = dgdx*ChiAP + dgdz*ZAP
c         dgdGA = dgdx*ChiAG
c         dgdTA = dgdz*ZAT
c         dgdPB = dgdx*ChiBP + dgdz*ZBP
c         dgdGB = dgdx*ChiBG
c         dgdTB = dgdz*ZBT
c         EUEGPA = PotLC + P*dLdS*RSP + P*dLdZ*dZdA - EUPA
c         EUEGPB = PotLC + P*dLdS*RSP + P*dLdZ*dZdB - EUPB
c         if (ipol.eq.1) then 
c           Amat(n,D1_RA)  = Amat(n,D1_RA) 
c    &                     + (EUEGPA*gcab   + EUEG*dgdPA)*wght
c           Cmat(n,D1_GAA) = Cmat(n,D1_GAA) + EUEG*dgdGA*wght
c           Mmat(n,D1_TA)  = Mmat(n,D1_TA)  + EUEG*dgdTA*wght
c         else
c           Amat(n,D1_RA)  = Amat(n,D1_RA)
c    &                     + (EUEGPA*gcab   + EUEG*dgdPA)*wght
c           Amat(n,D1_RB)  = Amat(n,D1_RB)
c    &                     + (EUEGPB*gcab   + EUEG*dgdPB)*wght
c           Cmat(n,D1_GAA) = Cmat(n,D1_GAA) + EUEG*dgdGA*wght
c           Cmat(n,D1_GBB) = Cmat(n,D1_GBB) + EUEG*dgdGB*wght
c           Mmat(n,D1_TA)  = Mmat(n,D1_TA)  + EUEG*dgdTA*wght
c           Mmat(n,D1_TB)  = Mmat(n,D1_TB)  + EUEG*dgdTB*wght
c         endif
      endIf
c      write (*,*) "Amat(n,1),Cmat(n,1),Mmat(n,1)",Amat(n,1),Cmat(n,1)
c     & ,Mmat(n,1),ipol
c      stop
20    continue
      end
C>
C> \brief Compute the same-spin part of the VS98 correlation functional
C>
C> This routine evaluates the same-spin part of the VS98 functional for
C> 1 grid point and 1 spin-case.
C>
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
      Subroutine nwxc_vs98ss_p(tol_rho,PX,GX,TX,F,FP,FG,FT,EUEG,Z,Chi,
     +                         EUEGP,ChiP,ChiG,ZP,ZT,
     +                         r13,r14,r15,r16,r17,r18)
#else
      Subroutine nwxc_vs98ss(tol_rho,PX,GX,TX,F,FP,FG,FT,EUEG,Z,Chi,
     +                       EUEGP,ChiP,ChiG,ZP,ZT,
     +                       r13,r14,r15,r16,r17,r18)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
      Subroutine nwxc_vs98ss_d2(tol_rho,PX,GX,TX,F,FP,FG,FT,EUEG,Z,Chi,
     +                       EUEGP,ChiP,ChiG,ZP,ZT,
     +                       r13,r14,r15,r16,r17,r18)
#else
      Subroutine nwxc_vs98ss_d3(tol_rho,PX,GX,TX,F,FP,FG,FT,EUEG,Z,Chi,
     +                       EUEGP,ChiP,ChiG,ZP,ZT,
     +                       r13,r14,r15,r16,r17,r18)
#endif
#include "nwad.fh"
      Implicit none
c
#include "intf_nwxc_c_lsda.fh"
#include "intf_nwxc_gvt4.fh"
C
C     Compute the same-spin part of the vs98 correlation functional for one grid
C     point and one spin-case.
C

      double precision tol_rho
#if defined(NWAD_PRINT)
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
      type(nwad_dble)::r13, r14, r15, r16, r17, r18
#else
      double precision r13, r14, r15, r16, r17, r18
#endif
#else
      double precision r13, r14, r15, r16, r17, r18
#endif
      type(nwad_dble)::PX, GX, TX, F, EUEG, Chi, RS, Z, P, E, PotLC
      type(nwad_dble)::rhoo, rho53, rho83
      type(nwad_dble)::kc,xk,zk,d,gc, Zeta
      double precision FP, FG, FT, DTol, ZP, ZT
      double precision EUEGP, ChiP, ChiG, cf, gcc
      double precision Zero, Pt25, F1, F2, F3, F4, F5, F6, F8, F11
      double precision Pi, Pi34, F13, F23, F43, F53, F83, F113
      double precision RSP, DX, DZ, dgdP, dgdG, dgdT
      double precision DP, DG, DT
      double precision F4o3, dgdx, dgdz
      double precision d2LdSS, d2LdSZ, d2LdZZ, dLdS, dLdZ

      Data Zero/0.0d0/, Pt25/0.25d0/, F1/1.0d0/, F2/2.0d0/, F3/3.0d0/,
     $  F4/4.0d0/, F5/5.0d0/, F6/6.0d0/, F8/8.0d0/, F11/11.0d0/,
     $  gcc/0.00515088d0/,cf/9.115599720d0/
 
 
      F4o3 = 4.0d0/3.0d0
      dtol=tol_rho
      If(PX.le.DTol) then
        EUEG = Zero
        Chi = Zero
        EUEGP = Zero
        ChiP = Zero
        ChiG = Zero
        PX = Zero
        GX = Zero 
        TX = Zero
        F  = Zero
        FP = Zero
        FG = Zero
        FT = Zero
        Z  = Zero
        ZP = Zero
        ZT = Zero
      else
        Pi = F4*ATan(F1)
        Pi34 = F3 / (F4*Pi)
        F13 = F1 / F3
        F23 = F2 / F3
        F43 = F2 * F23
        F53 = F5 / F3
        F83 = F8 / F3
        F113 = F11 / F3
        rhoo = PX 
c       rrho = 1.0d0/rhoo
c       rho43 = rhoo**F4o3
c       rho13 = rho43*rrho
        rho53 = rhoo**F53
        rho83 = rho53*rhoo
        
        RS = (Pi34/PX) ** F13
        Zeta = F1
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
        Call nwxc_c_lsda_p(tol_rho,
     A       RS,Zeta,PotLC,dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#else
        Call nwxc_c_lsda(tol_rho,
     A       RS,Zeta,PotLC,dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
        Call nwxc_c_lsda_d2(tol_rho,
     A       RS,Zeta,PotLC,dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#else
        Call nwxc_c_lsda_d3(tol_rho,
     A       RS,Zeta,PotLC,dLdS,dLdZ,d2LdSS,d2LdSZ,d2LdZZ)
#endif
        EUEG = PX*PotLC
        Chi = GX/rho83
        Z = (TX/rho53) - cf
        kc = F1 + gcc*(Chi + Z)
        xk = Chi/kc
        zk = Z/kc
        D = F1 - Chi/(F4*(Z + cf)) 
#if !defined(SECOND_DERIV) && !defined(THIRD_DERIV)
#if defined(NWAD_PRINT)
        call nwxc_gvt4_p(gc,dgdx,dgdz,xk,zk,kc,gcc,gcc,
     &                 r13,r14,r15,r16,r17,r18)
#else
        call nwxc_gvt4(gc,dgdx,dgdz,xk,zk,kc,gcc,gcc,
     &                 r13,r14,r15,r16,r17,r18)
#endif
#elif defined(SECOND_DERIV) && !defined(THIRD_DERIV)
        call nwxc_gvt4_d2(gc,dgdx,dgdz,xk,zk,kc,gcc,gcc,
     &                 r13,r14,r15,r16,r17,r18)
#else
        call nwxc_gvt4_d3(gc,dgdx,dgdz,xk,zk,kc,gcc,gcc,
     &                 r13,r14,r15,r16,r17,r18)
#endif
        E = D*EUEG*gc
c         write (*,*) "Chi, Z, gc", CHi, Z, gc
        F = E 
c
c       RSP = -RS/(F3*Px)
c       ChiG = F1/PX**F83
c       ChiP = -F83*Chi/PX
c       ZP = -F53 * TX/rho83
c       ZT =  F1/rho53
c       DZ = Chi/(F4*(Z + cf)*(Z + cf)) 
c       DX = -F1/(F4*(Z + cf))
c       DP = DZ*ZP + DX*ChiP
c       DG = DX*ChiG
c       DT = DZ*ZT
c       dgdP = dgdx*ChiP + dgdz*ZP
c       dgdG = dgdx*ChiG 
c       dgdT = dgdz*ZT
c       EUEGP = PotLC + PX*dLdS*RSP
c       FP = DP*EUEG*gc + D*EUEGP*gc + D*EUEG*dgdP
c       FG = DG*EUEG*gc + D*EUEG*dgdG
c       FT = DT*EUEG*gc + D*EUEG*dgdT
       Endif
       Return
       End
#ifndef NWAD_PRINT
#define NWAD_PRINT
c
c     Compile source again for Maxima
c
#include "nwxc_c_vs98.F"
#endif
#ifndef SECOND_DERIV
#define SECOND_DERIV
c
c     Compile source again for the 2nd derivative case
c
#include "nwxc_c_vs98.F"
#endif
#ifndef THIRD_DERIV
#define THIRD_DERIV
c
c     Compile source again for the 3rd derivative case
c
#include "nwxc_c_vs98.F"
#endif
#undef NWAD_PRINT
C> @}
