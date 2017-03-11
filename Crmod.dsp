# Microsoft Developer Studio Project File - Name="crmod" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) External Target" 0x0106

CFG=crmod - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Crmod.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Crmod.mak" CFG="crmod - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "crmod - Win32 Release" (based on "Win32 (x86) External Target")
!MESSAGE "crmod - Win32 Debug" (based on "Win32 (x86) External Target")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""

!IF  "$(CFG)" == "crmod - Win32 Release"

# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Cmd_Line "NMAKE /f crmod.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "crmod.exe"
# PROP BASE Bsc_Name "crmod.bsc"
# PROP BASE Target_Dir ""
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Release"
# PROP Intermediate_Dir ".\Release"
# PROP Cmd_Line "make.bat"
# PROP Rebuild_Opt "/a"
# PROP Target_File "crmod.exe"
# PROP Bsc_Name "crmod.bsc"
# PROP Target_Dir ""

!ELSEIF  "$(CFG)" == "crmod - Win32 Debug"

# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\Debug"
# PROP BASE Intermediate_Dir ".\Debug"
# PROP BASE Cmd_Line "NMAKE /f crmod.mak"
# PROP BASE Rebuild_Opt "/a"
# PROP BASE Target_File "crmod.exe"
# PROP BASE Bsc_Name "crmod.bsc"
# PROP BASE Target_Dir ""
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\Debug"
# PROP Intermediate_Dir ".\Debug"
# PROP Cmd_Line "make.bat /O2"
# PROP Rebuild_Opt "/a"
# PROP Target_File "crmod.exe"
# PROP Bsc_Name "crmod.bsc"
# PROP Target_Dir ""

!ENDIF 

# Begin Target

# Name "crmod - Win32 Release"
# Name "crmod - Win32 Debug"

!IF  "$(CFG)" == "crmod - Win32 Release"

!ELSEIF  "$(CFG)" == "crmod - Win32 Debug"

!ENDIF 

# Begin Group "Source Files"

# PROP Default_Filter ".qc"
# Begin Source File

SOURCE=.\admin.qc
# End Source File
# Begin Source File

SOURCE=.\angles.qc
# End Source File
# Begin Source File

SOURCE=.\array.qc
# End Source File
# Begin Source File

SOURCE=.\auto.qc
# End Source File
# Begin Source File

SOURCE=.\buttons.qc
# End Source File
# Begin Source File

SOURCE=.\client.qc
# End Source File
# Begin Source File

SOURCE=.\combat.qc
# End Source File
# Begin Source File

SOURCE=.\console.qc
# End Source File
# Begin Source File

SOURCE=.\Debug.qc
# End Source File
# Begin Source File

SOURCE=.\defs.qc
# End Source File
# Begin Source File

SOURCE=.\display.qc
# End Source File
# Begin Source File

SOURCE=.\doors.qc
# End Source File
# Begin Source File

SOURCE=.\elodefs.qc
# End Source File
# Begin Source File

SOURCE=.\elohim.qc
# End Source File
# Begin Source File

SOURCE=.\internal.qc
# End Source File
# Begin Source File

SOURCE=.\items.qc
# End Source File
# Begin Source File

SOURCE=.\match.qc
# End Source File
# Begin Source File

SOURCE=.\misc.qc
# End Source File
# Begin Source File

SOURCE=.\models.qc
# End Source File
# Begin Source File

SOURCE=.\monsters.qc
# End Source File
# Begin Source File

SOURCE=.\motd.qc
# End Source File
# Begin Source File

SOURCE=.\name.qc
# End Source File
# Begin Source File

SOURCE=.\net.qc
# End Source File
# Begin Source File

SOURCE=.\observer.qc
# End Source File
# Begin Source File

SOURCE=.\options.qc
# End Source File
# Begin Source File

SOURCE=.\plats.qc
# End Source File
# Begin Source File

SOURCE=.\player.qc
# End Source File
# Begin Source File

SOURCE=.\progs.src
# End Source File
# Begin Source File

SOURCE=.\proquake.qc
# End Source File
# Begin Source File

SOURCE=.\qsmack.qc
# End Source File
# Begin Source File

SOURCE=.\quaketag.qc
# End Source File
# Begin Source File

SOURCE=.\quaketv.qc
# End Source File
# Begin Source File

SOURCE=.\Score.qc
# End Source File
# Begin Source File

SOURCE=.\sprites.qc
# End Source File
# Begin Source File

SOURCE=.\stats.qc
# End Source File
# Begin Source File

SOURCE=.\strings.qc
# End Source File
# Begin Source File

SOURCE=.\subs.qc
# End Source File
# Begin Source File

SOURCE=.\Training.qc
# End Source File
# Begin Source File

SOURCE=.\triggers.qc
# End Source File
# Begin Source File

SOURCE=.\userdefs.qc
# End Source File
# Begin Source File

SOURCE=.\utils.qc
# End Source File
# Begin Source File

SOURCE=.\votables.qc
# End Source File
# Begin Source File

SOURCE=.\vote.qc
# End Source File
# Begin Source File

SOURCE=.\weapons.qc
# End Source File
# Begin Source File

SOURCE=.\world.qc
# End Source File
# Begin Source File

SOURCE=.\zone.qc
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# End Group
# Begin Group "Release"

# PROP Default_Filter ".txt;.cfg;.scr"
# Begin Source File

SOURCE=\games\Quake\games\crmod\Release\autoexec.cfg
# End Source File
# Begin Source File

SOURCE=..\Release\ban.cfg
# End Source File
# Begin Source File

SOURCE=..\Release\crmod.cfg
# End Source File
# Begin Source File

SOURCE=\games\Quake\games\crmod\Release\levels.cfg
# End Source File
# Begin Source File

SOURCE=..\Release\manual.txt
# End Source File
# Begin Source File

SOURCE=..\Release\readme.txt
# End Source File
# Begin Source File

SOURCE=\games\Quake\games\crmod\Release\userdefs.cfg
# End Source File
# End Group
# Begin Group "HTML files"

# PROP Default_Filter ".html;.cgi"
# Begin Source File

SOURCE=..\html\download.html
# End Source File
# Begin Source File

SOURCE=..\html\help.html
# End Source File
# Begin Source File

SOURCE=..\html\index.html
# End Source File
# Begin Source File

SOURCE=..\html\main.html
# End Source File
# Begin Source File

SOURCE=..\html\manual.html
# End Source File
# Begin Source File

SOURCE=..\html\menu.html
# End Source File
# Begin Source File

SOURCE=..\html\moved.html
# End Source File
# Begin Source File

SOURCE=..\html\old_news1.html
# End Source File
# Begin Source File

SOURCE=..\html\servers.html
# End Source File
# Begin Source File

SOURCE=..\html\whatsnew.html
# End Source File
# End Group
# Begin Group "PERL files"

# PROP Default_Filter "pl"
# Begin Source File

SOURCE="..\html\cgi-bin\servers.pl"
# End Source File
# Begin Source File

SOURCE="..\html\cgi-bin\servers.txt"
# End Source File
# End Group
# Begin Source File

SOURCE=.\changes.log
# End Source File
# Begin Source File

SOURCE=.\Make.bat
# End Source File
# Begin Source File

SOURCE=..\html\menu.ssi
# End Source File
# Begin Source File

SOURCE=..\Userdefs.cfg
# End Source File
# End Target
# End Project
