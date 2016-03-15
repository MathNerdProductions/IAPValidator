<?php

$receipt = $_GET["receipt"];

//Create JSON data
$json = array(
	"receipt-data" => $receipt
);

$jsonData = json_encode($json);

$url = "https://buy.itunes.apple.com/verifyReceipt";
$curl = curl_init($url);
curl_setopt($curl, CURLOPT_HEADER, false);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curl, CURLOPT_HTTPHEADER, array("Content-type: application/json"));
curl_setopt($curl, CURLOPT_POST, true);
curl_setopt($curl, CURLOPT_POSTFIELDS, $jsonData);

$json_response = curl_exec($curl);

$status = curl_getinfo($curl, CURLINFO_HTTP_CODE);

if($status > 299)
{
	die("ERROR: Code $status");
}

curl_close($curl);

$response = json_decode($json_response, true);
$response["receipt-data"] = $receipt;

echo json_encode($response);

?>