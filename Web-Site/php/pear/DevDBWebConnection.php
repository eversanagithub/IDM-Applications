<?php
$conn=odbc_connect("DevDBWebConnection","","");
if (!$conn)
  {exit("Connection Failed: " . $conn);}
?>  
