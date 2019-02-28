c234567
c
c20111127[MHP]: Main diff. of v2 regarding to first one is fixing an apparent major bug (entering lon/lat in degrees, instead of in radians, in subroutine sla_rdplan, but without practical consecuences for all the applications done so far with this program and associated subroutine splanets (whith doesn't matter about topocentric or geocentric Sun apparent coordinates).
c
      program planets_v2
      implicit double precision (a-h,o-z)
      character pnames*7,planet*7
      dimension pnames(10)
      data pnames / 'Mercury','Venus','Moon','Mars','Jupiter','Saturn',
     1              'Uranus','Neptune','Pluto','Sun' /
c
c Calling to starlink 'rdplan' subroutine:
*  Approximate topocentric apparent RA,Dec of a planet, and its
*  angular diameter.
*
*  Given:
*     DATE        d       MJD of observation (JD - 2400000.5)
*     NP          i       planet: 1 = Mercury
*                                 2 = Venus
*                                 3 = Moon
*                                 4 = Mars
*                                 5 = Jupiter
*                                 6 = Saturn
*                                 7 = Uranus
*                                 8 = Neptune
*                                 9 = Pluto
*                              else = Sun
*     ELONG,PHI   d       observer's east longitude and geodetic
*                                               latitude (radians)
*
*  Returned:
*     RA,DEC      d        RA, Dec (topocentric apparent, radians)
*     DIAM        d        angular diameter (equatorial, radians)
c234567
      open(1,file='planets_v2.log')
      d2r=dacos(-1.d0)/180.d0
      read(*,*)iyear,imonth,idd,thours,xlon,xlat,planet 
c      write(1,*)'iyear,imonth,idd,thours,xlon,xlat,planet=',
c     1           iyear,imonth,idd,thours,xlon,xlat,planet
      xlonr=xlon*d2r
      xlatr=xlat*d2r
      do i=1,10
       if(planet.eq.pnames(i))then
        ip=i
        goto 20
       endif
      enddo
      write(1,*)'ERROR: not valid planet name; it must be one of:'
      do i=1,10
       write(1,*)pnames(i)
      enddo
      stop 'ERROR: not valid planet name'
  20  continue
c      write(1,*)'iyear,imonth,idd=',iyear,imonth,idd 
      call sla_caldj(iyear,imonth,idd,djm,j)
c      write(1,*)'iyear,imonth,idd,djm,j=',iyear,imonth,idd,djm,j 
      if(j.ne.0)then
       write(1,*)'ERROR: in date format (j=',j,')'
       stop 'ERROR: in date format'
      endif
      djmt=djm+thours/24.d0
c      write(1,*)'djmt,ip,xlon,xlat=',djmt,ip,xlon,xlat
c
c      call sla_rdplan(djmt,ip,xlon,xlat,ra,dec,diam)
      call sla_rdplan(djmt,ip,xlonr,xlatr,ra,dec,diam)
c
      write(*,*)ra/d2r,dec/d2r,diam/d2r
      stop
      end

      SUBROUTINE sla_CALDJ (IY, IM, ID, DJM, J)
*+
*     - - - - - -
*      C A L D J
*     - - - - - -
*
*  Gregorian Calendar to Modified Julian Date
*
*  (Includes century default feature:  use sla_CLDJ for years
*   before 100AD.)
*
*  Given:
*     IY,IM,ID     int    year, month, day in Gregorian calendar
*
*  Returned:
*     DJM          dp     modified Julian Date (JD-2400000.5) for 0 hrs
*     J            int    status:
*                           0 = OK
*                           1 = bad year   (MJD not computed)
*                           2 = bad month  (MJD not computed)
*                           3 = bad day    (MJD computed)
*
*  Acceptable years are 00-49, interpreted as 2000-2049,
*                       50-99,     "       "  1950-1999,
*                       100 upwards, interpreted literally.
*
*  Called:  sla_CLDJ
*
*  P.T.Wallace   Starlink   November 1985
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      INTEGER IY,IM,ID
      DOUBLE PRECISION DJM
      INTEGER J

      INTEGER NY




*  Default century if appropriate
      IF (IY.GE.0.AND.IY.LE.49) THEN
         NY=IY+2000
      ELSE IF (IY.GE.50.AND.IY.LE.99) THEN
         NY=IY+1900
      ELSE
         NY=IY
      END IF

*  Modified Julian Date
      CALL sla_CLDJ(NY,IM,ID,DJM,J)

      END

      SUBROUTINE sla_CLDJ (IY, IM, ID, DJM, J)
*+
*     - - - - -
*      C L D J
*     - - - - -
*
*  Gregorian Calendar to Modified Julian Date
*
*  Given:
*     IY,IM,ID     int    year, month, day in Gregorian calendar
*
*  Returned:
*     DJM          dp     modified Julian Date (JD-2400000.5) for 0 hrs
*     J            int    status:
*                           0 = OK
*                           1 = bad year   (MJD not computed)
*                           2 = bad month  (MJD not computed)
*                           3 = bad day    (MJD computed)
*
*  The year must be -4699 (i.e. 4700BC) or later.
*
*  The algorithm is derived from that of Hatcher 1984
*  (QJRAS 25, 53-55).
*
*  P.T.Wallace   Starlink   December 1985
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      INTEGER IY,IM,ID
      DOUBLE PRECISION DJM
      INTEGER J

*  Month lengths in days
      INTEGER MTAB(12)
      DATA MTAB/31,28,31,30,31,30,31,31,30,31,30,31/



*  Preset status
      J=0

*  Validate year
      IF (IY.LT.-4699) THEN
         J=1
      ELSE

*     Validate month
         IF (IM.GE.1.AND.IM.LE.12) THEN

*        Allow for leap year
            IF (MOD(IY,4).EQ.0) THEN
               MTAB(2)=29
            ELSE
               MTAB(2)=28
            END IF
            IF (MOD(IY,100).EQ.0.AND.MOD(IY,400).NE.0)
     :         MTAB(2)=28

*        Validate day
            IF (ID.LT.1.OR.ID.GT.MTAB(IM)) J=3

*        Modified Julian Date
               DJM=DBLE((1461*(IY-(12-IM)/10+4712))/4
     :                  +(306*MOD(IM+9,12)+5)/10
     :                  -(3*((IY-(12-IM)/10+4900)/100))/4
     :                  +ID-2399904)

*        Bad month
         ELSE
            J=2
         END IF

      END IF

      END


      SUBROUTINE sla_RDPLAN (DATE, NP, ELONG, PHI, RA, DEC, DIAM)
*+
*     - - - - - - -
*      R D P L A N
*     - - - - - - -
*
*  Approximate topocentric apparent RA,Dec of a planet, and its
*  angular diameter.
*
*  Given:
*     DATE        d       MJD of observation (JD - 2400000.5)
*     NP          i       planet: 1 = Mercury
*                                 2 = Venus
*                                 3 = Moon
*                                 4 = Mars
*                                 5 = Jupiter
*                                 6 = Saturn
*                                 7 = Uranus
*                                 8 = Neptune
*                                 9 = Pluto
*                              else = Sun
*     ELONG,PHI   d       observer's east longitude and geodetic
*                                               latitude (radians)
*
*  Returned:
*     RA,DEC      d        RA, Dec (topocentric apparent, radians)
*     DIAM        d        angular diameter (equatorial, radians)
*
*  Notes:
*
*  1  The date is in a dynamical timescale (TDB, formerly ET) and is
*     in the form of a Modified Julian Date (JD-2400000.5).  For all
*     practical purposes, TT can be used instead of TDB, and for many
*     applications UT will do (except for the Moon).
*
*  2  The longitude and latitude allow correction for geocentric
*     parallax.  This is a major effect for the Moon, but in the
*     context of the limited accuracy of the present routine its
*     effect on planetary positions is small (negligible for the
*     outer planets).  Geocentric positions can be generated by
*     appropriate use of the routines sla_DMOON and sla_PLANET.
*
*  3  The direction accuracy (arcsec, 1000-3000AD) is of order:
*
*            Sun              5
*            Mercury          2
*            Venus           10
*            Moon            30
*            Mars            50
*            Jupiter         90
*            Saturn          90
*            Uranus          90
*            Neptune         10
*            Pluto            1   (1885-2099AD only)
*
*     The angular diameter accuracy is about 0.4% for the Moon,
*     and 0.01% or better for the Sun and planets.
*
*  See the sla_PLANET routine for references.
*
*  Called: sla_GMST, sla_DT, sla_EPJ, sla_DMOON, sla_PVOBS, sla_PRENUT,
*          sla_PLANET, sla_DMXV, sla_DCC2S, sla_DRANRM
*
*  P.T.Wallace   Starlink   26 May 1997
*
*  Copyright (C) 1997 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER NP
      DOUBLE PRECISION ELONG,PHI,RA,DEC,DIAM

*  AU in km
      DOUBLE PRECISION AUKM
      PARAMETER (AUKM=1.49597870D8)

*  Light time for unit distance (sec)
      DOUBLE PRECISION TAU
      PARAMETER (TAU=499.004782D0)

      INTEGER IP,J,I
      DOUBLE PRECISION EQRAU(0:9),STL,VGM(6),V(6),RMAT(3,3),
     :                 VSE(6),VSG(6),VSP(6),VGO(6),DX,DY,DZ,R,TL
      DOUBLE PRECISION sla_GMST,sla_DT,sla_EPJ,sla_DRANRM

*  Equatorial radii (km)
      DATA EQRAU / 696000D0,2439.7D0,6051.9D0,1738D0,3397D0,71492D0,
     :             60268D0,25559D0,24764D0,1151D0 /



*  Classify NP
      IP=NP
      IF (IP.LT.0.OR.IP.GT.9) IP=0

*  Approximate local ST
      STL=sla_GMST(DATE-sla_DT(sla_EPJ(DATE))/86400D0)+ELONG

*  Geocentre to Moon (mean of date)
      CALL sla_DMOON(DATE,V)

*  Nutation to true of date
      CALL sla_NUT(DATE,RMAT)
      CALL sla_DMXV(RMAT,V,VGM)
      CALL sla_DMXV(RMAT,V(4),VGM(4))

*  Moon?
      IF (IP.EQ.3) THEN

*     Yes: geocentre to Moon (true of date)
         DO I=1,6
            V(I)=VGM(I)
         END DO
      ELSE

*     No: precession/nutation matrix, J2000 to date
         CALL sla_PRENUT(2000D0,DATE,RMAT)

*     Sun to Earth-Moon Barycentre (J2000)
         CALL sla_PLANET(DATE,3,V,J)

*     Precession and nutation to date
         CALL sla_DMXV(RMAT,V,VSE)
         CALL sla_DMXV(RMAT,V(4),VSE(4))

*     Sun to geocentre (true of date)
         DO I=1,6
            VSG(I)=VSE(I)-0.012150581D0*VGM(I)
         END DO

*     Sun?
         IF (IP.EQ.0) THEN

*        Yes: geocentre to Sun
            DO I=1,6
               V(I)=-VSG(I)
            END DO
         ELSE

*        No: Sun to Planet (J2000)
            CALL sla_PLANET(DATE,IP,V,J)

*        Precession and nutation to date
            CALL sla_DMXV(RMAT,V,VSP)
            CALL sla_DMXV(RMAT,V(4),VSP(4))

*        Geocentre to planet
            DO I=1,6
               V(I)=VSP(I)-VSG(I)
            END DO
         END IF
      END IF

*  Refer to origin at the observer
      CALL sla_PVOBS(PHI,0D0,STL,VGO)
      DO I=1,6
         V(I)=V(I)-VGO(I)
      END DO

*  Geometric distance (AU)
      DX=V(1)
      DY=V(2)
      DZ=V(3)
      R=SQRT(DX*DX+DY*DY+DZ*DZ)

*  Light time (sec)
      TL=TAU*R

*  Correct position for planetary aberration
      DO I=1,3
         V(I)=V(I)-TL*V(I+3)
      END DO

*  To RA,Dec
      CALL sla_DCC2S(V,RA,DEC)
      RA=sla_DRANRM(RA)

*  Angular diameter (radians)
      DIAM=2D0*ASIN(EQRAU(IP)/(R*AUKM))

      END

      DOUBLE PRECISION FUNCTION sla_GMST (UT1)
*+
*     - - - - -
*      G M S T
*     - - - - -
*
*  Conversion from universal time to sidereal time (double precision)
*
*  Given:
*    UT1    dp     universal time (strictly UT1) expressed as
*                  modified Julian Date (JD-2400000.5)
*
*  The result is the Greenwich mean sidereal time (double
*  precision, radians).
*
*  The IAU 1982 expression (see page S15 of 1984 Astronomical
*  Almanac) is used, but rearranged to reduce rounding errors.
*  This expression is always described as giving the GMST at
*  0 hours UT.  In fact, it gives the difference between the
*  GMST and the UT, which happens to equal the GMST (modulo
*  24 hours) at 0 hours UT each day.  In this routine, the
*  entire UT is used directly as the argument for the
*  standard formula, and the fractional part of the UT is
*  added separately;  note that the factor 1.0027379... does
*  not appear.
*
*  See also the routine sla_GMSTA, which delivers better numerical
*  precision by accepting the UT date and time as separate arguments.
*
*  Called:  sla_DRANRM
*
*  P.T.Wallace   Starlink   14 September 1995
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION UT1

      DOUBLE PRECISION sla_DRANRM

      DOUBLE PRECISION D2PI,S2R
      PARAMETER (D2PI=6.283185307179586476925286766559D0,
     :           S2R=7.272205216643039903848711535369D-5)

      DOUBLE PRECISION TU



*  Julian centuries from fundamental epoch J2000 to this UT
      TU=(UT1-51544.5D0)/36525D0

*  GMST at this UT
      sla_GMST=sla_DRANRM(MOD(UT1,1D0)*D2PI+
     :                    (24110.54841D0+
     :                    (8640184.812866D0+
     :                    (0.093104D0-6.2D-6*TU)*TU)*TU)*S2R)

      END

      DOUBLE PRECISION FUNCTION sla_DT (EPOCH)
*+
*     - - -
*      D T
*     - - -
*
*  Estimate the offset between dynamical time and Universal Time
*  for a given historical epoch.
*
*  Given:
*     EPOCH       d        (Julian) epoch (e.g. 1850D0)
*
*  The result is a rough estimate of ET-UT (after 1984, TT-UT) at
*  the given epoch, in seconds.
*
*  Notes:
*
*  1  Depending on the epoch, one of three parabolic approximations
*     is used:
*
*      before 979    Stephenson & Morrison's 390 BC to AD 948 model
*      979 to 1708   Stephenson & Morrison's 948 to 1600 model
*      after 1708    McCarthy & Babcock's post-1650 model
*
*     The breakpoints are chosen to ensure continuity:  they occur
*     at places where the adjacent models give the same answer as
*     each other.
*
*  2  The accuracy is modest, with errors of up to 20 sec during
*     the interval since 1650, rising to perhaps 30 min by 1000 BC.
*     Comparatively accurate values from AD 1600 are tabulated in
*     the Astronomical Almanac (see section K8 of the 1995 AA).
*
*  3  The use of double-precision for both argument and result is
*     purely for compatibility with other SLALIB time routines.
*
*  4  The models used are based on a lunar tidal acceleration value
*     of -26.00 arcsec per century.
*
*  Reference:  Explanatory Supplement to the Astronomical Almanac,
*              ed P.K.Seidelmann, University Science Books (1992),
*              section 2.553, p83.  This contains references to
*              the Stephenson & Morrison and McCarthy & Babcock
*              papers.
*
*  P.T.Wallace   Starlink   1 March 1995
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION EPOCH
      DOUBLE PRECISION T,W,S


*  Centuries since 1800
      T=(EPOCH-1800D0)/100D0

*  Select model
      IF (EPOCH.GE.1708.185161980887D0) THEN

*     Post-1708: use McCarthy & Babcock
         W=T-0.19D0
         S=5.156D0+13.3066D0*W*W
      ELSE IF (EPOCH.GE.979.0258204760233D0) THEN

*     979-1708: use Stephenson & Morrison's 948-1600 model
         S=25.5D0*T*T
      ELSE

*     Pre-979: use Stephenson & Morrison's 390 BC to AD 948 model
         S=1360.0D0+(320D0+44.3D0*T)*T
      END IF

*  Result
      sla_DT=S

      END

      DOUBLE PRECISION FUNCTION sla_EPJ (DATE)
*+
*     - - - -
*      E P J
*     - - - -
*
*  Conversion of Modified Julian Date to Julian Epoch (double precision)
*
*  Given:
*     DATE     dp       Modified Julian Date (JD - 2400000.5)
*
*  The result is the Julian Epoch.
*
*  Reference:
*     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
*
*  P.T.Wallace   Starlink   February 1984
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE


      sla_EPJ = 2000D0 + (DATE-51544.5D0)/365.25D0

      END

      SUBROUTINE sla_DMOON (DATE, PV)
*+
*     - - - - - -
*      D M O O N
*     - - - - - -
*
*  Approximate geocentric position and velocity of the Moon
*  (double precision)
*
*  Given:
*     DATE       D       TDB (loosely ET) as a Modified Julian Date
*                                                    (JD-2400000.5)
*
*  Returned:
*     PV         D(6)    Moon x,y,z,xdot,ydot,zdot, mean equator and
*                                         equinox of date (AU, AU/s)
*
*  Notes:
*
*  1  This routine is a full implementation of the algorithm
*     published by Meeus (see reference).
*
*  2  Meeus quotes accuracies of 10 arcsec in longitude, 3 arcsec in
*     latitude and 0.2 arcsec in HP (equivalent to about 20 km in
*     distance).  Comparison with JPL DE200 over the interval
*     1960-2025 gives RMS errors of 3.7 arcsec and 83 mas/hour in
*     longitude, 2.3 arcsec and 48 mas/hour in latitude, 11 km
*     and 81 mm/s in distance.
*
*  3  The original algorithm is expressed in terms of the obsolete
*     timescale Ephemeris Time.  Either TDB or TT can be used, but
*     not UT without incurring significant errors (30 arcsec at
*     the present time) due to the Moon's 0.5 arcsec/sec movement.
*
*  4  The algorithm is based on pre IAU 1976 standards.  However,
*     the result has been moved onto the new (FK5) equinox, an
*     adjustment which is in any case much smaller than the
*     intrinsic accuracy of the procedure.
*
*  5  Velocity is obtained by a complete analytical differentiation
*     of the Meeus model.
*
*  Reference:
*     Meeus, l'Astronomie, June 1984, p348.
*
*  P.T.Wallace   Starlink   7 December 1994
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,PV(6)

*  Degrees, arcseconds and seconds of time to radians
      DOUBLE PRECISION D2R,DAS2R,DS2R
      PARAMETER (D2R=0.0174532925199432957692369D0,
     :           DAS2R=4.848136811095359935899141D-6,
     :           DS2R=7.272205216643039903848712D-5)

*  Seconds per Julian century (86400*36525)
      DOUBLE PRECISION CJ
      PARAMETER (CJ=3155760000D0)

*  Julian epoch of B1950
      DOUBLE PRECISION B1950
      PARAMETER (B1950=1949.9997904423D0)

*  Earth equatorial radius in AU ( = 6378.137 / 149597870 )
      DOUBLE PRECISION ERADAU
      PARAMETER (ERADAU=4.2635212653763D-5)

      DOUBLE PRECISION T,THETA,SINOM,COSOM,DOMCOM,WA,DWA,WB,DWB,WOM,
     :                 DWOM,SINWOM,COSWOM,V,DV,COEFF,EMN,EMPN,DN,FN,EN,
     :                 DEN,DTHETA,FTHETA,EL,DEL,B,DB,BF,DBF,P,DP,SP,R,
     :                 DR,X,Y,Z,XD,YD,ZD,SEL,CEL,SB,CB,RCB,RBD,W,EPJ,
     :                 EQCOR,EPS,SINEPS,COSEPS,ES,EC
      INTEGER N,I

*
*  Coefficients for fundamental arguments
*
*   at J1900:  T**0, T**1, T**2, T**3
*   at epoch:  T**0, T**1
*
*  Units are degrees for position and Julian centuries for time
*

*  Moon's mean longitude
      DOUBLE PRECISION ELP0,ELP1,ELP2,ELP3,ELP,DELP
      PARAMETER (ELP0=270.434164D0,
     :           ELP1=481267.8831D0,
     :           ELP2=-0.001133D0,
     :           ELP3=0.0000019D0)

*  Sun's mean anomaly
      DOUBLE PRECISION EM0,EM1,EM2,EM3,EM,DEM
      PARAMETER (EM0=358.475833D0,
     :           EM1=35999.0498D0,
     :           EM2=-0.000150D0,
     :           EM3=-0.0000033D0)

*  Moon's mean anomaly
      DOUBLE PRECISION EMP0,EMP1,EMP2,EMP3,EMP,DEMP
      PARAMETER (EMP0=296.104608D0,
     :           EMP1=477198.8491D0,
     :           EMP2=0.009192D0,
     :           EMP3=0.0000144D0)

*  Moon's mean elongation
      DOUBLE PRECISION D0,D1,D2,D3,D,DD
      PARAMETER (D0=350.737486D0,
     :           D1=445267.1142D0,
     :           D2=-0.001436D0,
     :           D3=0.0000019D0)

*  Mean distance of the Moon from its ascending node
      DOUBLE PRECISION F0,F1,F2,F3,F,DF
      PARAMETER (F0=11.250889D0,
     :           F1=483202.0251D0,
     :           F2=-0.003211D0,
     :           F3=-0.0000003D0)

*  Longitude of the Moon's ascending node
      DOUBLE PRECISION OM0,OM1,OM2,OM3,OM,DOM
      PARAMETER (OM0=259.183275D0,
     :           OM1=-1934.1420D0,
     :           OM2=0.002078D0,
     :           OM3=0.0000022D0)

*  Coefficients for (dimensionless) E factor
      DOUBLE PRECISION E1,E2,E,DE,ESQ,DESQ
      PARAMETER (E1=-0.002495D0,E2=-0.00000752D0)

*  Coefficients for periodic variations etc
      DOUBLE PRECISION PAC,PA0,PA1
      PARAMETER (PAC=0.000233D0,PA0=51.2D0,PA1=20.2D0)
      DOUBLE PRECISION PBC
      PARAMETER (PBC=-0.001778D0)
      DOUBLE PRECISION PCC
      PARAMETER (PCC=0.000817D0)
      DOUBLE PRECISION PDC
      PARAMETER (PDC=0.002011D0)
      DOUBLE PRECISION PEC,PE0,PE1,PE2
      PARAMETER (PEC=0.003964D0,
     :                     PE0=346.560D0,PE1=132.870D0,PE2=-0.0091731D0)
      DOUBLE PRECISION PFC
      PARAMETER (PFC=0.001964D0)
      DOUBLE PRECISION PGC
      PARAMETER (PGC=0.002541D0)
      DOUBLE PRECISION PHC
      PARAMETER (PHC=0.001964D0)
      DOUBLE PRECISION PIC
      PARAMETER (PIC=-0.024691D0)
      DOUBLE PRECISION PJC,PJ0,PJ1
      PARAMETER (PJC=-0.004328D0,PJ0=275.05D0,PJ1=-2.30D0)
      DOUBLE PRECISION CW1
      PARAMETER (CW1=0.0004664D0)
      DOUBLE PRECISION CW2
      PARAMETER (CW2=0.0000754D0)

*
*  Coefficients for Moon position
*
*   Tx(N)       = coefficient of L, B or P term (deg)
*   ITx(N,1-5)  = coefficients of M, M', D, F, E**n in argument
*
      INTEGER NL,NB,NP
      PARAMETER (NL=50,NB=45,NP=31)
      DOUBLE PRECISION TL(NL),TB(NB),TP(NP)
      INTEGER ITL(5,NL),ITB(5,NB),ITP(5,NP)
*
*  Longitude
*                                         M   M'  D   F   n
      DATA TL( 1)/            +6.288750D0                     /,
     :     (ITL(I, 1),I=1,5)/            +0, +1, +0, +0,  0   /
      DATA TL( 2)/            +1.274018D0                     /,
     :     (ITL(I, 2),I=1,5)/            +0, -1, +2, +0,  0   /
      DATA TL( 3)/            +0.658309D0                     /,
     :     (ITL(I, 3),I=1,5)/            +0, +0, +2, +0,  0   /
      DATA TL( 4)/            +0.213616D0                     /,
     :     (ITL(I, 4),I=1,5)/            +0, +2, +0, +0,  0   /
      DATA TL( 5)/            -0.185596D0                     /,
     :     (ITL(I, 5),I=1,5)/            +1, +0, +0, +0,  1   /
      DATA TL( 6)/            -0.114336D0                     /,
     :     (ITL(I, 6),I=1,5)/            +0, +0, +0, +2,  0   /
      DATA TL( 7)/            +0.058793D0                     /,
     :     (ITL(I, 7),I=1,5)/            +0, -2, +2, +0,  0   /
      DATA TL( 8)/            +0.057212D0                     /,
     :     (ITL(I, 8),I=1,5)/            -1, -1, +2, +0,  1   /
      DATA TL( 9)/            +0.053320D0                     /,
     :     (ITL(I, 9),I=1,5)/            +0, +1, +2, +0,  0   /
      DATA TL(10)/            +0.045874D0                     /,
     :     (ITL(I,10),I=1,5)/            -1, +0, +2, +0,  1   /
      DATA TL(11)/            +0.041024D0                     /,
     :     (ITL(I,11),I=1,5)/            -1, +1, +0, +0,  1   /
      DATA TL(12)/            -0.034718D0                     /,
     :     (ITL(I,12),I=1,5)/            +0, +0, +1, +0,  0   /
      DATA TL(13)/            -0.030465D0                     /,
     :     (ITL(I,13),I=1,5)/            +1, +1, +0, +0,  1   /
      DATA TL(14)/            +0.015326D0                     /,
     :     (ITL(I,14),I=1,5)/            +0, +0, +2, -2,  0   /
      DATA TL(15)/            -0.012528D0                     /,
     :     (ITL(I,15),I=1,5)/            +0, +1, +0, +2,  0   /
      DATA TL(16)/            -0.010980D0                     /,
     :     (ITL(I,16),I=1,5)/            +0, -1, +0, +2,  0   /
      DATA TL(17)/            +0.010674D0                     /,
     :     (ITL(I,17),I=1,5)/            +0, -1, +4, +0,  0   /
      DATA TL(18)/            +0.010034D0                     /,
     :     (ITL(I,18),I=1,5)/            +0, +3, +0, +0,  0   /
      DATA TL(19)/            +0.008548D0                     /,
     :     (ITL(I,19),I=1,5)/            +0, -2, +4, +0,  0   /
      DATA TL(20)/            -0.007910D0                     /,
     :     (ITL(I,20),I=1,5)/            +1, -1, +2, +0,  1   /
      DATA TL(21)/            -0.006783D0                     /,
     :     (ITL(I,21),I=1,5)/            +1, +0, +2, +0,  1   /
      DATA TL(22)/            +0.005162D0                     /,
     :     (ITL(I,22),I=1,5)/            +0, +1, -1, +0,  0   /
      DATA TL(23)/            +0.005000D0                     /,
     :     (ITL(I,23),I=1,5)/            +1, +0, +1, +0,  1   /
      DATA TL(24)/            +0.004049D0                     /,
     :     (ITL(I,24),I=1,5)/            -1, +1, +2, +0,  1   /
      DATA TL(25)/            +0.003996D0                     /,
     :     (ITL(I,25),I=1,5)/            +0, +2, +2, +0,  0   /
      DATA TL(26)/            +0.003862D0                     /,
     :     (ITL(I,26),I=1,5)/            +0, +0, +4, +0,  0   /
      DATA TL(27)/            +0.003665D0                     /,
     :     (ITL(I,27),I=1,5)/            +0, -3, +2, +0,  0   /
      DATA TL(28)/            +0.002695D0                     /,
     :     (ITL(I,28),I=1,5)/            -1, +2, +0, +0,  1   /
      DATA TL(29)/            +0.002602D0                     /,
     :     (ITL(I,29),I=1,5)/            +0, +1, -2, -2,  0   /
      DATA TL(30)/            +0.002396D0                     /,
     :     (ITL(I,30),I=1,5)/            -1, -2, +2, +0,  1   /
      DATA TL(31)/            -0.002349D0                     /,
     :     (ITL(I,31),I=1,5)/            +0, +1, +1, +0,  0   /
      DATA TL(32)/            +0.002249D0                     /,
     :     (ITL(I,32),I=1,5)/            -2, +0, +2, +0,  2   /
      DATA TL(33)/            -0.002125D0                     /,
     :     (ITL(I,33),I=1,5)/            +1, +2, +0, +0,  1   /
      DATA TL(34)/            -0.002079D0                     /,
     :     (ITL(I,34),I=1,5)/            +2, +0, +0, +0,  2   /
      DATA TL(35)/            +0.002059D0                     /,
     :     (ITL(I,35),I=1,5)/            -2, -1, +2, +0,  2   /
      DATA TL(36)/            -0.001773D0                     /,
     :     (ITL(I,36),I=1,5)/            +0, +1, +2, -2,  0   /
      DATA TL(37)/            -0.001595D0                     /,
     :     (ITL(I,37),I=1,5)/            +0, +0, +2, +2,  0   /
      DATA TL(38)/            +0.001220D0                     /,
     :     (ITL(I,38),I=1,5)/            -1, -1, +4, +0,  1   /
      DATA TL(39)/            -0.001110D0                     /,
     :     (ITL(I,39),I=1,5)/            +0, +2, +0, +2,  0   /
      DATA TL(40)/            +0.000892D0                     /,
     :     (ITL(I,40),I=1,5)/            +0, +1, -3, +0,  0   /
      DATA TL(41)/            -0.000811D0                     /,
     :     (ITL(I,41),I=1,5)/            +1, +1, +2, +0,  1   /
      DATA TL(42)/            +0.000761D0                     /,
     :     (ITL(I,42),I=1,5)/            -1, -2, +4, +0,  1   /
      DATA TL(43)/            +0.000717D0                     /,
     :     (ITL(I,43),I=1,5)/            -2, +1, +0, +0,  2   /
      DATA TL(44)/            +0.000704D0                     /,
     :     (ITL(I,44),I=1,5)/            -2, +1, -2, +0,  2   /
      DATA TL(45)/            +0.000693D0                     /,
     :     (ITL(I,45),I=1,5)/            +1, -2, +2, +0,  1   /
      DATA TL(46)/            +0.000598D0                     /,
     :     (ITL(I,46),I=1,5)/            -1, +0, +2, -2,  1   /
      DATA TL(47)/            +0.000550D0                     /,
     :     (ITL(I,47),I=1,5)/            +0, +1, +4, +0,  0   /
      DATA TL(48)/            +0.000538D0                     /,
     :     (ITL(I,48),I=1,5)/            +0, +4, +0, +0,  0   /
      DATA TL(49)/            +0.000521D0                     /,
     :     (ITL(I,49),I=1,5)/            -1, +0, +4, +0,  1   /
      DATA TL(50)/            +0.000486D0                     /,
     :     (ITL(I,50),I=1,5)/            +0, +2, -1, +0,  0   /
*
*  Latitude
*                                         M   M'  D   F   n
      DATA TB( 1)/            +5.128189D0                     /,
     :     (ITB(I, 1),I=1,5)/            +0, +0, +0, +1,  0   /
      DATA TB( 2)/            +0.280606D0                     /,
     :     (ITB(I, 2),I=1,5)/            +0, +1, +0, +1,  0   /
      DATA TB( 3)/            +0.277693D0                     /,
     :     (ITB(I, 3),I=1,5)/            +0, +1, +0, -1,  0   /
      DATA TB( 4)/            +0.173238D0                     /,
     :     (ITB(I, 4),I=1,5)/            +0, +0, +2, -1,  0   /
      DATA TB( 5)/            +0.055413D0                     /,
     :     (ITB(I, 5),I=1,5)/            +0, -1, +2, +1,  0   /
      DATA TB( 6)/            +0.046272D0                     /,
     :     (ITB(I, 6),I=1,5)/            +0, -1, +2, -1,  0   /
      DATA TB( 7)/            +0.032573D0                     /,
     :     (ITB(I, 7),I=1,5)/            +0, +0, +2, +1,  0   /
      DATA TB( 8)/            +0.017198D0                     /,
     :     (ITB(I, 8),I=1,5)/            +0, +2, +0, +1,  0   /
      DATA TB( 9)/            +0.009267D0                     /,
     :     (ITB(I, 9),I=1,5)/            +0, +1, +2, -1,  0   /
      DATA TB(10)/            +0.008823D0                     /,
     :     (ITB(I,10),I=1,5)/            +0, +2, +0, -1,  0   /
      DATA TB(11)/            +0.008247D0                     /,
     :     (ITB(I,11),I=1,5)/            -1, +0, +2, -1,  1   /
      DATA TB(12)/            +0.004323D0                     /,
     :     (ITB(I,12),I=1,5)/            +0, -2, +2, -1,  0   /
      DATA TB(13)/            +0.004200D0                     /,
     :     (ITB(I,13),I=1,5)/            +0, +1, +2, +1,  0   /
      DATA TB(14)/            +0.003372D0                     /,
     :     (ITB(I,14),I=1,5)/            -1, +0, -2, +1,  1   /
      DATA TB(15)/            +0.002472D0                     /,
     :     (ITB(I,15),I=1,5)/            -1, -1, +2, +1,  1   /
      DATA TB(16)/            +0.002222D0                     /,
     :     (ITB(I,16),I=1,5)/            -1, +0, +2, +1,  1   /
      DATA TB(17)/            +0.002072D0                     /,
     :     (ITB(I,17),I=1,5)/            -1, -1, +2, -1,  1   /
      DATA TB(18)/            +0.001877D0                     /,
     :     (ITB(I,18),I=1,5)/            -1, +1, +0, +1,  1   /
      DATA TB(19)/            +0.001828D0                     /,
     :     (ITB(I,19),I=1,5)/            +0, -1, +4, -1,  0   /
      DATA TB(20)/            -0.001803D0                     /,
     :     (ITB(I,20),I=1,5)/            +1, +0, +0, +1,  1   /
      DATA TB(21)/            -0.001750D0                     /,
     :     (ITB(I,21),I=1,5)/            +0, +0, +0, +3,  0   /
      DATA TB(22)/            +0.001570D0                     /,
     :     (ITB(I,22),I=1,5)/            -1, +1, +0, -1,  1   /
      DATA TB(23)/            -0.001487D0                     /,
     :     (ITB(I,23),I=1,5)/            +0, +0, +1, +1,  0   /
      DATA TB(24)/            -0.001481D0                     /,
     :     (ITB(I,24),I=1,5)/            +1, +1, +0, +1,  1   /
      DATA TB(25)/            +0.001417D0                     /,
     :     (ITB(I,25),I=1,5)/            -1, -1, +0, +1,  1   /
      DATA TB(26)/            +0.001350D0                     /,
     :     (ITB(I,26),I=1,5)/            -1, +0, +0, +1,  1   /
      DATA TB(27)/            +0.001330D0                     /,
     :     (ITB(I,27),I=1,5)/            +0, +0, -1, +1,  0   /
      DATA TB(28)/            +0.001106D0                     /,
     :     (ITB(I,28),I=1,5)/            +0, +3, +0, +1,  0   /
      DATA TB(29)/            +0.001020D0                     /,
     :     (ITB(I,29),I=1,5)/            +0, +0, +4, -1,  0   /
      DATA TB(30)/            +0.000833D0                     /,
     :     (ITB(I,30),I=1,5)/            +0, -1, +4, +1,  0   /
      DATA TB(31)/            +0.000781D0                     /,
     :     (ITB(I,31),I=1,5)/            +0, +1, +0, -3,  0   /
      DATA TB(32)/            +0.000670D0                     /,
     :     (ITB(I,32),I=1,5)/            +0, -2, +4, +1,  0   /
      DATA TB(33)/            +0.000606D0                     /,
     :     (ITB(I,33),I=1,5)/            +0, +0, +2, -3,  0   /
      DATA TB(34)/            +0.000597D0                     /,
     :     (ITB(I,34),I=1,5)/            +0, +2, +2, -1,  0   /
      DATA TB(35)/            +0.000492D0                     /,
     :     (ITB(I,35),I=1,5)/            -1, +1, +2, -1,  1   /
      DATA TB(36)/            +0.000450D0                     /,
     :     (ITB(I,36),I=1,5)/            +0, +2, -2, -1,  0   /
      DATA TB(37)/            +0.000439D0                     /,
     :     (ITB(I,37),I=1,5)/            +0, +3, +0, -1,  0   /
      DATA TB(38)/            +0.000423D0                     /,
     :     (ITB(I,38),I=1,5)/            +0, +2, +2, +1,  0   /
      DATA TB(39)/            +0.000422D0                     /,
     :     (ITB(I,39),I=1,5)/            +0, -3, +2, -1,  0   /
      DATA TB(40)/            -0.000367D0                     /,
     :     (ITB(I,40),I=1,5)/            +1, -1, +2, +1,  1   /
      DATA TB(41)/            -0.000353D0                     /,
     :     (ITB(I,41),I=1,5)/            +1, +0, +2, +1,  1   /
      DATA TB(42)/            +0.000331D0                     /,
     :     (ITB(I,42),I=1,5)/            +0, +0, +4, +1,  0   /
      DATA TB(43)/            +0.000317D0                     /,
     :     (ITB(I,43),I=1,5)/            -1, +1, +2, +1,  1   /
      DATA TB(44)/            +0.000306D0                     /,
     :     (ITB(I,44),I=1,5)/            -2, +0, +2, -1,  2   /
      DATA TB(45)/            -0.000283D0                     /,
     :     (ITB(I,45),I=1,5)/            +0, +1, +0, +3,  0   /
*
*  Parallax
*                                         M   M'  D   F   n
      DATA TP( 1)/            +0.950724D0                     /,
     :     (ITP(I, 1),I=1,5)/            +0, +0, +0, +0,  0   /
      DATA TP( 2)/            +0.051818D0                     /,
     :     (ITP(I, 2),I=1,5)/            +0, +1, +0, +0,  0   /
      DATA TP( 3)/            +0.009531D0                     /,
     :     (ITP(I, 3),I=1,5)/            +0, -1, +2, +0,  0   /
      DATA TP( 4)/            +0.007843D0                     /,
     :     (ITP(I, 4),I=1,5)/            +0, +0, +2, +0,  0   /
      DATA TP( 5)/            +0.002824D0                     /,
     :     (ITP(I, 5),I=1,5)/            +0, +2, +0, +0,  0   /
      DATA TP( 6)/            +0.000857D0                     /,
     :     (ITP(I, 6),I=1,5)/            +0, +1, +2, +0,  0   /
      DATA TP( 7)/            +0.000533D0                     /,
     :     (ITP(I, 7),I=1,5)/            -1, +0, +2, +0,  1   /
      DATA TP( 8)/            +0.000401D0                     /,
     :     (ITP(I, 8),I=1,5)/            -1, -1, +2, +0,  1   /
      DATA TP( 9)/            +0.000320D0                     /,
     :     (ITP(I, 9),I=1,5)/            -1, +1, +0, +0,  1   /
      DATA TP(10)/            -0.000271D0                     /,
     :     (ITP(I,10),I=1,5)/            +0, +0, +1, +0,  0   /
      DATA TP(11)/            -0.000264D0                     /,
     :     (ITP(I,11),I=1,5)/            +1, +1, +0, +0,  1   /
      DATA TP(12)/            -0.000198D0                     /,
     :     (ITP(I,12),I=1,5)/            +0, -1, +0, +2,  0   /
      DATA TP(13)/            +0.000173D0                     /,
     :     (ITP(I,13),I=1,5)/            +0, +3, +0, +0,  0   /
      DATA TP(14)/            +0.000167D0                     /,
     :     (ITP(I,14),I=1,5)/            +0, -1, +4, +0,  0   /
      DATA TP(15)/            -0.000111D0                     /,
     :     (ITP(I,15),I=1,5)/            +1, +0, +0, +0,  1   /
      DATA TP(16)/            +0.000103D0                     /,
     :     (ITP(I,16),I=1,5)/            +0, -2, +4, +0,  0   /
      DATA TP(17)/            -0.000084D0                     /,
     :     (ITP(I,17),I=1,5)/            +0, +2, -2, +0,  0   /
      DATA TP(18)/            -0.000083D0                     /,
     :     (ITP(I,18),I=1,5)/            +1, +0, +2, +0,  1   /
      DATA TP(19)/            +0.000079D0                     /,
     :     (ITP(I,19),I=1,5)/            +0, +2, +2, +0,  0   /
      DATA TP(20)/            +0.000072D0                     /,
     :     (ITP(I,20),I=1,5)/            +0, +0, +4, +0,  0   /
      DATA TP(21)/            +0.000064D0                     /,
     :     (ITP(I,21),I=1,5)/            -1, +1, +2, +0,  1   /
      DATA TP(22)/            -0.000063D0                     /,
     :     (ITP(I,22),I=1,5)/            +1, -1, +2, +0,  1   /
      DATA TP(23)/            +0.000041D0                     /,
     :     (ITP(I,23),I=1,5)/            +1, +0, +1, +0,  1   /
      DATA TP(24)/            +0.000035D0                     /,
     :     (ITP(I,24),I=1,5)/            -1, +2, +0, +0,  1   /
      DATA TP(25)/            -0.000033D0                     /,
     :     (ITP(I,25),I=1,5)/            +0, +3, -2, +0,  0   /
      DATA TP(26)/            -0.000030D0                     /,
     :     (ITP(I,26),I=1,5)/            +0, +1, +1, +0,  0   /
      DATA TP(27)/            -0.000029D0                     /,
     :     (ITP(I,27),I=1,5)/            +0, +0, -2, +2,  0   /
      DATA TP(28)/            -0.000029D0                     /,
     :     (ITP(I,28),I=1,5)/            +1, +2, +0, +0,  1   /
      DATA TP(29)/            +0.000026D0                     /,
     :     (ITP(I,29),I=1,5)/            -2, +0, +2, +0,  2   /
      DATA TP(30)/            -0.000023D0                     /,
     :     (ITP(I,30),I=1,5)/            +0, +1, -2, +2,  0   /
      DATA TP(31)/            +0.000019D0                     /,
     :     (ITP(I,31),I=1,5)/            -1, -1, +4, +0,  1   /



*  Centuries since J1900
      T=(DATE-15019.5D0)/36525D0

*
*  Fundamental arguments (radians) and derivatives (radians per
*  Julian century) for the current epoch
*

*  Moon's mean longitude
      ELP=D2R*MOD(ELP0+(ELP1+(ELP2+ELP3*T)*T)*T,360D0)
      DELP=D2R*(ELP1+(2D0*ELP2+3D0*ELP3*T)*T)

*  Sun's mean anomaly
      EM=D2R*MOD(EM0+(EM1+(EM2+EM3*T)*T)*T,360D0)
      DEM=D2R*(EM1+(2D0*EM2+3D0*EM3*T)*T)

*  Moon's mean anomaly
      EMP=D2R*MOD(EMP0+(EMP1+(EMP2+EMP3*T)*T)*T,360D0)
      DEMP=D2R*(EMP1+(2D0*EMP2+3D0*EMP3*T)*T)

*  Moon's mean elongation
      D=D2R*MOD(D0+(D1+(D2+D3*T)*T)*T,360D0)
      DD=D2R*(D1+(2D0*D2+3D0*D3*T)*T)

*  Mean distance of the Moon from its ascending node
      F=D2R*MOD(F0+(F1+(F2+F3*T)*T)*T,360D0)
      DF=D2R*(F1+(2D0*F2+3D0*F3*T)*T)

*  Longitude of the Moon's ascending node
      OM=D2R*MOD(OM0+(OM1+(OM2+OM3*T)*T)*T,360D0)
      DOM=D2R*(OM1+(2D0*OM2+3D0*OM3*T)*T)
      SINOM=SIN(OM)
      COSOM=COS(OM)
      DOMCOM=DOM*COSOM

*  Add the periodic variations
      THETA=D2R*(PA0+PA1*T)
      WA=SIN(THETA)
      DWA=D2R*PA1*COS(THETA)
      THETA=D2R*(PE0+(PE1+PE2*T)*T)
      WB=PEC*SIN(THETA)
      DWB=D2R*PEC*(PE1+2D0*PE2*T)*COS(THETA)
      ELP=ELP+D2R*(PAC*WA+WB+PFC*SINOM)
      DELP=DELP+D2R*(PAC*DWA+DWB+PFC*DOMCOM)
      EM=EM+D2R*PBC*WA
      DEM=DEM+D2R*PBC*DWA
      EMP=EMP+D2R*(PCC*WA+WB+PGC*SINOM)
      DEMP=DEMP+D2R*(PCC*DWA+DWB+PGC*DOMCOM)
      D=D+D2R*(PDC*WA+WB+PHC*SINOM)
      DD=DD+D2R*(PDC*DWA+DWB+PHC*DOMCOM)
      WOM=OM+D2R*(PJ0+PJ1*T)
      DWOM=DOM+D2R*PJ1
      SINWOM=SIN(WOM)
      COSWOM=COS(WOM)
      F=F+D2R*(WB+PIC*SINOM+PJC*SINWOM)
      DF=DF+D2R*(DWB+PIC*DOMCOM+PJC*DWOM*COSWOM)

*  E-factor, and square
      E=1D0+(E1+E2*T)*T
      DE=E1+2D0*E2*T
      ESQ=E*E
      DESQ=2D0*E*DE

*
*  Series expansions
*

*  Longitude
      V=0D0
      DV=0D0
      DO N=NL,1,-1
         COEFF=TL(N)
         EMN=DBLE(ITL(1,N))
         EMPN=DBLE(ITL(2,N))
         DN=DBLE(ITL(3,N))
         FN=DBLE(ITL(4,N))
         I=ITL(5,N)
         IF (I.EQ.0) THEN
            EN=1D0
            DEN=0D0
         ELSE IF (I.EQ.1) THEN
            EN=E
            DEN=DE
         ELSE
            EN=ESQ
            DEN=DESQ
         END IF
         THETA=EMN*EM+EMPN*EMP+DN*D+FN*F
         DTHETA=EMN*DEM+EMPN*DEMP+DN*DD+FN*DF
         FTHETA=SIN(THETA)
         V=V+COEFF*FTHETA*EN
         DV=DV+COEFF*(COS(THETA)*DTHETA*EN+FTHETA*DEN)
      END DO
      EL=ELP+D2R*V
      DEL=(DELP+D2R*DV)/CJ

*  Latitude
      V=0D0
      DV=0D0
      DO N=NB,1,-1
         COEFF=TB(N)
         EMN=DBLE(ITB(1,N))
         EMPN=DBLE(ITB(2,N))
         DN=DBLE(ITB(3,N))
         FN=DBLE(ITB(4,N))
         I=ITB(5,N)
         IF (I.EQ.0) THEN
            EN=1D0
            DEN=0D0
         ELSE IF (I.EQ.1) THEN
            EN=E
            DEN=DE
         ELSE
            EN=ESQ
            DEN=DESQ
         END IF
         THETA=EMN*EM+EMPN*EMP+DN*D+FN*F
         DTHETA=EMN*DEM+EMPN*DEMP+DN*DD+FN*DF
         FTHETA=SIN(THETA)
         V=V+COEFF*FTHETA*EN
         DV=DV+COEFF*(COS(THETA)*DTHETA*EN+FTHETA*DEN)
      END DO
      BF=1D0-CW1*COSOM-CW2*COSWOM
      DBF=CW1*DOM*SINOM+CW2*DWOM*SINWOM
      B=D2R*V*BF
      DB=D2R*(DV*BF+V*DBF)/CJ

*  Parallax
      V=0D0
      DV=0D0
      DO N=NP,1,-1
         COEFF=TP(N)
         EMN=DBLE(ITP(1,N))
         EMPN=DBLE(ITP(2,N))
         DN=DBLE(ITP(3,N))
         FN=DBLE(ITP(4,N))
         I=ITP(5,N)
         IF (I.EQ.0) THEN
            EN=1D0
            DEN=0D0
         ELSE IF (I.EQ.1) THEN
            EN=E
            DEN=DE
         ELSE
            EN=ESQ
            DEN=DESQ
         END IF
         THETA=EMN*EM+EMPN*EMP+DN*D+FN*F
         DTHETA=EMN*DEM+EMPN*DEMP+DN*DD+FN*DF
         FTHETA=COS(THETA)
         V=V+COEFF*FTHETA*EN
         DV=DV+COEFF*(-SIN(THETA)*DTHETA*EN+FTHETA*DEN)
      END DO
      P=D2R*V
      DP=D2R*DV/CJ

*
*  Transformation into final form
*

*  Parallax to distance (AU, AU/sec)
      SP=SIN(P)
      R=ERADAU/SP
      DR=-R*DP*COS(P)/SP

*  Longitude, latitude to x,y,z (AU)
      SEL=SIN(EL)
      CEL=COS(EL)
      SB=SIN(B)
      CB=COS(B)
      RCB=R*CB
      RBD=R*DB
      W=RBD*SB-CB*DR
      X=RCB*CEL
      Y=RCB*SEL
      Z=R*SB
      XD=-Y*DEL-W*CEL
      YD=X*DEL-W*SEL
      ZD=RBD*CB+SB*DR

*  Julian centuries since J2000
      T=(DATE-51544.5D0)/36525D0

*  Fricke equinox correction
      EPJ=2000D0+T*100D0
      EQCOR=DS2R*(0.035D0+0.00085D0*(EPJ-B1950))

*  Mean obliquity (IAU 1976)
      EPS=DAS2R*(84381.448D0+(-46.8150D0+(-0.00059D0+0.001813D0*T)*T)*T)

*  To the equatorial system, mean of date, FK5 system
      SINEPS=SIN(EPS)
      COSEPS=COS(EPS)
      ES=EQCOR*SINEPS
      EC=EQCOR*COSEPS
      PV(1)=X-EC*Y+ES*Z
      PV(2)=EQCOR*X+Y*COSEPS-Z*SINEPS
      PV(3)=Y*SINEPS+Z*COSEPS
      PV(4)=XD-EC*YD+ES*ZD
      PV(5)=EQCOR*XD+YD*COSEPS-ZD*SINEPS
      PV(6)=YD*SINEPS+ZD*COSEPS

      END

      SUBROUTINE sla_PVOBS (P, H, STL, PV)
*+
*     - - - - - -
*      P V O B S
*     - - - - - -
*
*  Position and velocity of an observing station (double precision)
*
*  Given:
*     P     dp     latitude (geodetic, radians)
*     H     dp     height above reference spheroid (geodetic, metres)
*     STL   dp     local apparent sidereal time (radians)
*
*  Returned:
*     PV    dp(6)  position/velocity 6-vector (AU, AU/s, true equator
*                                              and equinox of date)
*
*  Called:  sla_GEOC
*
*  IAU 1976 constants are used.
*
*  P.T.Wallace   Starlink   14 November 1994
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION P,H,STL,PV(6)

      DOUBLE PRECISION R,Z,S,C,V

*  Mean sidereal rate (at J2000) in radians per (UT1) second
      DOUBLE PRECISION SR
      PARAMETER (SR=7.292115855306589D-5)



*  Geodetic to geocentric conversion
      CALL sla_GEOC(P,H,R,Z)

*  Functions of ST
      S=SIN(STL)
      C=COS(STL)

*  Speed
      V=SR*R

*  Position
      PV(1)=R*C
      PV(2)=R*S
      PV(3)=Z

*  Velocity
      PV(4)=-V*S
      PV(5)=V*C
      PV(6)=0D0

      END

      SUBROUTINE sla_PRENUT (EPOCH, DATE, RMATPN)
*+
*     - - - - - - -
*      P R E N U T
*     - - - - - - -
*
*  Form the matrix of precession and nutation (IAU1976/FK5)
*  (double precision)
*
*  Given:
*     EPOCH   dp         Julian Epoch for mean coordinates
*     DATE    dp         Modified Julian Date (JD-2400000.5)
*                        for true coordinates
*
*  Returned:
*     RMATPN  dp(3,3)    combined precession/nutation matrix
*
*  Called:  sla_PREC, sla_EPJ, sla_NUT, sla_DMXM
*
*  Notes:
*
*  1)  The epoch and date are TDB (loosely ET).
*
*  2)  The matrix is in the sense   V(true)  =  RMATPN * V(mean)
*
*  P.T.Wallace   Starlink   April 1987
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION EPOCH,DATE,RMATPN(3,3)

      DOUBLE PRECISION RMATP(3,3),RMATN(3,3),sla_EPJ



*  Precession
      CALL sla_PREC(EPOCH,sla_EPJ(DATE),RMATP)

*  Nutation
      CALL sla_NUT(DATE,RMATN)

*  Combine the matrices:  PN = N x P
      CALL sla_DMXM(RMATN,RMATP,RMATPN)

      END

      SUBROUTINE sla_PLANET (DATE, NP, PV, JSTAT)
*+
*     - - - - - - -
*      P L A N E T
*     - - - - - - -
*
*  Approximate heliocentric position and velocity of a specified
*  major planet.
*
*  Given:
*     DATE      d      Modified Julian Date (JD - 2400000.5)
*     NP        i      planet (1=Mercury, 2=Venus, 3=EMB ... 9=Pluto)
*
*  Returned:
*     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot, J2000
*                                           equatorial triad (AU,AU/s)
*     JSTAT     i      status: +1 = warning: date out of range
*                               0 = OK
*                              -1 = illegal NP (outside 1-9)
*                              -2 = solution didn't converge
*
*  Called:  sla_PLANEL
*
*  Notes
*
*  1  The epoch, DATE, is in the TDB timescale and is a Modified
*     Julian Date (JD-2400000.5).
*
*  2  The reference frame is equatorial and is with respect to the
*     mean equinox and ecliptic of epoch J2000.
*
*  3  If an NP value outside the range 1-9 is supplied, an error
*     status (JSTAT = -1) is returned and the PV vector set to zeroes.
*
*  4  The algorithm for obtaining the mean elements of the planets
*     from Mercury to Neptune is due to J.L. Simon, P. Bretagnon,
*     J. Chapront, M. Chapront-Touze, G. Francou and J. Laskar
*     (Bureau des Longitudes, Paris).  The (completely different)
*     algorithm for calculating the ecliptic coordinates of Pluto
*     is by Meeus.
*
*  5  Comparisons of the present routine with the JPL DE200 ephemeris
*     give the following RMS errors over the interval 1960-2025:
*
*                      position (km)     speed (metre/sec)
*
*        Mercury            334               0.437
*        Venus             1060               0.855
*        EMB               2010               0.815
*        Mars              7690               1.98
*        Jupiter          71700               7.70
*        Saturn          199000              19.4
*        Uranus          564000              16.4
*        Neptune         158000              14.4
*        Pluto            36400               0.137
*
*     From comparisons with DE102, Simon et al quote the following
*     longitude accuracies over the interval 1800-2200:
*
*        Mercury                 4"
*        Venus                   5"
*        EMB                     6"
*        Mars                   17"
*        Jupiter                71"
*        Saturn                 81"
*        Uranus                 86"
*        Neptune                11"
*
*     In the case of Pluto, Meeus quotes an accuracy of 0.6 arcsec
*     in longitude and 0.2 arcsec in latitude for the period
*     1885-2099.
*
*     For all except Pluto, over the period 1000-3000 the accuracy
*     is better than 1.5 times that over 1800-2200.  Outside the
*     period 1000-3000 the accuracy declines.  For Pluto the
*     accuracy declines rapidly outside the period 1885-2099.
*     Outside these ranges (1885-2099 for Pluto, 1000-3000 for
*     the rest) a "date out of range" warning status (JSTAT=+1)
*     is returned.
*
*  6  The algorithms for (i) Mercury through Neptune and (ii) Pluto
*     are completely independent.  In the Mercury through Neptune
*     case, the present SLALIB implementation differs from the
*     original Simon et al Fortran code in the following respects.
*
*     *  The date is supplied as a Modified Julian Date rather
*        than a Julian Date (MJD = JD - 2400000.5).
*
*     *  The result is returned only in equatorial Cartesian form;
*        the ecliptic longitude, latitude and radius vector are not
*        returned.
*
*     *  The velocity is in AU per second, not AU per day.
*
*     *  Different error/warning status values are used.
*
*     *  Kepler's equation is not solved inline.
*
*     *  Polynomials in T are nested to minimize rounding errors.
*
*     *  Explicit double-precision constants are used to avoid
*        mixed-mode expressions.
*
*     *  There are other, cosmetic, changes to comply with
*        Starlink/SLALIB style guidelines.
*
*     None of the above changes affects the result significantly.
*
*  7  For NP=3 the result is for the Earth-Moon Barycentre.  To
*     obtain the heliocentric position and velocity of the Earth,
*     either use the SLALIB routine sla_EVP or call sla_DMOON and
*     subtract 0.012150581 times the geocentric Moon vector from
*     the EMB vector produced by the present routine.  (The Moon
*     vector should be precessed to J2000 first, but this can
*     be omitted for modern epochs without introducing significant
*     inaccuracy.)
*
*  References:  Simon et al., Astron. Astrophys. 282, 663 (1994).
*               Meeus, Astronomical Algorithms, Willmann-Bell (1991).
*
*  P.T.Wallace   Starlink   27 May 1997
*
*  Copyright (C) 1997 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER NP
      DOUBLE PRECISION PV(6)
      INTEGER JSTAT

*  2Pi, deg to radians, arcsec to radians
      DOUBLE PRECISION D2PI,D2R,AS2R
      PARAMETER (D2PI=6.283185307179586476925286766559D0,
     :           D2R=0.017453292519943295769236907684886D0,
     :           AS2R=4.848136811095359935899141023579D-6)

*  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

*  Seconds per Julian century
      DOUBLE PRECISION SPC
      PARAMETER (SPC=36525D0*86400D0)

*  Sin and cos of J2000 mean obliquity (IAU 1976)
      DOUBLE PRECISION SE,CE
      PARAMETER (SE=0.3977771559319137D0,
     :           CE=0.9174820620691818D0)

      INTEGER I,J,IJSP(3,43)
      DOUBLE PRECISION AMAS(8),A(3,8),DLM(3,8),E(3,8),
     :                 PI(3,8),DINC(3,8),OMEGA(3,8),
     :                 DKP(9,8),CA(9,8),SA(9,8),
     :                 DKQ(10,8),CLO(10,8),SLO(10,8),
     :                 T,DA,DE,DPE,DI,DO,DMU,ARGA,ARGL,DM,
     :                 AB(2,3,43),DJ0,DS0,DP0,DL0,DLD0,DB0,DR0,
     :                 DJ,DS,DP,DJD,DSD,DPD,WLBR(3),WLBRD(3),
     :                 WJ,WS,WP,AL,ALD,SAL,CAL,
     :                 AC,BC,DL,DLD,DB,DBD,DR,DRD,
     :                 SL,CL,SB,CB,SLCB,CLCB,X,Y,Z,XD,YD,ZD

*  -----------------------
*  Mercury through Neptune
*  -----------------------

*  Planetary inverse masses
      DATA AMAS / 6023600D0,408523.5D0,328900.5D0,3098710D0,
     :            1047.355D0,3498.5D0,22869D0,19314D0 /

*
*  Tables giving the mean Keplerian elements, limited to T**2 terms:
*
*         A       semi-major axis (AU)
*         DLM     mean longitude (degree and arcsecond)
*         E       eccentricity
*         PI      longitude of the perihelion (degree and arcsecond)
*         DINC    inclination (degree and arcsecond)
*         OMEGA   longitude of the ascending node (degree and arcsecond)
*
      DATA A /
     :  0.3870983098D0,             0D0,      0D0,
     :  0.7233298200D0,             0D0,      0D0,
     :  1.0000010178D0,             0D0,      0D0,
     :  1.5236793419D0,           3D-10,      0D0,
     :  5.2026032092D0,       19132D-10,  -39D-10,
     :  9.5549091915D0, -0.0000213896D0,  444D-10,
     : 19.2184460618D0,       -3716D-10,  979D-10,
     : 30.1103868694D0,      -16635D-10,  686D-10 /
*
      DATA DLM /
     : 252.25090552D0, 5381016286.88982D0,  -1.92789D0,
     : 181.97980085D0, 2106641364.33548D0,   0.59381D0,
     : 100.46645683D0, 1295977422.83429D0,  -2.04411D0,
     : 355.43299958D0,  689050774.93988D0,   0.94264D0,
     :  34.35151874D0,  109256603.77991D0, -30.60378D0,
     :  50.07744430D0,   43996098.55732D0,  75.61614D0,
     : 314.05500511D0,   15424811.93933D0,  -1.75083D0,
     : 304.34866548D0,    7865503.20744D0,   0.21103D0/
*
      DATA E /
     : 0.2056317526D0,  0.0002040653D0,      -28349D-10,
     : 0.0067719164D0, -0.0004776521D0,       98127D-10,
     : 0.0167086342D0, -0.0004203654D0, -0.0000126734D0,
     : 0.0934006477D0,  0.0009048438D0,      -80641D-10,
     : 0.0484979255D0,  0.0016322542D0, -0.0000471366D0,
     : 0.0555481426D0, -0.0034664062D0, -0.0000643639D0,
     : 0.0463812221D0, -0.0002729293D0,  0.0000078913D0,
     : 0.0094557470D0,  0.0000603263D0,            0D0 /
*
      DATA PI /
     :  77.45611904D0,  5719.11590D0,   -4.83016D0,
     : 131.56370300D0,   175.48640D0, -498.48184D0,
     : 102.93734808D0, 11612.35290D0,   53.27577D0,
     : 336.06023395D0, 15980.45908D0,  -62.32800D0,
     :  14.33120687D0,  7758.75163D0,  259.95938D0,
     :  93.05723748D0, 20395.49439D0,  190.25952D0,
     : 173.00529106D0,  3215.56238D0,  -34.09288D0,
     :  48.12027554D0,  1050.71912D0,   27.39717D0 /
*
      DATA DINC /
     : 7.00498625D0, -214.25629D0,   0.28977D0,
     : 3.39466189D0,  -30.84437D0, -11.67836D0,
     :          0D0,  469.97289D0,  -3.35053D0,
     : 1.84972648D0, -293.31722D0,  -8.11830D0,
     : 1.30326698D0,  -71.55890D0,  11.95297D0,
     : 2.48887878D0,   91.85195D0, -17.66225D0,
     : 0.77319689D0,  -60.72723D0,   1.25759D0,
     : 1.76995259D0,    8.12333D0,   0.08135D0 /
*
      DATA OMEGA /
     :  48.33089304D0,  -4515.21727D0,  -31.79892D0,
     :  76.67992019D0, -10008.48154D0,  -51.32614D0,
     : 174.87317577D0,  -8679.27034D0,   15.34191D0,
     :  49.55809321D0, -10620.90088D0, -230.57416D0,
     : 100.46440702D0,   6362.03561D0,  326.52178D0,
     : 113.66550252D0,  -9240.19942D0,  -66.23743D0,
     :  74.00595701D0,   2669.15033D0,  145.93964D0,
     : 131.78405702D0,   -221.94322D0,   -0.78728D0 /
*
*  Tables for trigonometric terms to be added to the mean elements
*  of the semi-major axes.
*
      DATA DKP /
     : 69613, 75645, 88306, 59899, 15746, 71087, 142173,  3086,    0,
     : 21863, 32794, 26934, 10931, 26250, 43725,  53867, 28939,    0,
     : 16002, 21863, 32004, 10931, 14529, 16368,  15318, 32794,    0,
     : 6345,   7818, 15636,  7077,  8184, 14163,   1107,  4872,    0,
     : 1760,   1454,  1167,   880,   287,  2640,     19,  2047, 1454,
     :  574,      0,   880,   287,    19,  1760,   1167,   306,  574,
     :  204,      0,   177,  1265,     4,   385,    200,   208,  204,
     :    0,    102,   106,     4,    98,  1367,    487,   204,    0 /
*
      DATA CA /
     :      4,    -13,    11,    -9,    -9,    -3,    -1,     4,    0,
     :   -156,     59,   -42,     6,    19,   -20,   -10,   -12,    0,
     :     64,   -152,    62,    -8,    32,   -41,    19,   -11,    0,
     :    124,    621,  -145,   208,    54,   -57,    30,    15,    0,
     : -23437,  -2634,  6601,  6259, -1507, -1821,  2620, -2115,-1489,
     :  62911,-119919, 79336, 17814,-24241, 12068,  8306, -4893, 8902,
     : 389061,-262125,-44088,  8387,-22976, -2093,  -615, -9720, 6633,
     :-412235,-157046,-31430, 37817, -9740,   -13, -7449,  9644,    0 /
*
      DATA SA /
     :     -29,    -1,     9,     6,    -6,     5,     4,     0,    0,
     :     -48,  -125,   -26,   -37,    18,   -13,   -20,    -2,    0,
     :    -150,   -46,    68,    54,    14,    24,   -28,    22,    0,
     :    -621,   532,  -694,   -20,   192,   -94,    71,   -73,    0,
     :  -14614,-19828, -5869,  1881, -4372, -2255,   782,   930,  913,
     :  139737,     0, 24667, 51123, -5102,  7429, -4095, -1976,-9566,
     : -138081,     0, 37205,-49039,-41901,-33872,-27037,-12474,18797,
     :       0, 28492,133236, 69654, 52322,-49577,-26430, -3593,    0 /
*
*  Tables giving the trigonometric terms to be added to the mean
*  elements of the mean longitudes.
*
      DATA DKQ /
     :  3086, 15746, 69613, 59899, 75645, 88306, 12661, 2658,  0,   0,
     : 21863, 32794, 10931,    73,  4387, 26934,  1473, 2157,  0,   0,
     :    10, 16002, 21863, 10931,  1473, 32004,  4387,   73,  0,   0,
     :    10,  6345,  7818,  1107, 15636,  7077,  8184,  532, 10,   0,
     :    19,  1760,  1454,   287,  1167,   880,   574, 2640, 19,1454,
     :    19,   574,   287,   306,  1760,    12,    31,   38, 19, 574,
     :     4,   204,   177,     8,    31,   200,  1265,  102,  4, 204,
     :     4,   102,   106,     8,    98,  1367,   487,  204,  4, 102 /
*
      DATA CLO /
     :     21,   -95, -157,   41,   -5,   42,   23,   30,     0,    0,
     :   -160,  -313, -235,   60,  -74,  -76,  -27,   34,     0,    0,
     :   -325,  -322,  -79,  232,  -52,   97,   55,  -41,     0,    0,
     :   2268,  -979,  802,  602, -668,  -33,  345,  201,   -55,    0,
     :   7610, -4997,-7689,-5841,-2617, 1115, -748, -607,  6074,  354,
     : -18549, 30125,20012, -730,  824,   23, 1289, -352,-14767,-2062,
     :-135245,-14594, 4197,-4030,-5630,-2898, 2540, -306,  2939, 1986,
     :  89948,  2103, 8963, 2695, 3682, 1648,  866, -154, -1963, -283 /
*
      DATA SLO /
     :   -342,   136,  -23,   62,   66,  -52,  -33,   17,     0,    0,
     :    524,  -149,  -35,  117,  151,  122,  -71,  -62,     0,    0,
     :   -105,  -137,  258,   35, -116,  -88, -112,  -80,     0,    0,
     :    854,  -205, -936, -240,  140, -341,  -97, -232,   536,    0,
     : -56980,  8016, 1012, 1448,-3024,-3710,  318,  503,  3767,  577,
     : 138606,-13478,-4964, 1441,-1319,-1482,  427, 1236, -9167,-1918,
     :  71234,-41116, 5334,-4935,-1848,   66,  434,-1748,  3780, -701,
     : -47645, 11647, 2166, 3194,  679,    0, -244, -419, -2531,   48 /

*  -----
*  Pluto
*  -----

*
*  Coefficients for fundamental arguments:  mean longitudes
*  (degrees) and mean rate of change of longitude (degrees per
*  Julian century) for Jupiter, Saturn and Pluto
*
      DATA DJ0, DJD / 34.35D0, 3034.9057D0 /
      DATA DS0, DSD / 50.08D0, 1222.1138D0 /
      DATA DP0, DPD / 238.96D0, 144.9600D0 /

*  Coefficients for latitude, longitude, radius vector
      DATA DL0,DLD0 / 238.956785D0, 144.96D0 /
      DATA DB0 / -3.908202D0 /
      DATA DR0 / 40.7247248D0 /

*
*  Coefficients for periodic terms (Meeus's Table 36.A)
*
*  The coefficients for term n in the series are:
*
*    IJSP(1,n)     J
*    IJSP(2,n)     S
*    IJSP(3,n)     P
*    AB(1,1,n)     longitude sine (degrees)
*    AB(2,1,n)     longitude cosine (degrees)
*    AB(1,2,n)     latitude sine (degrees)
*    AB(2,2,n)     latitude cosine (degrees)
*    AB(1,3,n)     radius vector sine (AU)
*    AB(2,3,n)     radius vector cosine (AU)
*
      DATA (IJSP(I, 1),I=1,3),((AB(J,I, 1),J=1,2),I=1,3) /
     :                             0,  0,  1,
     :            -19798886D-6,  19848454D-6,
     :             -5453098D-6, -14974876D-6,
     :             66867334D-7,  68955876D-7 /
      DATA (IJSP(I, 2),I=1,3),((AB(J,I, 2),J=1,2),I=1,3) /
     :                             0,  0,  2,
     :               897499D-6,  -4955707D-6,
     :              3527363D-6,   1672673D-6,
     :            -11826086D-7,   -333765D-7 /
      DATA (IJSP(I, 3),I=1,3),((AB(J,I, 3),J=1,2),I=1,3) /
     :                             0,  0,  3,
     :               610820D-6,   1210521D-6,
     :             -1050939D-6,    327763D-6,
     :              1593657D-7,  -1439953D-7 /
      DATA (IJSP(I, 4),I=1,3),((AB(J,I, 4),J=1,2),I=1,3) /
     :                             0,  0,  4,
     :              -341639D-6,   -189719D-6,
     :               178691D-6,   -291925D-6,
     :               -18948D-7,    482443D-7 /
      DATA (IJSP(I, 5),I=1,3),((AB(J,I, 5),J=1,2),I=1,3) /
     :                             0,  0,  5,
     :               129027D-6,    -34863D-6,
     :                18763D-6,    100448D-6,
     :               -66634D-7,    -85576D-7 /
      DATA (IJSP(I, 6),I=1,3),((AB(J,I, 6),J=1,2),I=1,3) /
     :                             0,  0,  6,
     :               -38215D-6,     31061D-6,
     :               -30594D-6,    -25838D-6,
     :                30841D-7,     -5765D-7 /
      DATA (IJSP(I, 7),I=1,3),((AB(J,I, 7),J=1,2),I=1,3) /
     :                             0,  1, -1,
     :                20349D-6,     -9886D-6,
     :                 4965D-6,     11263D-6,
     :                -6140D-7,     22254D-7 /
      DATA (IJSP(I, 8),I=1,3),((AB(J,I, 8),J=1,2),I=1,3) /
     :                             0,  1,  0,
     :                -4045D-6,     -4904D-6,
     :                  310D-6,      -132D-6,
     :                 4434D-7,      4443D-7 /
      DATA (IJSP(I, 9),I=1,3),((AB(J,I, 9),J=1,2),I=1,3) /
     :                             0,  1,  1,
     :                -5885D-6,     -3238D-6,
     :                 2036D-6,      -947D-6,
     :                -1518D-7,       641D-7 /
      DATA (IJSP(I,10),I=1,3),((AB(J,I,10),J=1,2),I=1,3) /
     :                             0,  1,  2,
     :                -3812D-6,      3011D-6,
     :                   -2D-6,      -674D-6,
     :                   -5D-7,       792D-7 /
      DATA (IJSP(I,11),I=1,3),((AB(J,I,11),J=1,2),I=1,3) /
     :                             0,  1,  3,
     :                 -601D-6,      3468D-6,
     :                 -329D-6,      -563D-6,
     :                  518D-7,       518D-7 /
      DATA (IJSP(I,12),I=1,3),((AB(J,I,12),J=1,2),I=1,3) /
     :                             0,  2, -2,
     :                 1237D-6,       463D-6,
     :                  -64D-6,        39D-6,
     :                  -13D-7,      -221D-7 /
      DATA (IJSP(I,13),I=1,3),((AB(J,I,13),J=1,2),I=1,3) /
     :                             0,  2, -1,
     :                 1086D-6,      -911D-6,
     :                  -94D-6,       210D-6,
     :                  837D-7,      -494D-7 /
      DATA (IJSP(I,14),I=1,3),((AB(J,I,14),J=1,2),I=1,3) /
     :                             0,  2,  0,
     :                  595D-6,     -1229D-6,
     :                   -8D-6,      -160D-6,
     :                 -281D-7,       616D-7 /
      DATA (IJSP(I,15),I=1,3),((AB(J,I,15),J=1,2),I=1,3) /
     :                             1, -1,  0,
     :                 2484D-6,      -485D-6,
     :                 -177D-6,       259D-6,
     :                  260D-7,      -395D-7 /
      DATA (IJSP(I,16),I=1,3),((AB(J,I,16),J=1,2),I=1,3) /
     :                             1, -1,  1,
     :                  839D-6,     -1414D-6,
     :                   17D-6,       234D-6,
     :                 -191D-7,      -396D-7 /
      DATA (IJSP(I,17),I=1,3),((AB(J,I,17),J=1,2),I=1,3) /
     :                             1,  0, -3,
     :                 -964D-6,      1059D-6,
     :                  582D-6,      -285D-6,
     :                -3218D-7,       370D-7 /
      DATA (IJSP(I,18),I=1,3),((AB(J,I,18),J=1,2),I=1,3) /
     :                             1,  0, -2,
     :                -2303D-6,     -1038D-6,
     :                 -298D-6,       692D-6,
     :                 8019D-7,     -7869D-7 /
      DATA (IJSP(I,19),I=1,3),((AB(J,I,19),J=1,2),I=1,3) /
     :                             1,  0, -1,
     :                 7049D-6,       747D-6,
     :                  157D-6,       201D-6,
     :                  105D-7,     45637D-7 /
      DATA (IJSP(I,20),I=1,3),((AB(J,I,20),J=1,2),I=1,3) /
     :                             1,  0,  0,
     :                 1179D-6,      -358D-6,
     :                  304D-6,       825D-6,
     :                 8623D-7,      8444D-7 /
      DATA (IJSP(I,21),I=1,3),((AB(J,I,21),J=1,2),I=1,3) /
     :                             1,  0,  1,
     :                  393D-6,       -63D-6,
     :                 -124D-6,       -29D-6,
     :                 -896D-7,      -801D-7 /
      DATA (IJSP(I,22),I=1,3),((AB(J,I,22),J=1,2),I=1,3) /
     :                             1,  0,  2,
     :                  111D-6,      -268D-6,
     :                   15D-6,         8D-6,
     :                  208D-7,      -122D-7 /
      DATA (IJSP(I,23),I=1,3),((AB(J,I,23),J=1,2),I=1,3) /
     :                             1,  0,  3,
     :                  -52D-6,      -154D-6,
     :                    7D-6,        15D-6,
     :                 -133D-7,        65D-7 /
      DATA (IJSP(I,24),I=1,3),((AB(J,I,24),J=1,2),I=1,3) /
     :                             1,  0,  4,
     :                  -78D-6,       -30D-6,
     :                    2D-6,         2D-6,
     :                  -16D-7,         1D-7 /
      DATA (IJSP(I,25),I=1,3),((AB(J,I,25),J=1,2),I=1,3) /
     :                             1,  1, -3,
     :                  -34D-6,       -26D-6,
     :                    4D-6,         2D-6,
     :                  -22D-7,         7D-7 /
      DATA (IJSP(I,26),I=1,3),((AB(J,I,26),J=1,2),I=1,3) /
     :                             1,  1, -2,
     :                  -43D-6,         1D-6,
     :                    3D-6,         0D-6,
     :                   -8D-7,        16D-7 /
      DATA (IJSP(I,27),I=1,3),((AB(J,I,27),J=1,2),I=1,3) /
     :                             1,  1, -1,
     :                  -15D-6,        21D-6,
     :                    1D-6,        -1D-6,
     :                    2D-7,         9D-7 /
      DATA (IJSP(I,28),I=1,3),((AB(J,I,28),J=1,2),I=1,3) /
     :                             1,  1,  0,
     :                   -1D-6,        15D-6,
     :                    0D-6,        -2D-6,
     :                   12D-7,         5D-7 /
      DATA (IJSP(I,29),I=1,3),((AB(J,I,29),J=1,2),I=1,3) /
     :                             1,  1,  1,
     :                    4D-6,         7D-6,
     :                    1D-6,         0D-6,
     :                    1D-7,        -3D-7 /
      DATA (IJSP(I,30),I=1,3),((AB(J,I,30),J=1,2),I=1,3) /
     :                             1,  1,  3,
     :                    1D-6,         5D-6,
     :                    1D-6,        -1D-6,
     :                    1D-7,         0D-7 /
      DATA (IJSP(I,31),I=1,3),((AB(J,I,31),J=1,2),I=1,3) /
     :                             2,  0, -6,
     :                    8D-6,         3D-6,
     :                   -2D-6,        -3D-6,
     :                    9D-7,         5D-7 /
      DATA (IJSP(I,32),I=1,3),((AB(J,I,32),J=1,2),I=1,3) /
     :                             2,  0, -5,
     :                   -3D-6,         6D-6,
     :                    1D-6,         2D-6,
     :                    2D-7,        -1D-7 /
      DATA (IJSP(I,33),I=1,3),((AB(J,I,33),J=1,2),I=1,3) /
     :                             2,  0, -4,
     :                    6D-6,       -13D-6,
     :                   -8D-6,         2D-6,
     :                   14D-7,        10D-7 /
      DATA (IJSP(I,34),I=1,3),((AB(J,I,34),J=1,2),I=1,3) /
     :                             2,  0, -3,
     :                   10D-6,        22D-6,
     :                   10D-6,        -7D-6,
     :                  -65D-7,        12D-7 /
      DATA (IJSP(I,35),I=1,3),((AB(J,I,35),J=1,2),I=1,3) /
     :                             2,  0, -2,
     :                  -57D-6,       -32D-6,
     :                    0D-6,        21D-6,
     :                  126D-7,      -233D-7 /
      DATA (IJSP(I,36),I=1,3),((AB(J,I,36),J=1,2),I=1,3) /
     :                             2,  0, -1,
     :                  157D-6,       -46D-6,
     :                    8D-6,         5D-6,
     :                  270D-7,      1068D-7 /
      DATA (IJSP(I,37),I=1,3),((AB(J,I,37),J=1,2),I=1,3) /
     :                             2,  0,  0,
     :                   12D-6,       -18D-6,
     :                   13D-6,        16D-6,
     :                  254D-7,       155D-7 /
      DATA (IJSP(I,38),I=1,3),((AB(J,I,38),J=1,2),I=1,3) /
     :                             2,  0,  1,
     :                   -4D-6,         8D-6,
     :                   -2D-6,        -3D-6,
     :                  -26D-7,        -2D-7 /
      DATA (IJSP(I,39),I=1,3),((AB(J,I,39),J=1,2),I=1,3) /
     :                             2,  0,  2,
     :                   -5D-6,         0D-6,
     :                    0D-6,         0D-6,
     :                    7D-7,         0D-7 /
      DATA (IJSP(I,40),I=1,3),((AB(J,I,40),J=1,2),I=1,3) /
     :                             2,  0,  3,
     :                    3D-6,         4D-6,
     :                    0D-6,         1D-6,
     :                  -11D-7,         4D-7 /
      DATA (IJSP(I,41),I=1,3),((AB(J,I,41),J=1,2),I=1,3) /
     :                             3,  0, -2,
     :                   -1D-6,        -1D-6,
     :                    0D-6,         1D-6,
     :                    4D-7,       -14D-7 /
      DATA (IJSP(I,42),I=1,3),((AB(J,I,42),J=1,2),I=1,3) /
     :                             3,  0, -1,
     :                    6D-6,        -3D-6,
     :                    0D-6,         0D-6,
     :                   18D-7,        35D-7 /
      DATA (IJSP(I,43),I=1,3),((AB(J,I,43),J=1,2),I=1,3) /
     :                             3,  0,  0,
     :                   -1D-6,        -2D-6,
     :                    0D-6,         1D-6,
     :                   13D-7,         3D-7 /


*  Validate the planet number.
      IF (NP.LT.1.OR.NP.GT.9) THEN
         JSTAT=-1
         DO I=1,6
            PV(I)=0D0
         END DO
      ELSE

*     Separate algorithms for Pluto and the rest.
         IF (NP.NE.9) THEN

*        -----------------------
*        Mercury through Neptune
*        -----------------------

*        Time: Julian millennia since J2000.
            T=(DATE-51544.5D0)/365250D0

*        OK status unless remote epoch.
            IF (ABS(T).LE.1D0) THEN
               JSTAT=0
            ELSE
               JSTAT=1
            END IF

*        Compute the mean elements.
            DA=A(1,NP)+(A(2,NP)+A(3,NP)*T)*T
            DL=(3600D0*DLM(1,NP)+(DLM(2,NP)+DLM(3,NP)*T)*T)*AS2R
            DE=E(1,NP)+(E(2,NP)+E(3,NP)*T)*T
            DPE=MOD((3600D0*PI(1,NP)+(PI(2,NP)+PI(3,NP)*T)*T)*AS2R,D2PI)
            DI=(3600D0*DINC(1,NP)+(DINC(2,NP)+DINC(3,NP)*T)*T)*AS2R
            DO=MOD((3600D0*OMEGA(1,NP)
     :                        +(OMEGA(2,NP)+OMEGA(3,NP)*T)*T)*AS2R,D2PI)

*        Apply the trigonometric terms.
            DMU=0.35953620D0*T
            DO J=1,8
               ARGA=DKP(J,NP)*DMU
               ARGL=DKQ(J,NP)*DMU
               DA=DA+(CA(J,NP)*COS(ARGA)+SA(J,NP)*SIN(ARGA))*1D-7
               DL=DL+(CLO(J,NP)*COS(ARGL)+SLO(J,NP)*SIN(ARGL))*1D-7
            END DO
            ARGA=DKP(9,NP)*DMU
            DA=DA+T*(CA(9,NP)*COS(ARGA)+SA(9,NP)*SIN(ARGA))*1D-7
            DO J=9,10
               ARGL=DKQ(J,NP)*DMU
               DL=DL+T*(CLO(J,NP)*COS(ARGL)+SLO(J,NP)*SIN(ARGL))*1D-7
            END DO
            DL=MOD(DL,D2PI)

*        Daily motion.
            DM=GCON*SQRT((1D0+1D0/AMAS(NP))/(DA*DA*DA))

*        Make the prediction.
            CALL sla_PLANEL(DATE,1,DATE,DI,DO,DPE,DA,DE,DL,DM,PV,J)
            IF (J.LT.0) JSTAT=-2

         ELSE

*        -----
*        Pluto
*        -----

*        Time: Julian centuries since J2000.
            T=(DATE-51544.5D0)/36525D0

*        OK status unless remote epoch.
            IF (T.GE.-1.15D0.AND.T.LE.1D0) THEN
               JSTAT=0
            ELSE
               JSTAT=1
            END IF

*        Fundamental arguments (radians).
            DJ=(DJ0+DJD*T)*D2R
            DS=(DS0+DSD*T)*D2R
            DP=(DP0+DPD*T)*D2R

*        Initialize coefficients and derivatives.
            DO I=1,3
               WLBR(I)=0D0
               WLBRD(I)=0D0
            END DO

*        Term by term through Meeus Table 36.A.
            DO J=1,43

*           Argument and derivative (radians, radians per century).
               WJ=DBLE(IJSP(1,J))
               WS=DBLE(IJSP(2,J))
               WP=DBLE(IJSP(3,J))
               AL=WJ*DJ+WS*DS+WP*DP
               ALD=(WJ*DJD+WS*DSD+WP*DPD)*D2R

*           Functions of argument.
               SAL=SIN(AL)
               CAL=COS(AL)

*           Periodic terms in longitude, latitude, radius vector.
               DO I=1,3

*              A and B coefficients (deg, AU).
                  AC=AB(1,I,J)
                  BC=AB(2,I,J)

*              Periodic terms (deg, AU, deg/Jc, AU/Jc).
                  WLBR(I)=WLBR(I)+AC*SAL+BC*CAL
                  WLBRD(I)=WLBRD(I)+(AC*CAL-BC*SAL)*ALD
               END DO
            END DO

*        Heliocentric longitude and derivative (radians, radians/sec).
            DL=(DL0+DLD0*T+WLBR(1))*D2R
            DLD=(DLD0+WLBRD(1))*D2R/SPC

*        Heliocentric latitude and derivative (radians, radians/sec).
            DB=(DB0+WLBR(2))*D2R
            DBD=WLBRD(2)*D2R/SPC

*        Heliocentric radius vector and derivative (AU, AU/sec).
            DR=DR0+WLBR(3)
            DRD=WLBRD(3)/SPC

*        Functions of latitude, longitude, radius vector.
            SL=SIN(DL)
            CL=COS(DL)
            SB=SIN(DB)
            CB=COS(DB)
            SLCB=SL*CB
            CLCB=CL*CB

*        Heliocentric vector and derivative, J2000 ecliptic and equinox.
            X=DR*CLCB
            Y=DR*SLCB
            Z=DR*SB
            XD=DRD*CLCB-DR*(CL*SB*DBD+SLCB*DLD)
            YD=DRD*SLCB+DR*(-SL*SB*DBD+CLCB*DLD)
            ZD=DRD*SB+DR*CB*DBD

*        Transform to J2000 equator and equinox.
            PV(1)=X
            PV(2)=Y*CE-Z*SE
            PV(3)=Y*SE+Z*CE
            PV(4)=XD
            PV(5)=YD*CE-ZD*SE
            PV(6)=YD*SE+ZD*CE
         END IF
      END IF

      END

      SUBROUTINE sla_DMXV (DM, VA, VB)
*+
*     - - - - -
*      D M X V
*     - - - - -
*
*  Performs the 3-D forward unitary transformation:
*
*     vector VB = matrix DM * vector VA
*
*  (double precision)
*
*  Given:
*     DM       dp(3,3)    matrix
*     VA       dp(3)      vector
*
*  Returned:
*     VB       dp(3)      result vector
*
*  P.T.Wallace   Starlink   March 1986
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DM(3,3),VA(3),VB(3)

      INTEGER I,J
      DOUBLE PRECISION W,VW(3)


*  Matrix DM * vector VA -> vector VW
      DO J=1,3
         W=0D0
         DO I=1,3
            W=W+DM(J,I)*VA(I)
         END DO
         VW(J)=W
      END DO

*  Vector VW -> vector VB
      DO J=1,3
         VB(J)=VW(J)
      END DO

      END

      SUBROUTINE sla_DCC2S (V, A, B)
*+
*     - - - - - -
*      D C C 2 S
*     - - - - - -
*
*  Direction cosines to spherical coordinates (double precision)
*
*  Given:
*     V     d(3)   x,y,z vector
*
*  Returned:
*     A,B   d      spherical coordinates in radians
*
*  The spherical coordinates are longitude (+ve anticlockwise
*  looking from the +ve latitude pole) and latitude.  The
*  Cartesian coordinates are right handed, with the x axis
*  at zero longitude and latitude, and the z axis at the
*  +ve latitude pole.
*
*  If V is null, zero A and B are returned.
*  At either pole, zero A is returned.
*
*  P.T.Wallace   Starlink   July 1989
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION V(3),A,B

      DOUBLE PRECISION X,Y,Z,R


      X = V(1)
      Y = V(2)
      Z = V(3)
      R = SQRT(X*X+Y*Y)

      IF (R.EQ.0D0) THEN
         A = 0D0
      ELSE
         A = ATAN2(Y,X)
      END IF

      IF (Z.EQ.0D0) THEN
         B = 0D0
      ELSE
         B = ATAN2(Z,R)
      END IF

      END

      DOUBLE PRECISION FUNCTION sla_DRANRM (ANGLE)
*+
*     - - - - - - -
*      D R A N R M
*     - - - - - - -
*
*  Normalize angle into range 0-2 pi  (double precision)
*
*  Given:
*     ANGLE     dp      the angle in radians
*
*  The result is ANGLE expressed in the range 0-2 pi (double
*  precision).
*
*  P.T.Wallace   Starlink   23 November 1995
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION ANGLE

      DOUBLE PRECISION D2PI
      PARAMETER (D2PI=6.283185307179586476925286766559D0)


      sla_DRANRM=MOD(ANGLE,D2PI)
      IF (sla_DRANRM.LT.0D0) sla_DRANRM=sla_DRANRM+D2PI

      END


      SUBROUTINE sla_NUT (DATE, RMATN)
*+
*     - - - -
*      N U T
*     - - - -
*
*  Form the matrix of nutation for a given date - IAU 1980 theory
*  (double precision)
*
*  References:
*     Final report of the IAU Working Group on Nutation,
*      chairman P.K.Seidelmann, 1980.
*     Kaplan,G.H., 1981, USNO circular no. 163, pA3-6.
*
*  Given:
*     DATE   dp         TDB (loosely ET) as Modified Julian Date
*                                           (=JD-2400000.5)
*  Returned:
*     RMATN  dp(3,3)    nutation matrix
*
*  The matrix is in the sense   V(true)  =  RMATN * V(mean)
*
*  Called:   sla_NUTC, sla_DEULER
*
*  P.T.Wallace   Starlink   1 January 1993
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,RMATN(3,3)

      DOUBLE PRECISION DPSI,DEPS,EPS0



*  Nutation components and mean obliquity
      CALL sla_NUTC(DATE,DPSI,DEPS,EPS0)

*  Rotation matrix
      CALL sla_DEULER('XZX',EPS0,-DPSI,-(EPS0+DEPS),RMATN)

      END

      SUBROUTINE sla_GEOC (P, H, R, Z)
*+
*     - - - - -
*      G E O C
*     - - - - -
*
*  Convert geodetic position to geocentric (double precision)
*
*  Given:
*     P     dp     latitude (geodetic, radians)
*     H     dp     height above reference spheroid (geodetic, metres)
*
*  Returned:
*     R     dp     distance from Earth axis (AU)
*     Z     dp     distance from plane of Earth equator (AU)
*
*  Notes:
*     1)  Geocentric latitude can be obtained by evaluating ATAN2(Z,R).
*     2)  IAU 1976 constants are used.
*
*  Reference:
*     Green,R.M., Spherical Astronomy, CUP 1985, p98.
*
*  P.T.Wallace   Starlink   4th October 1989
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION P,H,R,Z

*  Earth equatorial radius (metres)
      DOUBLE PRECISION A0
      PARAMETER (A0=6378140D0)

*  Reference spheroid flattening factor and useful function
      DOUBLE PRECISION F,B
      PARAMETER (F=1D0/298.257D0,B=(1D0-F)**2)

*  Astronomical unit in metres
      DOUBLE PRECISION AU
      PARAMETER (AU=1.49597870D11)

      DOUBLE PRECISION SP,CP,C,S



*  Geodetic to geocentric conversion
      SP=SIN(P)
      CP=COS(P)
      C=1D0/SQRT(CP*CP+B*SP*SP)
      S=B*C
      R=(A0*C+H)*CP/AU
      Z=(A0*S+H)*SP/AU

      END

      SUBROUTINE sla_PREC (EP0, EP1, RMATP)
*+
*     - - - - -
*      P R E C
*     - - - - -
*
*  Form the matrix of precession between two epochs (IAU 1976, FK5)
*  (double precision)
*
*  Given:
*     EP0    dp         beginning epoch
*     EP1    dp         ending epoch
*
*  Returned:
*     RMATP  dp(3,3)    precession matrix
*
*  Notes:
*
*     1)  The epochs are TDB (loosely ET) Julian epochs.
*
*     2)  The matrix is in the sense   V(EP1)  =  RMATP * V(EP0)
*
*     3)  Though the matrix method itself is rigorous, the precession
*         angles are expressed through canonical polynomials which are
*         valid only for a limited time span.  There are also known
*         errors in the IAU precession rate.  The absolute accuracy
*         of the present formulation is better than 0.1 arcsec from
*         1960AD to 2040AD, better than 1 arcsec from 1640AD to 2360AD,
*         and remains below 3 arcsec for the whole of the period
*         500BC to 3000AD.  The errors exceed 10 arcsec outside the
*         range 1200BC to 3900AD, exceed 100 arcsec outside 4200BC to
*         5600AD and exceed 1000 arcsec outside 6800BC to 8200AD.
*         The SLALIB routine sla_PRECL implements a more elaborate
*         model which is suitable for problems spanning several
*         thousand years.
*
*  References:
*     Lieske,J.H., 1979. Astron.Astrophys.,73,282.
*      equations (6) & (7), p283.
*     Kaplan,G.H., 1981. USNO circular no. 163, pA2.
*
*  Called:  sla_DEULER
*
*  P.T.Wallace   Starlink   23 August 1996
*
*  Copyright (C) 1996 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION EP0,EP1,RMATP(3,3)

*  Arc seconds to radians
      DOUBLE PRECISION AS2R
      PARAMETER (AS2R=0.484813681109535994D-5)

      DOUBLE PRECISION T0,T,TAS2R,W,ZETA,Z,THETA



*  Interval between basic epoch J2000.0 and beginning epoch (JC)
      T0 = (EP0-2000D0)/100D0

*  Interval over which precession required (JC)
      T = (EP1-EP0)/100D0

*  Euler angles
      TAS2R = T*AS2R
      W = 2306.2181D0+(1.39656D0-0.000139D0*T0)*T0

      ZETA = (W+((0.30188D0-0.000344D0*T0)+0.017998D0*T)*T)*TAS2R
      Z = (W+((1.09468D0+0.000066D0*T0)+0.018203D0*T)*T)*TAS2R
      THETA = ((2004.3109D0+(-0.85330D0-0.000217D0*T0)*T0)
     :        +((-0.42665D0-0.000217D0*T0)-0.041833D0*T)*T)*TAS2R

*  Rotation matrix
      CALL sla_DEULER('ZYZ',-ZETA,THETA,-Z,RMATP)

      END

      SUBROUTINE sla_DMXM (A, B, C)
*+
*     - - - - -
*      D M X M
*     - - - - -
*
*  Product of two 3x3 matrices:
*
*      matrix C  =  matrix A  x  matrix B
*
*  (double precision)
*
*  Given:
*      A      dp(3,3)        matrix
*      B      dp(3,3)        matrix
*
*  Returned:
*      C      dp(3,3)        matrix result
*
*  To comply with the ANSI Fortran 77 standard, A, B and C must
*  be different arrays.  However, the routine is coded so as to
*  work properly on the VAX and many other systems even if this
*  rule is violated.
*
*  P.T.Wallace   Starlink   5 April 1990
*
*  Copyright (C) 1995 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION A(3,3),B(3,3),C(3,3)

      INTEGER I,J,K
      DOUBLE PRECISION W,WM(3,3)


*  Multiply into scratch matrix
      DO I=1,3
         DO J=1,3
            W=0D0
            DO K=1,3
               W=W+A(I,K)*B(K,J)
            END DO
            WM(I,J)=W
         END DO
      END DO

*  Return the result
      DO J=1,3
         DO I=1,3
            C(I,J)=WM(I,J)
         END DO
      END DO

      END

      SUBROUTINE sla_PLANEL (DATE, JFORM, EPOCH, ORBINC, ANODE, PERIH,
     :                       AORQ, E, AORL, DM, PV, JSTAT)
*+
*     - - - - - - -
*      P L A N E L
*     - - - - - - -
*
*  Heliocentric position and velocity of a planet, asteroid
*  or comet, starting from orbital elements.
*
*  Given:
*     DATE      d      date, Modified Julian Date (JD - 2400000.5)
*     JFORM     i      choice of element set (1-3, see Note 3, below)
*     EPOCH     d      epoch of elements (TT MJD)
*     ORBINC    d      inclination (radians)
*     ANODE     d      longitude of the ascending node (radians)
*     PERIH     d      longitude or argument of perihelion (radians)
*     AORQ      d      mean distance or perihelion distance (AU)
*     E         d      eccentricity
*     AORL      d      mean anomaly or longitude (radians, JFORM=1,2 only)
*     DM        d      daily motion (radians, JFORM=1 only)
*
*  Returned:
*     PV        d(6)   heliocentric x,y,z,xdot,ydot,zdot of date,
*                                       J2000 equatorial triad (AU,AU/s)
*     JSTAT     i      status:  0 = OK
*                              -1 = illegal JFORM
*                              -2 = illegal E
*                              -3 = illegal AORQ
*                              -4 = illegal DM
*                              -5 = failed to converge
*
*  Notes
*
*  1  DATE is the instant for which the prediction is required.  It is
*     in the TT timescale (formerly Ephemeris Time, ET) and is a
*     Modified Julian Date (JD-2400000.5).
*
*  2  The elements are with respect to the J2000 ecliptic and
*     equinox.
*
*  3  Three different element-format options are available:
*
*     Option JFORM=1, suitable for the major planets:
*
*     EPOCH  = epoch of elements (TT MJD)
*     ORBINC = inclination i (radians)
*     ANODE  = longitude of the ascending node, big omega (radians)
*     PERIH  = longitude of perihelion, curly pi (radians)
*     AORQ   = mean distance, a (AU)
*     E      = eccentricity, e
*     AORL   = mean longitude L (radians)
*     DM     = daily motion (radians)
*
*     Option JFORM=2, suitable for minor planets:
*
*     EPOCH  = epoch of elements (TT MJD)
*     ORBINC = inclination i (radians)
*     ANODE  = longitude of the ascending node, big omega (radians)
*     PERIH  = argument of perihelion, little omega (radians)
*     AORQ   = mean distance, a (AU)
*     E      = eccentricity, e
*     AORL   = mean anomaly M (radians)
*
*     Option JFORM=3, suitable for comets:
*
*     EPOCH  = epoch of perihelion (TT MJD)
*     ORBINC = inclination i (radians)
*     ANODE  = longitude of the ascending node, big omega (radians)
*     PERIH  = argument of perihelion, little omega (radians)
*     AORQ   = perihelion distance, q (AU)
*     E      = eccentricity, e
*
*  4  Unused elements (DM for JFORM=1 and AORL for JFORM=1,2) are
*     not accessed.
*
*  5  The reference frame for the result is equatorial and is with
*     respect to the mean equinox and ecliptic of epoch J2000.
*
*  6  The algorithm is adapted from the EPHSLA program of
*     D.H.P.Jones (private communication, 1996).  The method is
*     based on Stumpff's Universal Variables;  see Everhart and
*     Pitkin (1983, Am.J.Phys.51,712).
*
*  P.T.Wallace   Starlink   23 May 1997
*
*  Copyright (C) 1997 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER JFORM
      DOUBLE PRECISION EPOCH,ORBINC,ANODE,PERIH,AORQ,E,AORL,DM,PV(6)
      INTEGER JSTAT

*  Gaussian gravitational constant (exact)
      DOUBLE PRECISION GCON
      PARAMETER (GCON=0.01720209895D0)

*  Canonical days to seconds
      DOUBLE PRECISION CD2S
      PARAMETER (CD2S=GCON/86400D0)

*  Sin and cos of J2000 mean obliquity (IAU 1976)
      DOUBLE PRECISION SE,CE
      PARAMETER (SE=0.3977771559319137D0,
     :           CE=0.9174820620691818D0)

*  Test value for solution and maximum number of iterations
      DOUBLE PRECISION TEST
      INTEGER NITMAX
      PARAMETER (TEST=1D-11,NITMAX=20)

      INTEGER NIT,N

      DOUBLE PRECISION AM,W,PHT,ARGPH,Q,TF,ALPHA,ABA,SQA,
     :                 DT,FC,FP,PSI,PSJ,BETA,BS0,BS1,BS2,BS3,
     :                 FF,FDOT,PHS,SW,CW,SI,CI,SO,CO,
     :                 X,Y,Z,XDOT,YDOT,ZDOT,VF



*  Validate arguments.
      IF (JFORM.LT.1.OR.JFORM.GT.3) THEN
         JSTAT = -1
         GO TO 999
      END IF
      IF (E.LT.0D0.OR.(E.GE.1D0.AND.JFORM.NE.3)) THEN
         JSTAT = -2
         GO TO 999
      END IF
      IF (AORQ.LE.0D0) THEN
         JSTAT = -3
         GO TO 999
      END IF
      IF (JFORM.EQ.1.AND.DM.LE.0D0) THEN
         JSTAT = -4
         GO TO 999
      END IF

*
*  Transform elements into standard form:
*
*  AM    = mean anomaly (M)
*  PHT   = epoch of perihelion passage
*  ARGPH = argument of perihelion (little omega)
*  Q     = perihelion distance (q)
*
*  Also computed is TF, the ratio of the daily motion to
*  the "theoretical" value.

      IF (JFORM.EQ.1) THEN
         AM = AORL-PERIH
         W = SQRT(AORQ*AORQ*AORQ)/GCON
         PHT = EPOCH-AM*W
         ARGPH = PERIH-ANODE
         Q = AORQ*(1D0-E)
         TF = DM*W
      ELSE IF (JFORM.EQ.2) THEN
         AM = AORL
         PHT = EPOCH-AM*SQRT(AORQ*AORQ*AORQ)/GCON
         ARGPH = PERIH
         Q = AORQ*(1D0-E)
         TF = 1D0
      ELSE IF (JFORM.EQ.3) THEN
         AM = AORL
         PHT = EPOCH
         ARGPH = PERIH
         Q = AORQ
         TF = 1D0
      END IF

*  The universal variable alpha.  This is proportional to the total
*  energy of the orbit:  -ve for an ellipse, zero for a parabola,
*  +ve for a hyperbola.

      ALPHA = (E-1D0)/Q
      ABA = ABS(ALPHA)
      SQA = SQRT(ABA)

*  Time from perihelion to date (in Canonical Days:  a canonical day
*  is 58.1324409... days, defined as 1/GCON).  The portion of the
*  time from the epoch to date is adjusted to take account of any
*  difference between the supplied and theoretical daily motion.

      DT = ((DATE-EPOCH)*TF+EPOCH-PHT)*GCON

*  First Approximation to the Universal Eccentric Anomaly, PSI,
*  based on the circle (FC) and parabola (FP) values.

      FC = DT/Q
      W = (3D0*DT+SQRT(9D0*DT*DT+8D0*Q*Q*Q))**(1D0/3D0)
      FP = W-2D0*Q/W
      PSI = (1D0-E)*FC+E*FP

*  Successive Approximations to Universal Eccentric Anomaly.

      NIT=1
      W=1D0
      DO WHILE (ABS(W).GE.TEST)

*     Compute the Universal Variables BS0, BS1, BS2, BS3.

*     Form half angles until BETA below maximum (0.7).
         N = 0
         PSJ = PSI
         BETA = ALPHA*PSI*PSI
         DO WHILE (ABS(BETA).GT.0.7D0)
            N = N+1
            BETA = BETA/4D0
            PSJ = PSJ/2D0
         END DO

*     Calculate Universal Variables by nested series.
         BS3 = PSJ*PSJ*PSJ*((((((BETA/210D0+1D0)
     :                          *BETA/156D0+1D0)
     :                          *BETA/110D0+1D0)
     :                          *BETA/72D0+1D0)
     :                          *BETA/42D0+1D0)
     :                          *BETA/20D0+1D0)/6D0
         BS2 = PSJ*PSJ*((((((BETA/182D0+1D0)
     :                      *BETA/132D0+1D0)
     :                      *BETA/90D0+1D0)
     :                      *BETA/56D0+1D0)
     :                      *BETA/30D0+1D0)
     :                      *BETA/12D0+1D0)/2D0
         BS1 = PSJ+ALPHA*BS3
         BS0 = 1D0+ALPHA*BS2

*     Double angles until N vanishes.
         DO WHILE (N.GT.0)
            BS3 = 2D0*(BS0*BS3+PSJ*BS2)
            BS2 = 2D0*BS1*BS1
            BS1 = 2D0*BS0*BS1
            BS0 = 2D0*BS0*BS0-1D0
            N = N-1
            PSJ = 2D0*PSJ
         END DO

*     Improve the approximation.
         FF = Q*BS1+BS3-DT
         FDOT = Q*BS0+BS2
         W = FF/FDOT
         PSI = PSI-W
         IF (NIT.LT.NITMAX) THEN
            NIT = NIT+1
         ELSE
            JSTAT = -5
            GO TO 999
         END IF
      END DO

*  Speed at perihelion.

      PHS = SQRT(ALPHA+2D0/Q)

*  In a Cartesian coordinate system which has the x-axis pointing
*  to perihelion and the z-axis normal to the orbit (such that the
*  object orbits counter-clockwise as seen from +ve z), the
*  perihelion position and velocity vectors are:
*
*    position   [Q,0,0]
*    velocity   [0,PHS,0]
*
*  Using the Universal Variables we project these vectors to the
*  given date:

      X = Q-BS2
      Y = PHS*Q*BS1
      XDOT = -BS1/FDOT
      YDOT = PHS*(1D0-BS2/FDOT)

*  To express the results in J2000 equatorial coordinates we make a
*  series of four rotations of the Cartesian axes:
*
*            axis     Euler angle
*
*     1      z        argument of perihelion (little omega)
*     2      x        inclination (i)
*     3      z        longitude of the ascending node (big omega)
*     4      x        J2000 obliquity (epsilon)
*
*  In each case the rotation is clockwise as seen from the +ve end
*  of the axis concerned.

*  Functions of the Euler angles.
      SW = SIN(ARGPH)
      CW = COS(ARGPH)
      SI = SIN(ORBINC)
      CI = COS(ORBINC)
      SO = SIN(ANODE)
      CO = COS(ANODE)

*  Position.
      W = X*CW-Y*SW
      Y = X*SW+Y*CW
      X = W
      Z = Y*SI
      Y = Y*CI
      W = X*CO-Y*SO
      Y = X*SO+Y*CO
      PV(1) = W
      PV(2) = Y*CE-Z*SE
      PV(3) = Y*SE+Z*CE

*  Velocity (scaled to AU/s and adjusted for daily motion).
      W = XDOT*CW-YDOT*SW
      YDOT = XDOT*SW+YDOT*CW
      XDOT = W
      ZDOT = YDOT*SI
      YDOT = YDOT*CI
      W = XDOT*CO-YDOT*SO
      YDOT = XDOT*SO+YDOT*CO
      VF = TF*CD2S
      PV(4) = VF*W
      PV(5) = VF*(YDOT*CE-ZDOT*SE)
      PV(6) = VF*(YDOT*SE+ZDOT*CE)

*  Wrap up.
      JSTAT = 0
 999  CONTINUE

      END

      SUBROUTINE sla_NUTC (DATE, DPSI, DEPS, EPS0)
*+
*     - - - - -
*      N U T C
*     - - - - -
*
*  Nutation:  longitude & obliquity components and mean
*  obliquity - IAU 1980 theory (double precision)
*
*  Given:
*
*     DATE        dp    TDB (loosely ET) as Modified Julian Date
*                                            (JD-2400000.5)
*  Returned:
*
*     DPSI,DEPS   dp    nutation in longitude,obliquity
*     EPS0        dp    mean obliquity
*
*  References:
*     Final report of the IAU Working Group on Nutation,
*      chairman P.K.Seidelmann, 1980.
*     Kaplan,G.H., 1981, USNO circular no. 163, pA3-6.
*
*  P.T.Wallace   Starlink   23 August 1996
*
*  Copyright (C) 1996 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE,DPSI,DEPS,EPS0

      DOUBLE PRECISION T2AS,AS2R,U2R
      DOUBLE PRECISION T,EL,EL2,EL3
      DOUBLE PRECISION ELP,ELP2
      DOUBLE PRECISION F,F2,F4
      DOUBLE PRECISION D,D2,D4
      DOUBLE PRECISION OM,OM2
      DOUBLE PRECISION DP,DE
      DOUBLE PRECISION A


*  Turns to arc seconds
      PARAMETER (T2AS=1296000D0)
*  Arc seconds to radians
      PARAMETER (AS2R=0.484813681109535994D-5)
*  Units of 0.0001 arcsec to radians
      PARAMETER (U2R=AS2R/1D4)




*  Interval between basic epoch J2000.0 and current epoch (JC)
      T=(DATE-51544.5D0)/36525D0

*
*  FUNDAMENTAL ARGUMENTS in the FK5 reference system
*

*  Mean longitude of the Moon minus mean longitude of the Moon's perigee
      EL=AS2R*(485866.733D0+(1325D0*T2AS+715922.633D0
     :         +(31.310D0+0.064D0*T)*T)*T)

*  Mean longitude of the Sun minus mean longitude of the Sun's perigee
      ELP=AS2R*(1287099.804D0+(99D0*T2AS+1292581.224D0
     :         +(-0.577D0-0.012D0*T)*T)*T)

*  Mean longitude of the Moon minus mean longitude of the Moon's node
      F=AS2R*(335778.877D0+(1342D0*T2AS+295263.137D0
     :         +(-13.257D0+0.011D0*T)*T)*T)

*  Mean elongation of the Moon from the Sun
      D=AS2R*(1072261.307D0+(1236D0*T2AS+1105601.328D0
     :         +(-6.891D0+0.019D0*T)*T)*T)

*  Longitude of the mean ascending node of the lunar orbit on the
*   ecliptic, measured from the mean equinox of date
      OM=AS2R*(450160.280D0+(-5D0*T2AS-482890.539D0
     :         +(7.455D0+0.008D0*T)*T)*T)

*  Multiples of arguments
      EL2=EL+EL
      EL3=EL2+EL
      ELP2=ELP+ELP
      F2=F+F
      F4=F2+F2
      D2=D+D
      D4=D2+D2
      OM2=OM+OM


*
*  SERIES FOR THE NUTATION
*
      DP=0D0
      DE=0D0

*  106
      DP=DP+SIN(ELP+D)
*  105
      DP=DP-SIN(F2+D4+OM2)
*  104
      DP=DP+SIN(EL2+D2)
*  103
      DP=DP-SIN(EL-F2+D2)
*  102
      DP=DP-SIN(EL+ELP-D2+OM)
*  101
      DP=DP-SIN(-ELP+F2+OM)
*  100
      DP=DP-SIN(EL-F2-D2)
*  99
      DP=DP-SIN(ELP+D2)
*  98
      DP=DP-SIN(F2-D+OM2)
*  97
      DP=DP-SIN(-F2+OM)
*  96
      DP=DP+SIN(-EL-ELP+D2+OM)
*  95
      DP=DP+SIN(ELP+F2+OM)
*  94
      DP=DP-SIN(EL+F2-D2)
*  93
      DP=DP+SIN(EL3+F2-D2+OM2)
*  92
      DP=DP+SIN(F4-D2+OM2)
*  91
      DP=DP-SIN(EL+D2+OM)
*  90
      DP=DP-SIN(EL2+F2+D2+OM2)
*  89
      A=EL2+F2-D2+OM
      DP=DP+SIN(A)
      DE=DE-COS(A)
*  88
      DP=DP+SIN(EL-ELP-D2)
*  87
      DP=DP+SIN(-EL+F4+OM2)
*  86
      A=-EL2+F2+D4+OM2
      DP=DP-SIN(A)
      DE=DE+COS(A)
*  85
      A=EL+F2+D2+OM
      DP=DP-SIN(A)
      DE=DE+COS(A)
*  84
      A=EL+ELP+F2-D2+OM2
      DP=DP+SIN(A)
      DE=DE-COS(A)
*  83
      DP=DP-SIN(EL2-D4)
*  82
      A=-EL+F2+D4+OM2
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
*  81
      A=-EL2+F2+D2+OM2
      DP=DP+SIN(A)
      DE=DE-COS(A)
*  80
      DP=DP-SIN(EL-D4)
*  79
      A=-EL+OM2
      DP=DP+SIN(A)
      DE=DE-COS(A)
*  78
      A=F2+D+OM2
      DP=DP+2D0*SIN(A)
      DE=DE-COS(A)
*  77
      DP=DP+2D0*SIN(EL3)
*  76
      A=EL+OM2
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
*  75
      A=EL2+OM
      DP=DP+2D0*SIN(A)
      DE=DE-COS(A)
*  74
      A=-EL+F2-D2+OM
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
*  73
      A=EL+ELP+F2+OM2
      DP=DP+2D0*SIN(A)
      DE=DE-COS(A)
*  72
      A=-ELP+F2+D2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
*  71
      A=EL3+F2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
*  70
      A=-EL2+OM
      DP=DP-2D0*SIN(A)
      DE=DE+COS(A)
*  69
      A=-EL-ELP+F2+D2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
*  68
      A=EL-ELP+F2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+COS(A)
*  67
      DP=DP+3D0*SIN(EL+F2)
*  66
      DP=DP-3D0*SIN(EL+ELP)
*  65
      DP=DP-4D0*SIN(D)
*  64
      DP=DP+4D0*SIN(EL-F2)
*  63
      DP=DP-4D0*SIN(ELP-D2)
*  62
      A=EL2+F2+OM
      DP=DP-5D0*SIN(A)
      DE=DE+3D0*COS(A)
*  61
      DP=DP+5D0*SIN(EL-ELP)
*  60
      A=-D2+OM
      DP=DP-5D0*SIN(A)
      DE=DE+3D0*COS(A)
*  59
      A=EL+F2-D2+OM
      DP=DP+6D0*SIN(A)
      DE=DE-3D0*COS(A)
*  58
      A=F2+D2+OM
      DP=DP-7D0*SIN(A)
      DE=DE+3D0*COS(A)
*  57
      A=D2+OM
      DP=DP-6D0*SIN(A)
      DE=DE+3D0*COS(A)
*  56
      A=EL2+F2-D2+OM2
      DP=DP+6D0*SIN(A)
      DE=DE-3D0*COS(A)
*  55
      DP=DP+6D0*SIN(EL+D2)
*  54
      A=EL+F2+D2+OM2
      DP=DP-8D0*SIN(A)
      DE=DE+3D0*COS(A)
*  53
      A=-ELP+F2+OM2
      DP=DP-7D0*SIN(A)
      DE=DE+3D0*COS(A)
*  52
      A=ELP+F2+OM2
      DP=DP+7D0*SIN(A)
      DE=DE-3D0*COS(A)
*  51
      DP=DP-7D0*SIN(EL+ELP-D2)
*  50
      A=-EL+F2+D2+OM
      DP=DP-10D0*SIN(A)
      DE=DE+5D0*COS(A)
*  49
      A=EL-D2+OM
      DP=DP-13D0*SIN(A)
      DE=DE+7D0*COS(A)
*  48
      A=-EL+D2+OM
      DP=DP+16D0*SIN(A)
      DE=DE-8D0*COS(A)
*  47
      A=-EL+F2+OM
      DP=DP+21D0*SIN(A)
      DE=DE-10D0*COS(A)
*  46
      DP=DP+26D0*SIN(F2)
      DE=DE-COS(F2)
*  45
      A=EL2+F2+OM2
      DP=DP-31D0*SIN(A)
      DE=DE+13D0*COS(A)
*  44
      A=EL+F2-D2+OM2
      DP=DP+29D0*SIN(A)
      DE=DE-12D0*COS(A)
*  43
      DP=DP+29D0*SIN(EL2)
      DE=DE-COS(EL2)
*  42
      A=F2+D2+OM2
      DP=DP-38D0*SIN(A)
      DE=DE+16D0*COS(A)
*  41
      A=EL+F2+OM
      DP=DP-51D0*SIN(A)
      DE=DE+27D0*COS(A)
*  40
      A=-EL+F2+D2+OM2
      DP=DP-59D0*SIN(A)
      DE=DE+26D0*COS(A)
*  39
      A=-EL+OM
      DP=DP+(-58D0-0.1D0*T)*SIN(A)
      DE=DE+32D0*COS(A)
*  38
      A=EL+OM
      DP=DP+(63D0+0.1D0*T)*SIN(A)
      DE=DE-33D0*COS(A)
*  37
      DP=DP+63D0*SIN(D2)
      DE=DE-2D0*COS(D2)
*  36
      A=-EL+F2+OM2
      DP=DP+123D0*SIN(A)
      DE=DE-53D0*COS(A)
*  35
      A=EL-D2
      DP=DP-158D0*SIN(A)
      DE=DE-COS(A)
*  34
      A=EL+F2+OM2
      DP=DP-301D0*SIN(A)
      DE=DE+(129D0-0.1D0*T)*COS(A)
*  33
      A=F2+OM
      DP=DP+(-386D0-0.4D0*T)*SIN(A)
      DE=DE+200D0*COS(A)
*  32
      DP=DP+(712D0+0.1D0*T)*SIN(EL)
      DE=DE-7D0*COS(EL)
*  31
      A=F2+OM2
      DP=DP+(-2274D0-0.2D0*T)*SIN(A)
      DE=DE+(977D0-0.5D0*T)*COS(A)
*  30
      DP=DP-SIN(ELP+F2-D2)
*  29
      DP=DP+SIN(-EL+D+OM)
*  28
      DP=DP+SIN(ELP+OM2)
*  27
      DP=DP-SIN(ELP-F2+D2)
*  26
      DP=DP+SIN(-F2+D2+OM)
*  25
      DP=DP+SIN(EL2+ELP-D2)
*  24
      DP=DP-4D0*SIN(EL-D)
*  23
      A=ELP+F2-D2+OM
      DP=DP+4D0*SIN(A)
      DE=DE-2D0*COS(A)
*  22
      A=EL2-D2+OM
      DP=DP+4D0*SIN(A)
      DE=DE-2D0*COS(A)
*  21
      A=-ELP+F2-D2+OM
      DP=DP-5D0*SIN(A)
      DE=DE+3D0*COS(A)
*  20
      A=-EL2+D2+OM
      DP=DP-6D0*SIN(A)
      DE=DE+3D0*COS(A)
*  19
      A=-ELP+OM
      DP=DP-12D0*SIN(A)
      DE=DE+6D0*COS(A)
*  18
      A=ELP2+F2-D2+OM2
      DP=DP+(-16D0+0.1D0*T)*SIN(A)
      DE=DE+7D0*COS(A)
*  17
      A=ELP+OM
      DP=DP-15D0*SIN(A)
      DE=DE+9D0*COS(A)
*  16
      DP=DP+(17D0-0.1D0*T)*SIN(ELP2)
*  15
      DP=DP-22D0*SIN(F2-D2)
*  14
      A=EL2-D2
      DP=DP+48D0*SIN(A)
      DE=DE+COS(A)
*  13
      A=F2-D2+OM
      DP=DP+(129D0+0.1D0*T)*SIN(A)
      DE=DE-70D0*COS(A)
*  12
      A=-ELP+F2-D2+OM2
      DP=DP+(217D0-0.5D0*T)*SIN(A)
      DE=DE+(-95D0+0.3D0*T)*COS(A)
*  11
      A=ELP+F2-D2+OM2
      DP=DP+(-517D0+1.2D0*T)*SIN(A)
      DE=DE+(224D0-0.6D0*T)*COS(A)
*  10
      DP=DP+(1426D0-3.4D0*T)*SIN(ELP)
      DE=DE+(54D0-0.1D0*T)*COS(ELP)
*  9
      A=F2-D2+OM2
      DP=DP+(-13187D0-1.6D0*T)*SIN(A)
      DE=DE+(5736D0-3.1D0*T)*COS(A)
*  8
      DP=DP+SIN(EL2-F2+OM)
*  7
      A=-ELP2+F2-D2+OM
      DP=DP-2D0*SIN(A)
      DE=DE+1D0*COS(A)
*  6
      DP=DP-3D0*SIN(EL-ELP-D)
*  5
      A=-EL2+F2+OM2
      DP=DP-3D0*SIN(A)
      DE=DE+1D0*COS(A)
*  4
      DP=DP+11D0*SIN(EL2-F2)
*  3
      A=-EL2+F2+OM
      DP=DP+46D0*SIN(A)
      DE=DE-24D0*COS(A)
*  2
      DP=DP+(2062D0+0.2D0*T)*SIN(OM2)
      DE=DE+(-895D0+0.5D0*T)*COS(OM2)
*  1
      DP=DP+(-171996D0-174.2D0*T)*SIN(OM)
      DE=DE+(92025D0+8.9D0*T)*COS(OM)

*  Convert results to radians
      DPSI=DP*U2R
      DEPS=DE*U2R

*  Mean obliquity
      EPS0=AS2R*(84381.448D0+
     :           (-46.8150D0+
     :           (-0.00059D0+
     :           0.001813D0*T)*T)*T)

      END

      SUBROUTINE sla_DEULER (ORDER, PHI, THETA, PSI, RMAT)
*+
*     - - - - - - -
*      D E U L E R
*     - - - - - - -
*
*  Form a rotation matrix from the Euler angles - three successive
*  rotations about specified Cartesian axes (double precision)
*
*  Given:
*    ORDER   c*(*)   specifies about which axes the rotations occur
*    PHI     d       1st rotation (radians)
*    THETA   d       2nd rotation (   "   )
*    PSI     d       3rd rotation (   "   )
*
*  Returned:
*    RMAT    d(3,3)  rotation matrix
*
*  A rotation is positive when the reference frame rotates
*  anticlockwise as seen looking towards the origin from the
*  positive region of the specified axis.
*
*  The characters of ORDER define which axes the three successive
*  rotations are about.  A typical value is 'ZXZ', indicating that
*  RMAT is to become the direction cosine matrix corresponding to
*  rotations of the reference frame through PHI radians about the
*  old Z-axis, followed by THETA radians about the resulting X-axis,
*  then PSI radians about the resulting Z-axis.
*
*  The axis names can be any of the following, in any order or
*  combination:  X, Y, Z, uppercase or lowercase, 1, 2, 3.  Normal
*  axis labelling/numbering conventions apply;  the xyz (=123)
*  triad is right-handed.  Thus, the 'ZXZ' example given above
*  could be written 'zxz' or '313' (or even 'ZxZ' or '3xZ').  ORDER
*  is terminated by length or by the first unrecognized character.
*
*  Fewer than three rotations are acceptable, in which case the later
*  angle arguments are ignored.  If all rotations are zero, the
*  identity matrix is produced.
*
*  P.T.Wallace   Starlink   23 May 1997
*
*  Copyright (C) 1997 Rutherford Appleton Laboratory
*-

      IMPLICIT NONE

      CHARACTER*(*) ORDER
      DOUBLE PRECISION PHI,THETA,PSI,RMAT(3,3)

      INTEGER J,I,L,N,K
      DOUBLE PRECISION RESULT(3,3),ROTN(3,3),ANGLE,S,C,W,WM(3,3)
      CHARACTER AXIS



*  Initialize result matrix
      DO J=1,3
         DO I=1,3
            IF (I.NE.J) THEN
               RESULT(I,J) = 0D0
            ELSE
               RESULT(I,J) = 1D0
            END IF
         END DO
      END DO

*  Establish length of axis string
      L = LEN(ORDER)

*  Look at each character of axis string until finished
      DO N=1,3
         IF (N.LE.L) THEN

*        Initialize rotation matrix for the current rotation
            DO J=1,3
               DO I=1,3
                  IF (I.NE.J) THEN
                     ROTN(I,J) = 0D0
                  ELSE
                     ROTN(I,J) = 1D0
                  END IF
               END DO
            END DO

*        Pick up the appropriate Euler angle and take sine & cosine
            IF (N.EQ.1) THEN
               ANGLE = PHI
            ELSE IF (N.EQ.2) THEN
               ANGLE = THETA
            ELSE
               ANGLE = PSI
            END IF
            S = SIN(ANGLE)
            C = COS(ANGLE)

*        Identify the axis
            AXIS = ORDER(N:N)
            IF (AXIS.EQ.'X'.OR.
     :          AXIS.EQ.'x'.OR.
     :          AXIS.EQ.'1') THEN

*           Matrix for x-rotation
               ROTN(2,2) = C
               ROTN(2,3) = S
               ROTN(3,2) = -S
               ROTN(3,3) = C

            ELSE IF (AXIS.EQ.'Y'.OR.
     :               AXIS.EQ.'y'.OR.
     :               AXIS.EQ.'2') THEN

*           Matrix for y-rotation
               ROTN(1,1) = C
               ROTN(1,3) = -S
               ROTN(3,1) = S
               ROTN(3,3) = C

            ELSE IF (AXIS.EQ.'Z'.OR.
     :               AXIS.EQ.'z'.OR.
     :               AXIS.EQ.'3') THEN

*           Matrix for z-rotation
               ROTN(1,1) = C
               ROTN(1,2) = S
               ROTN(2,1) = -S
               ROTN(2,2) = C

            ELSE

*           Unrecognized character - fake end of string
               L = 0

            END IF

*        Apply the current rotation (matrix ROTN x matrix RESULT)
            DO I=1,3
               DO J=1,3
                  W = 0D0
                  DO K=1,3
                     W = W+ROTN(I,K)*RESULT(K,J)
                  END DO
                  WM(I,J) = W
               END DO
            END DO
            DO J=1,3
               DO I=1,3
                  RESULT(I,J) = WM(I,J)
               END DO
            END DO

         END IF

      END DO

*  Copy the result
      DO J=1,3
         DO I=1,3
            RMAT(I,J) = RESULT(I,J)
         END DO
      END DO

      END
