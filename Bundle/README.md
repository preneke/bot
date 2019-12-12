#  Bundling

This directory contains scripts for building FDS and Smokeview installers on Windows, Linux and OSX (Mac) computer platforms.
This README documents building installers for Linux and OSX.

The installaton script used to install FDS and Smokeview consist of applications (FDS, Smokeview and Smokeview utilities), 
documents ( User, Verification/Validation and Technical guides), other files and scripts.
The installer copies these files to the desired location.  

FDS and Smokeview applications are built by running
firebot  with the -B option.  This option causes only the applications to be built
not the usual running and checking of verification cases.  FDS and Smokeview manuals are generated
by running a complete firebot and smokebot. For now, the full bots are only run on a Linux system.  
Other files rquired to build the installer are found in the fds, smv and bot repos.

The process of building an installer then consists of four steps: 1. run firebot to generate FDS manuals, 2. run smokebot to generated 
Smokeview manuals, 3. build applications and finally 4. build the installer from the parts generated in the first 3 steps.
These steps are outlined in more detail below.

### Bundling Steps

1. Run firebot on a Linux system to generate FDS publications. If the firebot run is successful, documents are copied to the
directory $HOME/.firebot/pubs.  In addition, FDS and Smokeview applications are copied to the directory $HOME/.firebot/apps
where $HOME is the home directory of the user running firebot. At NIST this occurs nightly.
2. Run smokebot on a Linux system to generate Smokeview publications. Similarly if the smokebot run is successful, documents are copied
to the directory $HOME/.smokebot/pubs.  Note, firebot generates both FDS and Smokeview applications.
At NIST this occurs whenever FDS and/or Smokeview source changes or at least once a day if this source has not changed.
3. Run firebot with the -B option on the system where you are generating  the installer (OSX or Linux) to generate the applications. 
4. Generate an installer using the make_bundle.sh script located in the `Bundle/fds/scripts` directory.  