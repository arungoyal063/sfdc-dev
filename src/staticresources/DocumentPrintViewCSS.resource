/* PDF SetUp */
@page {
	size: 21.0cm 29.7cm;
	margin-top: 1.0cm;
	margin-left: 1.0cm;
	margin-right: 1.0cm;
	margin-bottom: 1.0cm;
}
/* Print Styles */
@media print{
	.sliderWrap{
		display:none;
	}
	a:link,      
	a:visited,  
	a:hover,  
	a:active {
		color:#444;
		text-decoration: none;
	}
}
/* End Print Styles */
/* Screen Styles */
body.printableView{
	margin-top:0;
	position:relative;
	width:718px;
}
a{
	outline:none;
}
br.clear{
	clear:both;
}
/* Font Styles */
body{ 
	font-family: Arial Unicode MS;
	font-size: 62.5%;  /* 16px × 62.5% = 10px */ 
}
td.labelCol,
td.dataCol,
td.data2Col,
.detailTable td,
.detailTable th,
.bPageBlock th{
	color: #444;
	word-spacing: normal;
	text-align: left;
	letter-spacing: 0;
	line-height: 1.4em;
	font-size: 1.2em;
}
.bPageBlock th{
	font-weight: bold;
}
h1{
	color: #444;
	text-decoration: none;
	word-spacing: normal;
	text-align: left;
	letter-spacing: 0;
	font-size: 3em;
}
.bPageBlock h2{
	color: #444;
	text-decoration: none;
	word-spacing: normal;
	text-align: left;
	letter-spacing: 0;
	font-size: 2.4em;
}
.bPageBlock h3{
	color: #444;
	word-spacing: normal;
	text-align: left;
	letter-spacing: 0;
	font-size: 1.4em;
}
/* End Font Styles */
/* Table Styles */
table{
	border-collapse:collapse;
}
table,th,td{
	border:none;
}
.accFamilyLabel{}

.accFamilyData{
	width:69% !important;
}
.accFamilyDataPDF{
	width:73% !important;
}
colgroup.labelCol,
td.labelCol{
	background-color:#CCCCCC;
}
colgroup.dataCol,
td.dataCol{
	background-color:#EEEEEE;
}
.detailTable,
.detailList{
	width:100%;
	table-layout:fixed;
}	
	
.detailTable td,
.detailTable th,
.detailList td{
	width:23%;
	word-wrap:break-word;
	padding:0 1%;
	vertical-align:top;,
}
.accFamilyLabel,
.accFamilyData,
.accFamilyDataPDF{
	padding:1%!important;
}
.stripedCell{
	background:#EEEEEE;
}
/* End Table Styles */
/* Sliding Tab Menu */
.sliderWrap{
	margin: 0 auto;
	width: 300px;
}
#slider {
	position: absolute;
	width: 150px;
	height: 156px;
	top:0;
	right:20px;
}
#sliderContent ul{
	font-size:1.2em;
	list-style:none;
	padding:0;
	text-align:center;
	width: 100%;
	margin:0;
}
#sliderContent .optionsTitle{
	background: dimgray;
	color:white;
	text-align: center;
	font-weight: bold;
}
#slider a{
	text-decoration: none;
	
}
#slider a:link {}      
#slider a:visited {}  
#slider a:hover {}  
#slider a:active {} 

#sliderContent ul li{
	vertical-align: middle;
	padding:5px 5px 10px 0;
	width: 100%;
	text-align: right;
}
#sliderContent ul li img{
	vertical-align: middle;
	height: 32px;
	width: 32px;
}
#sliderContent a {
	-webkit-border-radius: 7px;
	-moz-border-radius: 7px;
	border-radius: 7px;
	background:none repeat scroll 0 0 dimgray;
	color:white;
	font-weight:normal;
	padding:2px;
}
#openCloseWrap {
	font-size:12px;
	font-weight:bold;
	position:absolute;
	right: 0;
	z-index: 2;
}
#sliderContent{
	width: 150px;
	height:100%;
	margin:30px 0 0 0;
	position:absolute;
	right:0;
	top:-190px;
	display:none;
	z-index: 1;
	padding:0;
}
.topMenuAction{
	-webkit-border-bottom-right-radius: 7px;
	-webkit-border-bottom-left-radius: 7px;
	-moz-border-radius-bottomright: 7px;
	-moz-border-radius-bottomleft: 7px;
	border-bottom-right-radius: 7px;
	border-bottom-left-radius: 7px;
	background:none repeat scroll 0 0 dimGray;
	color:white;
	display:block;
	height:20px;
	padding:5px 0;
	text-align:center;
	width:150px;
}	
/* End Sliding Tab Menu */
/* Override OutPutField Hover Panel */
.lookupHoverDetail{display:none}