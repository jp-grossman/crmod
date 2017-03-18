@echo a > ..\progs.dat
@del ..\progs.dat
utils\qccx /O2 %1 %2 %3 %4 %5 %6
utils\crmake ..

