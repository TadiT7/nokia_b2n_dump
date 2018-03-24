
function nameonly()
{
   local name=${1##*/}
   local name0="${name%.*}"
   echo "${name0:-$name}"
}

i=0
ID_Final=`cat /hidden/data/CDALog/ID_Final`
#echo $ID_Final
Lunchbox="LunchBox"

if [[ ! -d "/data/preload-app/$ID_Final" ]]; then
    echo "Error: /data/preload-app/$ID_Final" does not exists. 
    exit 0
fi

sku_dirs[i++]="/data/preload-app/$ID_Final/apk/removable"
sku_dirs[i++]="/data/preload-app/$ID_Final/apk/unremovable"
sku_dirs[i++]="/data/preload-app/$ID_Final/priv-apk/removable"
sku_dirs[i++]="/data/preload-app/$ID_Final/priv-apk/unremovable"
sku_dirs[i++]="/data/preload-app/$Lunchbox/apk/removable"
sku_dirs[i++]="/data/preload-app/$Lunchbox/apk/unremovable"
sku_dirs[i++]="/data/preload-app/$Lunchbox/priv-apk/removable"
sku_dirs[i++]="/data/preload-app/$Lunchbox/priv-apk/unremovable"
#echo "sku_dirs=" ${sku_dirs[@]}

i=0;
for dir in "${sku_dirs[@]}"
do
    echo "scanning $dir"
    for app in "$dir"/*
    do
        if [ -h "$app" ]; then
            sku_apps[i++]=$(nameonly $app)
            echo "  sku_apps += $app"
        fi
    done
done

#echo ${sku_apps[@]}
#for f in "${sku_apps[@]}"
#do
#   echo "sku_app: $f"
#done

echo "\nstart to remove unused apps"
for app_path in /data/preload-app/items/*
do
    if [[ -d $app_path ]]; then
        #echo "Handling $app_path"
        app=$(nameonly $app_path)
        there=0
        for sku_app in "${sku_apps[@]}"
        do
            #echo $app" matching "$sku_app
            if [[ "$app" == "$sku_app" ]]; then
                echo "  keep $app_path"
                there=1
            fi
        done
        if [[ $there -eq 0 ]]; then
            echo "    rm -rf $app_path"
            rm -rf $app_path
        else
            for dir in "${sku_dirs[@]}"
            do
                #echo "dir $dir"
                file=${dir}/${app}
                #echo "file $file"
                if [[ ! -d $file ]]; then
                    if [[ -h $file ]]; then
                        echo "  ${file} is not existing but symbol link is existing"
                        echo "  rm ${file}"
                        echo "  ln -s ${app_path} ${file}"
                        rm $file
                        ln -s $app_path $file
                    fi
                fi
            done
        fi
    fi
done


echo "cleanup unused skus"
for dir in /data/preload-app/*
do
    if [ -d "$dir" ]; then
        if [[ "$dir" == "/data/preload-app/items" ]]; then
            continue;
        fi
        if [[ "$dir" == "/data/preload-app/$ID_Final" ]]; then
            continue;
        fi
        if [[ "$dir" == "/data/preload-app/$Lunchbox" ]]; then
            continue;
        fi
        echo "  rm -rf $dir"
        rm -rf $dir
    fi
done
