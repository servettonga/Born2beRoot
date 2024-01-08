<?php
$output = file_get_contents('sysinfo.txt');

echo "<!DOCTYPE html>\n";
echo "<html>\n";
echo "<head>\n";
echo "    <title>System Information</title>\n";
echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n";
echo "    <style>\n";
echo "        pre {\n";
echo "            font-family: monospace;\n";
echo "            font-size: 14px;\n";
echo "            white-space: pre-wrap; /* Wrap long lines */\n";
echo "            word-break: break-all; /* Break words at any point */\n";
echo "        }\n";
echo "        @media (max-width: 600px) {\n";
echo "            pre {\n";
echo "                font-size: 12px; /* Reduce font size */\n";
echo "            }\n";
echo "        }\n";
echo "    </style>\n";
echo "</head>\n";
echo "<body>\n";
echo "    <pre>$output</pre>\n";
echo "</body>\n";
echo "</html>\n";
?>
