pdsh -g cn "ps axo pid=,stat= | grep Z" 2> /dev/null
pdsh -g login "ps axo pid=,stat= | grep Z" 2> /dev/null
pdsh -g viz "ps axo pid=,stat= | grep Z" 2> /dev/null
