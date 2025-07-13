0. У вас должен быть установлен Матлаб 914 R2023a

1. Смонтируйте iso-образ  Matlab914_R2023a_Docs.iso  в виртуальный диск
     На виндовз 8 и ниже для этого может потребоваться программа типа Daemon Tools Lite (или любая подобная)

2. Если работаете под виндовз то просто запустите двойным щелчком  "Install_Docs.cmd"
     Если установка не сработает то запустите этот cmd-файл с параметром  "<matlabfolder>"  тем способом каким умеете
       Скажем через Win+R надо писать полное имя до cmd-файла, т.е. вам надо будет написать что-то типа:  X:\Install_Docs.cmd "C:\Matlab\914"
       Где "X" - это буква куда примонтировался iso-образ, а "C:\Matlab\914" - папка куда вы поставили Matlab
     Ну либо делайте все по инструкции мафворкса, без cmd-помогашек, т.е. запускайте, скажем через Win+R, команду вроде
       R:\Win\bin\win64\mpm.exe  install-doc  --matlabroot="C:\Program Files\MATLAB\R2023a"

   Если работаете под линукс то просто запустите  "install_docs.sh"
     Если установка не сработает то запустите этот sh-файл с параметром  "<matlabfolder>"
     Ну либо делайте все по инструкции мафворкса, без sh-помогашек, т.е. перейдите в терминале в подпапку "Lin/bin/glnxa64" и запустите команду типа
       ./mpm install-doc --matlabroot="<matlabfolder>"
         где <matlabfolder> - папка куда вы установили Матлаб 9.14 R2023a (например  "/home/user/matlab/914")

3. В матлабе в  Preferences -> Help -> Documentation Location  выберите  "Installed Locally"


P.S.
Пока не поставите локальную документацию любой запрос информации в матлабе будет требовать предоставления ему доступа в интернет
Документация ставится не вся, а лишь под установленный набор компонентов матлаба
А значит если вы нарастите состав компонентов матлаба, то вам надо повторить еще раз установку документации



0. You must have installed  Matlab 914 R2023a

1. Mount iso-file  Matlab914_R2023a_Docs.iso  to virtual disk
     For Windows 8 and lower you probably need soft like Daemon Tools Lite (or similar)

2. If you work under Windows then just double-click on  "InstallDocs_Win.cmd"
     If it does not work out then run the cmd-file with parameter  "<matlabfolder>"  the way you can
       For example via Win+R you need to write full cmd-file name, so you need to write something like:  X:\InstallDocs_Win.cmd "C:\Matlab\914"
       Where "X" - is drive letter of mounted iso-file, and "C:\Matlab\914" - is folder where you installed Matlab
     Or do according to mathworks docs, without cmd-helpers. For example run via Win+R command like
       X:\Win\bin\win64\mpm.exe  install-doc  --matlabroot="C:\Matlab\914"

   If you work under Linux then in terminal goto mounted iso-file subfolder  "Lin/bin/glnxa64"  and execute command like
     ./mpm install-doc --matlabroot="<matlabfolder>"
       where <matlabfolder> - is path where you installed Matlab 9.14 R2023a (for example  "/home/user/matlab/914")

3. In Matlab in  Preferences -> Help -> Documentation Location  select  "Installed Locally"


P.S.
Until you install offline documentation any information request inside matlab will require internet access
Not the whole offline documentation is installed, but only the one necessary for installed matlab components
This mean that if you increase the set of installed matlab components then you need to repeat installation of docs
