<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, user-scalable=yes, initial-scale=1.0"/>
    <title>kkFileView演示首页</title>
    <link rel="stylesheet" href="css/viewer.min.css"/>
    <link rel="stylesheet" href="css/loading.css"/>
    <link rel="stylesheet" href="bootstrap/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="bootstrap-table/bootstrap-table.min.css"/>
    <link rel="stylesheet" href="gitalk/gitalk.css"/>
    <script type="text/javascript" src="js/jquery-3.0.0.min.js"></script>
    <script type="text/javascript" src="js/jquery.form.min.js"></script>
    <script type="text/javascript" src="bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="bootstrap-table/bootstrap-table.min.js"></script>
    <script type="text/javascript" src="gitalk/gitalk.min.js"></script>
    <script type="text/javascript" src="js/base64.min.js"></script>
</head>

<body>
<div class="panel-group container" id="accordion">
    <h1>文件预览项目接入和测试界面</h1>

    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
                    接入说明
                </a>
            </h4>
        </div>
        <div class="panel-body">
            <div>
                如果你的项目需要接入文件预览项目，达到对docx、excel、ppt、jpg等文件的预览效果，那么通过在你的项目中加入下面的代码就可以
                成功实现：
                <pre style="background-color: #2f332a;color: #cccccc">
                    var url = 'http://127.0.0.1:8080/file/test.txt'; //要预览文件的访问地址
                    window.open('http://127.0.0.1:8012/onlinePreview?url='+encodeURIComponent(Base64.encode(url)));
                </pre>
            </div>
            <div>
                如果你的项目需要携带header参数token进行访问，只需要如下代码即可成功实现：
                <pre style="background-color: #2f332a;color: #cccccc">
                    var url = 'http://127.0.0.1:8080/file/test.txt?header.token=B0EC3E3A01B8A92B2644B6709AA56159'; //要预览文件的访问地址
                    window.open('http://127.0.0.1:8012/onlinePreview?url='+encodeURIComponent(Base64.encode(url)));
                </pre>
            </div>
            <div>
                新增多图片同时预览功能，接口如下：
                <pre style="background-color: #2f332a;color: #cccccc">
                    var fileUrl =url1+"|"+"url2";//多文件使用“|”字符隔开
                    window.open('http://127.0.0.1:8012/picturesPreview?urls='+encodeURIComponent(Base64.encode(fileUrl)));
                </pre>
            </div>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                <a data-toggle="collapse" data-parent="#accordion">
                    输入下载地址预览文件
                </a>
            </h4>
        </div>
        <div class="panel-body">
            <label>文件下载地址：<input type="text" id="_url" style="min-width:50em"/></label>
            <form action="${baseUrl}onlinePreview" target="_blank" id="preview_by_url" style="display: inline-block">
                <input type="hidden" name="url"/>
                <input type="submit" value="预览">
            </form>
        </div>
    </div>
    <div class="panel panel-default">
        <div class="panel-heading">
            <h4 class="panel-title">
                <a data-toggle="collapse" data-parent="#accordion"
                   href="#collapseTwo">
                    预览测试
                </a>
            </h4>
        </div>
        <div class="panel-body">
            <#if fileUploadDisable == false>
                <div style="padding: 10px">
                    <form enctype="multipart/form-data" id="fileUpload">
                        <input type="file" name="file"/>
                        <input type="button" id="btnSubmit" value=" 上 传 "/>
                    </form>
                </div>
            </#if>
            <div>
                <table id="table" data-pagination="true"></table>
            </div>
        </div>
    </div>

</div>

<div class="loading_container">
    <div class="spinner">
        <div class="spinner-container container1">
            <div class="circle1"></div>
            <div class="circle2"></div>
            <div class="circle3"></div>
            <div class="circle4"></div>
        </div>
        <div class="spinner-container container2">
            <div class="circle1"></div>
            <div class="circle2"></div>
            <div class="circle3"></div>
            <div class="circle4"></div>
        </div>
        <div class="spinner-container container3">
            <div class="circle1"></div>
            <div class="circle2"></div>
            <div class="circle3"></div>
            <div class="circle4"></div>
        </div>
    </div>
</div>
<script>
    function deleteFile(fileName) {
        $.ajax({
            url: '${baseUrl}deleteFile?fileName=' + encodeURIComponent(fileName),
            success: function (data) {
                // 删除完成，刷新table
                if (1 === data.code) {
                    alert(data.msg);
                } else {
                    $('#table').bootstrapTable('refresh', {});
                }
            },
            error: function (data) {
                console.log(data);
            }
        })
    }

    $(function () {
        $('#table').bootstrapTable({
            url: 'listFiles',
            columns: [{
                field: 'fileName',
                title: '文件名'
            }, {
                field: 'action',
                title: '操作'
            },]
        }).on('pre-body.bs.table', function (e, data) {
            // 每个data添加一列用来操作
            $(data).each(function (index, item) {
                item.action = "<a class='btn btn-default' target='_blank' href='${baseUrl}onlinePreview?url=" + encodeURIComponent(Base64.encode('${baseUrl}' + item.fileName)) + "'>预览</a>" +
                    "<a class='btn btn-default' href='javascript:void(0);' onclick='deleteFile(\"" + item.fileName + "\")'>删除</a>";
            });
            return data;
        }).on('post-body.bs.table', function (e, data) {
            return data;
        });

        $('#preview_by_url').submit(function() {
            var _url = $("#_url").val();
            var urlField = $(this).find('[name=url]');
            var b64Encoded = Base64.encode(_url);
            urlField.val(b64Encoded);
        });


        function showLoadingDiv() {
            var height = window.document.documentElement.clientHeight - 1;
            $(".loading_container").css("height", height).show();
        }
        $("#btnSubmit").click(function () {
            showLoadingDiv();
            $("#fileUpload").ajaxSubmit({
                success: function (data) {
                    // 上传完成，刷新table
                    if (1 === data.code) {
                        alert(data.msg);
                    } else {
                        $('#table').bootstrapTable('refresh', {});
                    }
                    $(".loading_container").hide();
                },
                error: function () {
                    alert('上传失败，请联系管理员');
                    $(".loading_container").hide();
                },
                url: 'fileUpload', /*设置post提交到的页面*/
                type: "post", /*设置表单以post方法提交*/
                dataType: "json" /*设置返回值类型为文本*/
            });
        });


    });
</script>
</body>
</html>
