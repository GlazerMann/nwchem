      SUBROUTINE ccsdtq_lambda1_9_6_2(d_a,k_a_offset,d_b,k_b_offset,d_c,
     &k_c_offset)
C     $Id$
C     This is a Fortran77 program generated by Tensor Contraction Engine v.1.0
C     Copyright (c) Battelle & Pacific Northwest National Laboratory (2002)
C     i2 ( h11 h14 h13 p10 )_yt + = 5/18 * Sum ( h9 p8 p7 ) * t ( p7 p8 h9 h13 )_t * i3 ( h9 h11 h14 p7 p8 p10 )_y
      IMPLICIT NONE
#include "global.fh"
#include "mafdecls.fh"
#include "sym.fh"
#include "errquit.fh"
#include "tce.fh"
      INTEGER d_a
      INTEGER k_a_offset
      INTEGER d_b
      INTEGER k_b_offset
      INTEGER d_c
      INTEGER k_c_offset
      INTEGER NXTASK
      INTEGER next
      INTEGER nprocs
      INTEGER count
      INTEGER h11b
      INTEGER h14b
      INTEGER h13b
      INTEGER p10b
      INTEGER dimc
      INTEGER l_c_sort
      INTEGER k_c_sort
      INTEGER p7b
      INTEGER p8b
      INTEGER h9b
      INTEGER p7b_1
      INTEGER p8b_1
      INTEGER h13b_1
      INTEGER h9b_1
      INTEGER h11b_2
      INTEGER h14b_2
      INTEGER h9b_2
      INTEGER p10b_2
      INTEGER p7b_2
      INTEGER p8b_2
      INTEGER dim_common
      INTEGER dima_sort
      INTEGER dima
      INTEGER dimb_sort
      INTEGER dimb
      INTEGER l_a_sort
      INTEGER k_a_sort
      INTEGER l_a
      INTEGER k_a
      INTEGER l_b_sort
      INTEGER k_b_sort
      INTEGER l_b
      INTEGER k_b
      INTEGER nsuperp(2)
      INTEGER isuperp
      INTEGER l_c
      INTEGER k_c
      DOUBLE PRECISION FACTORIAL
      EXTERNAL NXTASK
      EXTERNAL FACTORIAL
      nprocs = GA_NNODES()
      count = 0
      next = NXTASK(nprocs,1)
      DO h11b = 1,noab
      DO h14b = h11b,noab
      DO h13b = 1,noab
      DO p10b = noab+1,noab+nvab
      IF (next.eq.count) THEN
      IF ((.not.restricted).or.(int_mb(k_spin+h11b-1)+int_mb(k_spin+h14b
     &-1)+int_mb(k_spin+h13b-1)+int_mb(k_spin+p10b-1).ne.8)) THEN
      IF (int_mb(k_spin+h11b-1)+int_mb(k_spin+h14b-1) .eq. int_mb(k_spin
     &+h13b-1)+int_mb(k_spin+p10b-1)) THEN
      IF (ieor(int_mb(k_sym+h11b-1),ieor(int_mb(k_sym+h14b-1),ieor(int_m
     &b(k_sym+h13b-1),int_mb(k_sym+p10b-1)))) .eq. ieor(irrep_y,irrep_t)
     &) THEN
      dimc = int_mb(k_range+h11b-1) * int_mb(k_range+h14b-1) * int_mb(k_
     &range+h13b-1) * int_mb(k_range+p10b-1)
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c_sort,k_c_sort)) CALL
     & ERRQUIT('ccsdtq_lambda1_9_6_2',0,MA_ERR)
      CALL DFILL(dimc,0.0d0,dbl_mb(k_c_sort),1)
      DO p7b = noab+1,noab+nvab
      DO p8b = p7b,noab+nvab
      DO h9b = 1,noab
      IF (int_mb(k_spin+p7b-1)+int_mb(k_spin+p8b-1) .eq. int_mb(k_spin+h
     &13b-1)+int_mb(k_spin+h9b-1)) THEN
      IF (ieor(int_mb(k_sym+p7b-1),ieor(int_mb(k_sym+p8b-1),ieor(int_mb(
     &k_sym+h13b-1),int_mb(k_sym+h9b-1)))) .eq. irrep_t) THEN
      CALL TCE_RESTRICTED_4(p7b,p8b,h13b,h9b,p7b_1,p8b_1,h13b_1,h9b_1)
      CALL TCE_RESTRICTED_6(h11b,h14b,h9b,p10b,p7b,p8b,h11b_2,h14b_2,h9b
     &_2,p10b_2,p7b_2,p8b_2)
      dim_common = int_mb(k_range+p7b-1) * int_mb(k_range+p8b-1) * int_m
     &b(k_range+h9b-1)
      dima_sort = int_mb(k_range+h13b-1)
      dima = dim_common * dima_sort
      dimb_sort = int_mb(k_range+h11b-1) * int_mb(k_range+h14b-1) * int_
     &mb(k_range+p10b-1)
      dimb = dim_common * dimb_sort
      IF ((dima .gt. 0) .and. (dimb .gt. 0)) THEN
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a_sort,k_a_sort)) CALL
     & ERRQUIT('ccsdtq_lambda1_9_6_2',1,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dima,'noname',l_a,k_a)) CALL ERRQUIT('
     &ccsdtq_lambda1_9_6_2',2,MA_ERR)
      IF ((h9b .le. h13b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h13b_
     &1 - 1 + noab * (h9b_1 - 1 + noab * (p8b_1 - noab - 1 + nvab * (p7b
     &_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p7b-1)
     &,int_mb(k_range+p8b-1),int_mb(k_range+h9b-1),int_mb(k_range+h13b-1
     &),4,3,2,1,1.0d0)
      END IF
      IF ((h13b .lt. h9b)) THEN
      CALL GET_HASH_BLOCK(d_a,dbl_mb(k_a),dima,int_mb(k_a_offset),(h9b_1
     & - 1 + noab * (h13b_1 - 1 + noab * (p8b_1 - noab - 1 + nvab * (p7b
     &_1 - noab - 1)))))
      CALL TCE_SORT_4(dbl_mb(k_a),dbl_mb(k_a_sort),int_mb(k_range+p7b-1)
     &,int_mb(k_range+p8b-1),int_mb(k_range+h13b-1),int_mb(k_range+h9b-1
     &),3,4,2,1,-1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_a)) CALL ERRQUIT('ccsdtq_lambda1_9_6_2',3,
     &MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b_sort,k_b_sort)) CALL
     & ERRQUIT('ccsdtq_lambda1_9_6_2',4,MA_ERR)
      IF (.not.MA_PUSH_GET(mt_dbl,dimb,'noname',l_b,k_b)) CALL ERRQUIT('
     &ccsdtq_lambda1_9_6_2',5,MA_ERR)
      IF ((h9b .le. h11b) .and. (p8b .le. p10b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p10b_
     &2 - noab - 1 + nvab * (p8b_2 - noab - 1 + nvab * (p7b_2 - noab - 1
     & + nvab * (h14b_2 - 1 + noab * (h11b_2 - 1 + noab * (h9b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h11b-1),int_mb(k_range+h14b-1),int_mb(k_range+p7b-
     &1),int_mb(k_range+p8b-1),int_mb(k_range+p10b-1),6,3,2,1,5,4,1.0d0)
      END IF
      IF ((h9b .le. h11b) .and. (p7b .le. p10b) .and. (p10b .lt. p8b)) T
     &HEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p8b_2
     & - noab - 1 + nvab * (p10b_2 - noab - 1 + nvab * (p7b_2 - noab - 1
     & + nvab * (h14b_2 - 1 + noab * (h11b_2 - 1 + noab * (h9b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h11b-1),int_mb(k_range+h14b-1),int_mb(k_range+p7b-
     &1),int_mb(k_range+p10b-1),int_mb(k_range+p8b-1),5,3,2,1,6,4,-1.0d0
     &)
      END IF
      IF ((h9b .le. h11b) .and. (p10b .lt. p7b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p8b_2
     & - noab - 1 + nvab * (p7b_2 - noab - 1 + nvab * (p10b_2 - noab - 1
     & + nvab * (h14b_2 - 1 + noab * (h11b_2 - 1 + noab * (h9b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h9b-1)
     &,int_mb(k_range+h11b-1),int_mb(k_range+h14b-1),int_mb(k_range+p10b
     &-1),int_mb(k_range+p7b-1),int_mb(k_range+p8b-1),4,3,2,1,6,5,1.0d0)
      END IF
      IF ((h11b .lt. h9b) .and. (h9b .le. h14b) .and. (p8b .le. p10b)) T
     &HEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p10b_
     &2 - noab - 1 + nvab * (p8b_2 - noab - 1 + nvab * (p7b_2 - noab - 1
     & + nvab * (h14b_2 - 1 + noab * (h9b_2 - 1 + noab * (h11b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h9b-1),int_mb(k_range+h14b-1),int_mb(k_range+p7b-
     &1),int_mb(k_range+p8b-1),int_mb(k_range+p10b-1),6,3,1,2,5,4,-1.0d0
     &)
      END IF
      IF ((h11b .lt. h9b) .and. (h9b .le. h14b) .and. (p7b .le. p10b) .a
     &nd. (p10b .lt. p8b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p8b_2
     & - noab - 1 + nvab * (p10b_2 - noab - 1 + nvab * (p7b_2 - noab - 1
     & + nvab * (h14b_2 - 1 + noab * (h9b_2 - 1 + noab * (h11b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h9b-1),int_mb(k_range+h14b-1),int_mb(k_range+p7b-
     &1),int_mb(k_range+p10b-1),int_mb(k_range+p8b-1),5,3,1,2,6,4,1.0d0)
      END IF
      IF ((h11b .lt. h9b) .and. (h9b .le. h14b) .and. (p10b .lt. p7b)) T
     &HEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p8b_2
     & - noab - 1 + nvab * (p7b_2 - noab - 1 + nvab * (p10b_2 - noab - 1
     & + nvab * (h14b_2 - 1 + noab * (h9b_2 - 1 + noab * (h11b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h9b-1),int_mb(k_range+h14b-1),int_mb(k_range+p10b
     &-1),int_mb(k_range+p7b-1),int_mb(k_range+p8b-1),4,3,1,2,6,5,-1.0d0
     &)
      END IF
      IF ((h14b .lt. h9b) .and. (p8b .le. p10b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p10b_
     &2 - noab - 1 + nvab * (p8b_2 - noab - 1 + nvab * (p7b_2 - noab - 1
     & + nvab * (h9b_2 - 1 + noab * (h14b_2 - 1 + noab * (h11b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h14b-1),int_mb(k_range+h9b-1),int_mb(k_range+p7b-
     &1),int_mb(k_range+p8b-1),int_mb(k_range+p10b-1),6,2,1,3,5,4,1.0d0)
      END IF
      IF ((h14b .lt. h9b) .and. (p7b .le. p10b) .and. (p10b .lt. p8b)) T
     &HEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p8b_2
     & - noab - 1 + nvab * (p10b_2 - noab - 1 + nvab * (p7b_2 - noab - 1
     & + nvab * (h9b_2 - 1 + noab * (h14b_2 - 1 + noab * (h11b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h14b-1),int_mb(k_range+h9b-1),int_mb(k_range+p7b-
     &1),int_mb(k_range+p10b-1),int_mb(k_range+p8b-1),5,2,1,3,6,4,-1.0d0
     &)
      END IF
      IF ((h14b .lt. h9b) .and. (p10b .lt. p7b)) THEN
      CALL GET_HASH_BLOCK(d_b,dbl_mb(k_b),dimb,int_mb(k_b_offset),(p8b_2
     & - noab - 1 + nvab * (p7b_2 - noab - 1 + nvab * (p10b_2 - noab - 1
     & + nvab * (h9b_2 - 1 + noab * (h14b_2 - 1 + noab * (h11b_2 - 1))))
     &)))
      CALL TCE_SORT_6(dbl_mb(k_b),dbl_mb(k_b_sort),int_mb(k_range+h11b-1
     &),int_mb(k_range+h14b-1),int_mb(k_range+h9b-1),int_mb(k_range+p10b
     &-1),int_mb(k_range+p7b-1),int_mb(k_range+p8b-1),4,2,1,3,6,5,1.0d0)
      END IF
      IF (.not.MA_POP_STACK(l_b)) CALL ERRQUIT('ccsdtq_lambda1_9_6_2',6,
     &MA_ERR)
      nsuperp(1) = 1
      nsuperp(2) = 1
      isuperp = 1
      IF (p7b .eq. p8b) THEN
      nsuperp(isuperp) = nsuperp(isuperp) + 1
      ELSE
      isuperp = isuperp + 1
      END IF
      CALL DGEMM('T','N',dima_sort,dimb_sort,dim_common,2.0d0/FACTORIAL(
     &nsuperp(1))/FACTORIAL(nsuperp(2)),dbl_mb(k_a_sort),dim_common,dbl_
     &mb(k_b_sort),dim_common,1.0d0,dbl_mb(k_c_sort),dima_sort)
      IF (.not.MA_POP_STACK(l_b_sort)) CALL ERRQUIT('ccsdtq_lambda1_9_6_
     &2',7,MA_ERR)
      IF (.not.MA_POP_STACK(l_a_sort)) CALL ERRQUIT('ccsdtq_lambda1_9_6_
     &2',8,MA_ERR)
      END IF
      END IF
      END IF
      END DO
      END DO
      END DO
      IF (.not.MA_PUSH_GET(mt_dbl,dimc,'noname',l_c,k_c)) CALL ERRQUIT('
     &ccsdtq_lambda1_9_6_2',9,MA_ERR)
      CALL TCE_SORT_4(dbl_mb(k_c_sort),dbl_mb(k_c),int_mb(k_range+p10b-1
     &),int_mb(k_range+h14b-1),int_mb(k_range+h11b-1),int_mb(k_range+h13
     &b-1),3,2,4,1,5.0d0/18.0d0)
      CALL ADD_HASH_BLOCK(d_c,dbl_mb(k_c),dimc,int_mb(k_c_offset),(p10b 
     &- noab - 1 + nvab * (h13b - 1 + noab * (h14b - 1 + noab * (h11b - 
     &1)))))
      IF (.not.MA_POP_STACK(l_c)) CALL ERRQUIT('ccsdtq_lambda1_9_6_2',10
     &,MA_ERR)
      IF (.not.MA_POP_STACK(l_c_sort)) CALL ERRQUIT('ccsdtq_lambda1_9_6_
     &2',11,MA_ERR)
      END IF
      END IF
      END IF
      next = NXTASK(nprocs,1)
      END IF
      count = count + 1
      END DO
      END DO
      END DO
      END DO
      next = NXTASK(-nprocs,1)
      call GA_SYNC()
      RETURN
      END
