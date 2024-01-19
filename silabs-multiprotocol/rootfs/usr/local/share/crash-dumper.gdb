break _exit
commands
python import time, os
python os.makedirs("/share/silabs_multiprotocol_crash_dumps", exist_ok=True)
python logfile = time.strftime('crash_%Y%m%d_%H%M%S.log')
python gdb.execute('set logging file /share/silabs_multiprotocol_crash_dumps/' + logfile)
set pagination off
set logging enabled on
set var $ptr=0x20000000
while $ptr < 0x20018000
x/4wx $ptr
set var $ptr+=16
end
info all-registers
set logging enabled off
set pagination on
monitor reset
cont
end