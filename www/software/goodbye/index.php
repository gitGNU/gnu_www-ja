<?php

$goodbye=$_POST['goodbye'];
$actual=$_POST['actual'];

if ($actual) {

  $u=$_POST['user'];
  $a=$_POST['arg'];
  $h=$_POST['hash'];

  $f = fopen('http://fencepost.gnu.org/' . $u . ':' . $a . ':' . $h,'r');
  $contents = '';
    while (!feof($f)) {
    $contents .= fread($f, 8192);
  }

  header("Content-Type: application/octet-stream; ");
  header("Content-Transfer-Encoding: binary"); 
  header("Content-Length: " . strlen($contents) ."; ");  
  header("Content-Disposition: attachment; filename='goodbye-" . $u . "=" . $a  . "'");
  flush();
  echo $contents;

 } else {

?>

<!DOCTYPE html>
<html>
<head>
<title>GNU Goodbye</title>
</head>
<body>

<h1>GNU Goodbye</h1>
<?php

  if (!$goodbye) {

?>

<p>The GNU Goodbye program is intending to produce a familiar, friendly farewell. In many ways, it could be considered a sister-program to <a href="/software/hello/">GNU Hello</a>, but unlike GNU Hello, it has not yet been developed.</p>

<form method="post">
<p><input type="submit" value="Say Goodbye!" name="goodbye" /></p>
</form>

<?php

    } 

 else {

 include('form.php');

 }
 }

?>
