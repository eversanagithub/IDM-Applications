<?php
$conn=odbc_connect("DBWebConnection","","");
if (!$conn)
  {exit("Connection Failed: " . $conn);}
?>  
