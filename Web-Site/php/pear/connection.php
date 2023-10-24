<?php
$conn=odbc_connect("ProdDBWebConnection","","");
if (!$conn)
  {exit("Connection Failed: " . $conn);}
?>  
