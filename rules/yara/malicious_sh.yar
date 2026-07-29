rule Malicious_Shell_Downloader {
    meta:
        author = "James Cooper"
        description = "Detects automated botnet stage-1 downloader scripts"
        date = "2026-07-28"
    strings:
        $s1 = "#!/bin/bash" ascii
        $s2 = "wget" ascii
        $s3 = "curl" ascii
        $s4 = "chmod +x" ascii
    condition:
        $s1 and ($s2 or $s3) and $s4
}
