#!/bin/bash

author=zhoufei05@baidu.com
version="1.0"
shellName=`basename $0`
# date: 2015.08.13

instruction="generate tag file using ctags by analyzing COMAKE file to resolve the inlcudes"

## steps of this shell:
# 1 if exist COMAKE, read it and go to step 2, else go step 4
# 2 get include paths
# 3 make tags with ctag for each include paths
# 4 make tags for current path

files2Scan="c++ cpp cc h hpp h++"
print_help() {
  echo ${instruction}
  echo "-d add directories to scan"
  echo "-t file types to scan, builtin types are: "${files2Scan}
  echo '-o out put tags file name, default name "tags"'
  echo "-v print version"
  echo "-h print this message"
  echo "example: "
  echo " " ${shellName} "-d ../src" "-d /src" "-t cxx" "-t hxx"
}

# echo $0
# echo `pwd`

tagsFilePath=`pwd`/tags
startPos=`pwd`
# echo "tags file:" ${tagsFilePath}
# echo "pwd:" ${startPos}

while getopts ':d:t:o:vh' dir; do
  # echo ${dir}
  case ${dir} in
    d)
      # echo "dir" $OPTARG >&2
      includes="${includes} ${OPTARG}"
      ;;
    t)
      # echo "type" $OPTARG >&2
      files2Scan="${files2Scan} ${OPTARG}"
      ;;
    o)
      tagsFilePath="${OPTARG}"
      ;;
    v)
      echo ${shellName} ${version} "by" ${author}
      exit 0
      ;;
    h)
      print_help
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_help
      exit -1
      ;;
  esac
done

if [ -f 'COMAKE' ]; then 
  # grep INCPATHS COMAKE
  ## 1 find include path 2 omit comment  3  get paths
  tmp=$(grep INCPATHS COMAKE | grep -v '^\s#' | sed -nr "s/.*'(.+)'.*/\1/p")
  includes="${tmp} ${includes}"
  # echo ${includes}
fi

if [ -f "${tagsFilePath}" ]; then
  echo 'existed tags file: '${tagsFilePath}
  echo 'please, make sure it is a tag file and remove it mannually first'
  exit -1
fi

echo "directries:" ${includes}
echo "file types:" ${files2Scan}

echo "making tags for files:" ${files2Scan} " in the following directories: "
# make tags for each include paths
for eachInclude in ${includes}; do
  echo ${eachInclude}
  # pwd

  ## make tags without -R option for each file, with `-L -` option,
  ## ctags read file name from stdin
  for eachFileExt in ${files2Scan}; do
    ## surpress the no files warning
    files=$(ls ${eachInclude}/*.${eachFileExt} 2>nul || echo "")
    # echo ${files}
    for eachFile in ${files}; do
      # echo ${eachFile}
      tmp=$(echo ${eachFile} | sed -nr 's#//#/#p')
      if [ ${#tmp} -gt 0 ]; then
        eachFile=${tmp}
      fi
      echo ${eachFile} | \
      ctags -L - \
          -a -o ${tagsFilePath} \
          --exclude=.git --exclude=.svn \
          --langmap=c++:+.inl+.cc+.h+.cxx -h [".h.H.hh.hpp.hxx.h++.inl"] \
          --c++-kinds=+p --fields=+iaSK --extra=+q \
          --languages=c++ --language-force=c++
    done
  done
done

## make tags for current path
echo `pwd`
ctags -R \
    -a -o ${tagsFilePath} \
    --exclude=.git --exclude=.svn \
    --langmap=c++:+.inl+.cc+.h+.cxx -h [".h.H.hh.hpp.hxx.h++.inl"] \
    --c++-kinds=+p --fields=+iaSK --extra=+q \
    --language-force=c++ --languages=c++

echo done
exit 0


# vim: ft=sh tw=80 sw=2 ts=2 et
