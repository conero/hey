# author: Joshua Conero
# 打包分发工具 

#时间统计
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# 先进行当前系统的编译
echo "go 系统编译中"
go build ./cmd/hey


# 查看所有
# $os    操作系统:     linux, darwin, windows, netbsd, freebsd
# $arch  操作系统架构: amd64, 386, arm, ppc64
# $cache 是否缓存模块，默认为否！可用于调试
Function yangsu_pack($os, $arch, $cache='')
{
    # 分发到 Windows, 编写参照: win => *, 其他打包文件参照 windows 打包文件
    # 设置环境变量
    # linux, darwin, windows, netbsd
    $env:GOOS=$os

    # 系统架构
    # amd64, 386, arm, ppc64
    $env:GOARCH = $arch

    # 系统版本
    $version = ./hey -version true

    $path = './runtime/bundle/'
    $name = 'hey-'+$version+'-'+$os+'.'+$arch

    $path = $path + $name
    if(-not (Test-Path -Path $path )){
        mkdir $path
    }
    else
    {
        # 删除目录并重建
        # rm $path -recurse -force
        Remove-Item $path -recurse -force
        mkdir $path
    }

    # 运行，即使对应操作系统的脚本
    go build -o $path ./cmd/hey
    #文件复制
    # 目录复制
    # cp -r ./config $path/config
    # cp -r ./doc $path/doc
    # cp -r ./public $path/public
    # cp -r ./views $path/views
    # 特定文件复制
    # cp ./README.md $path/README.md
    # cp ./README.en.md $path/README.en.md
    # 删除文件
    # 删除数据库配置文件
    # Remove-Item $path/config/database.toml -force

    # 删除本地文件（查找和删除文件）
    # Get-ChildItem -Recurse $path/config/*TAGprivate* | Remove-Item

    #
    # 文件压缩
    $version = ./hey -version true
    # 转到目录并压缩文件
    cd $path
    # @todo 过滤含"TAGprivate" 的而文件和目录
    tar -zcvf ../../../dist/$name.tar.gz *
    # 返回目录，用于控制台路劲恢复
    cd ../../../

    if($cache){
        echo $path+', 已缓存'
    }else{
        Remove-Item $path -recurse -force
    }

}

# 循环执行
# 变量为空，或者设置数组(仅仅支持数组形式)；
# powershell 单数组的写法: @('windows')
# 使用实例 >>
#          pack_all_list @('windows') amd64,arm
# $os    $os_list:     linux, darwin, windows, netbsd
# $arch  $arch_list:   amd64, 386, arm, ppc64
Function pack_all_list($os_list='', $arch_list='') 
{
    if(!$os_list){
        $os_list = "linux","darwin","windows", "netbsd"
    }
    if(!$arch_list){
        $arch_list = "amd64", "386", "arm", "ppc64"
    }
    
    foreach ($os in $os_list){
        foreach($arch in $arch_list){
            yangsu_pack $os $arch
        }
    }
}


# 执行打包
# yangsu_pack windows arm
# pack_all_list 默认全部
#pack_all_list @('windows') 'amd64','arm'
pack_all_list @('windows') 'amd64'
pack_all_list @('linux') 'amd64'
pack_all_list @('darwin') @('amd64')

write-host "Total Elapsed Time: $($elapsed.Elapsed.ToString())"
Read-Host '键入任意键退出'
