<?php
if (isset($_FILES["data"]) ) {
  $content_dir = "E:\\data\\visual_search\\uploads\\";
  $src_filename = $_FILES["file"]["tmp_name"];
  $dst_filename = $_FILES["file"]["name"];
  $dst_filename = str_replace("/", "_", $dst_filename);
  //print "src_filename".$src_filename."\n";
  //print "dst_filename=".$dst_filename."\n";
  move_uploaded_file( $src_filename, $content_dir . '/' . $dst_filename);
}
?>

[<?php echo $_POST['tag_name'] ?>]
