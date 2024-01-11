## .cshrc
# The following commands are automatically loaded at login
alias h history 100

if ($?prompt) then


source /usr/cad/synopsys/CIC/vcs.cshrc
# source /usr/cad/cadence/CIC/incisiv.cshrc
source /usr/cad/cadence/CIC/xcelium.cshrc
source /usr/cad/synopsys/CIC/verdi64.cshrc
source /usr/cad/synopsys/CIC/spyglass.cshrc
source /usr/cad/synopsys/CIC/synthesis.cshrc
source /usr/cad/synopsys/CIC/tmax.cshrc
source /usr/cad/synopsys/CIC/primetime.cshrc

source /usr/cad/cadence/CIC/license.cshrc
source /usr/cad/cadence/CIC/innovus.cshrc


endif
