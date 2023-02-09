@echo off

if NOT "x%1%" == "x" goto skip_usage
  call :usage
  exit /b
:skip_usage

set n_mpi=1
set n_openmp=1
set show_only=0
set stop_script=0
set use_openmp=0
set force_openmp=0
set have_casename=0
set show_version=0
set MPIEXEC_PORT_RANGE=
set MPICH_PORT_RANGE=
set debug=
set oversubscribed=
set casedir=
set use_default_casedir=
set "fabric="


call :getopts %*
if "%stop_script%" == "1" exit /b
call :set_openmp_defaults

if "x%IN_CMDFDS%" == "x1" goto skip_fdsinit
  echo setting up environment for fds
  call fdsinit
:skip_fdsinit

if "x%IN_CMDFDS%" == "x1" goto skip_NO_IN_CMDFDS
  echo ***Error: environment not setup for using fds
  echo type: fdsinit or use the CMDfds command shell
  exit /b
:skip_NO_IN_CMDFDS

if "%show_version%" == "0" goto skip_showversion
  mpiexec -localonly -n 1 fds
goto eof
:skip_showversion

if "%have_casename%" == "1" goto skip_casename_test
  echo ***error: an input file is missing
  call :usage
  echo .
  if "%show_only%" == "1" goto skip_casename_test
  exit /b
:skip_casename_test

set ECHO=
if "%show_only%" == "1" set ECHO=echo

if "%show_only%" == "1" goto skip1
if "x%use_default_casedir%" == "x" goto skip3
  set casedir=%casename:~0,-4%
:skip3
if "x%casedir%" == "x" goto skip2
if NOT exist %casedir% mkdir %casedir%
  echo @echo off            > %casedir%.bat
  echo smokeview %casedir% >> %casedir%.bat
  copy %casename% %casedir%
  cd %casedir%
:skip2
:skip1

:: placeholder names for openmp and non-openmp versions of fds

set fds_openmp=fds_openmp
set fds_non_openmp=fds

set fds=%fds_openmp%
set "openmp_env=-env OMP_NUM_THREADS %n_openmp%"

:: use non-openmp fds if number of threads is 1 and openmp is not being forced

if NOT "%n_openmp%" == "1" goto skip1
if "%force_openmp%" == "1" goto skip1
  set fds=%fds_non_openmp%
  set openmp_env=
:skip1

TITLE mpiexec -localonly -n %n_mpi% %openmp_env% %debug% %oversubscribed% %fabric% %fds% %casename%
%ECHO% mpiexec -localonly -n %n_mpi% %openmp_env% %debug% %oversubscribed% %fabric% %fds% %casename%

:eof
exit /b

:-------------------------------------------------------------------------
:----------------------subroutines----------------------------------------
:-------------------------------------------------------------------------

:-------------------------------------------------------------------------
:getopts
:-------------------------------------------------------------------------
 if (%1)==() exit /b

 set casename=%1
 set case1=%casename:~0,1%
 if "%case1%" == "-" goto skip_casename

   set have_casename=1
   if EXIST %casename% goto skip_casename_notexist
   if "%show_only%" == "1" goto skip_casename_notexist
      echo ***error: The input file %casename% does not exist
      set stop_script=1

 :skip_casename_notexist
 exit /b

 :skip_casename
 set valid=0
 set arg=%1
 if /I "%1" EQU "-p" (
   set valid=1
   set n_mpi=%2
   shift
 )
 if /I "%1" EQU "-c" (
   set valid=1
   set show_only=1
 )
 if /I "%1" EQU "-v" (
   set valid=1
   set show_version=1
 )
 if /I "%1" EQU "-d" (
   set valid=1
   set "debug=-env I_MPI_DEBUG=5"
 )
 if /I "%1" EQU "-F" (
   set valid=1
   set "fabric=-env I_MPI_FABRICS=%2"
   shift
 )
 if /I "%1" EQU "-h" (
   set valid=1
   set stop_script=1
   call :usage
   exit /b
 )
 if "%1" EQU "-o" (
   set valid=1
   set n_openmp=%2
   set use_openmp=1
   shift
 )
 if "%1" EQU "-f" (
   set valid=1
   set force_openmp=1
 )
 if "%1" EQU "-y" (
   set valid=1
   set casedir=%2
   shift
 )
 if "%1" EQU "-Y" (
   set valid=1
   set use_default_casedir=1
 )
 if "%1" EQU "-O" (
   set valid=1
   set "oversubscribed=-env I_MPI_WAIT_MODE=1"
 )
 shift
 if %valid% == 0 (
   echo.
   echo ***Error: the input argument %arg% is invalid
   echo.
   echo Usage:
   call :usage
   set stop_script=1
   exit /b
 )
if not (%1)==() goto getopts
exit /b

:-------------------------------------------------------------------------
:set_openmp_defaults
:-------------------------------------------------------------------------
:: if number of openmp threads are not specified then
:: set number of openmp threads to 1 if number of mpi processes > 1
:: set number of openmp threads to %OMP_NUM_THREADS% if number of mpi processes = 1

if "%use_openmp%" == "1" exit /b
if "%n_mpi%" == "1" set n_openmp=%OMP_NUM_THREADS%
if "%n_mpi%" == "1" exit /b
set n_openmp=1
exit /b

:-------------------------------------------------------------------------
:usage  
:-------------------------------------------------------------------------
echo.
echo Usage:
echo fds_local  [options] casename.fds
echo.
echo options:
echo -c     - show command line generated by this script (fds is not run)
echo -d     - add -env I_MPI_DEBUG=5 to the mpiexec line for debugging
echo -f     - force the openmp version of fds to be used even if the number of threads is 1
echo -F fabric - set I_MPI_FABRICS fabric variable
echo -h     - display this message
echo -p xx  - number of MPI processes [default: 1]
echo -o yy  - number of OpenMP threads per process [default: %OMP_NUM_THREADS% ]
echo          fds_local uses the non-OpenMP version of fds if the number of OpenMP threads
echo          specified per process is 1 unless the -f option is also specified
echo -O     - add -env I_MPI_WAIT=1 to the mpiexec line for use when your case is oversubscribed
echo -v     - show fds version information
echo -y dir - run casename.fds in directory dir
echo -Y     - run casename.fds in directory casename

exit /b
