import re
from pyspark.sql import Row

log_pattern = '^([a-zA-Z]\S+ )?(\S+) (\S+) (\S+) \[([^\]]+)\] "(.*)" (\d+) (\S+) "(.*)"$'
def parse_apache_log_line(logline):
    match = re.search(log_pattern, logline)
    if match is None:
        # return None
        raise ValueError("Invalid logline: %s" % logline)
    return Row(
        ip =           match.group(2),
        clientIdentd = match.group(3),
        userid =       match.group(4),
        datetime =     match.group(5),
        httpinfo   =     match.group(6),
        # endpoint =     match.group(10),
        # protocol =     match.group(11),
        responsecode = int(match.group(7)),
        contentsize  = -1 if match.group(8) == '-' else long(match.group(8)),
        useragent    = match.group(9)
        )
