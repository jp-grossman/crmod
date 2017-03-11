@cd ..
@echo a > progs.dat
@del progs.dat
@cd source
..\fastqcc\release\qccx /O2 %1 %2 %3 %4 %5 %6
@cd ..
crmake
@REM @copy progs.dat e:
@cd source

