@cd ..
@echo a > progs.dat
@del progs.dat
@cd source
..\fastqcc\release\fastqcc %1 %2 %3 %4 | more
@cd ..
crmake
rem @copy progs.dat e:
@cd source

