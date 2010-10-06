<?php
  if ($_REQUEST["bindata"] === NULL) { 
    echo "missing parameter.";
  }
  else {
    $img_data = base64_decode($_REQUEST["bindata"]);
    $name = $_REQUEST["name"] === NULL ? "anonymous\n" : $_REQUEST["name"] ."\n";
    $name = strip_tags($name);
    $comment = strip_tags($_REQUEST["comment"]) . "\n";
    $img_size = strlen($img_data);
    if ($img_size < 10000000) {
      $img_filename = "search.jpg";
      $comment_filename = "data/comment.txt";
      unlink($img_filename);
      unlink($comment_filename);
      $img_file = fopen($img_filename, "w") or die("can't open file");
      fwrite($img_file, $img_data);
      fclose($img_file);
      echo "$img_size bytes uploaded.";
      // write comments
      var_dump($comment);
      $comment_lines = explode("\r", $comment);
      var_dump($comment_lines);
      $comment_file = fopen($comment_filename, "w");
      fwrite($comment_file, $name);
      foreach ($comment_lines as $line) {
        fwrite($comment_file, $line . "\n");
      }
      //fwrite($comment_file, $comment);
      fclose($comment_file);
    }
    else {
      echo "image too big.";
    }
  }
  //var_dump($_REQUEST);
?>

											       
