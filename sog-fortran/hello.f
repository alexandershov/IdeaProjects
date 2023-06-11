      DIMENSION IA(9999)
10    FORMAT (I4/(I4))
      READ 10, I, (IA(J), J=1,I)
      ISUM = 0
      DO 20 J = 1,I
      ISUM = ISUM + IA(J)
20    CONTINUE
30    FORMAT (I4)
      PRINT 30, (ISUM)
      END
