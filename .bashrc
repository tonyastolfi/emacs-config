export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=${PATH}:/usr/local/bin:~/bin:mame0190-64bit:/Users/astolfi/Library/Python/2.7/bin:/Users/astolfi/bin
export GROOVY_HOME=/usr/local/opt/groovy/libexec
#export PS1="\\033[1m[\\u@\\h:\\W \\A]\\$\\033[0m "
#export PS1="\\033[1m[\\u@\\h:\\W]\\$\\033[0m "
#export PS1="[\\u@\\h:\\W]\\$ "
export PROMPT_COMMAND="updatePrompt"
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"
export BOOST_HOME=/Users/astolfi/projects/boost_1_62_0
export PGHOST=localhost

### Stuff needed for procurify/deployment/inception/check.sh
export INCEPTION_CHECK_GIT_ORIGIN=dt
export INCEPTION_CHECK_CONCURRENT_JOBS=3
###

function updatePrompt {
    dir=$(basename $(pwd))
    parent=$(basename $(dirname $(pwd)))
    #export PS1="[\\u@\\h:${parent}/${dir}]\\$ "
    export PS1="[${parent}/${dir}]\\$ "
}

function blaze {
    bazel $*
}

function browse {
    echo "opening $1 in a new tab..."
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --new-tab $1
}

function addpath {
    export PATH=${PATH}:$(cd $1 && pwd)
}

function pushpath {
    export PATH=$(cd $1 && pwd):${PATH}
}

function addbin {
    addpath $(dirname $1) && which $(basename $1)
}

function pushbin {
    pushpath $(dirname $1) && which $(basename $1)
}

function fullfile {
    echo $(cd $(dirname $1) && pwd)/$(basename $1)
}

function pushjar {
    if [ $# -lt 4 ]; then
        echo 'usage: pushjar <file> <groupId> <artifactId> <version>'
        return 1
    fi
    mvn deploy:deploy-file -Dfile=$(fullfile $1) \
        -DrepositoryId=tamr-nexus \
        -Durl=https://nexus.tamrdev.com:8091/nexus/content/repositories/thirdparty/ \
        -DgroupId=$2 -DartifactId=$3 -Dversion=$4 $5
    find ~/.gradle -name '*.jar' | grep $(basename $1) | xargs -t -n 1 rm -rf 
}

function g () {
    path=$PWD;
    while [ ! -f "${path}/gradlew" ]; do
        if [ "$path" == "/" ]; then
            echo "Couldn't find gradlew - hit / so giving up";
            return 1;
        else
            path=$(dirname $path);
        fi;
    done;
    if [ -f "${path}/gradlew" ]; then
        "${path}/gradlew" "$@";
    fi
}

function resolve() {
    if [ $# -lt 2 ]; then
        echo 'usage: resolve framework-name app-name'
        return 1
    fi
    curl -s http://10.0.23.238:8123/v1/hosts/$2.$1.mesos | jq -r '.[].ip'
}

function qg() {
    ./gradlew compileJava compileTestJava && \
        #./gradlew pushDockerImageCommit && \
        ./gradlew checkstyleMain checkstyleTest \
                  pmdMain pmdTest \
                  findbugsMain findbugsTest &&
        ./gradlew test && \
        ./gradlew integrationTest enforceTestCoverage && \
        ./gradlew build
}

#pushpath ~/tamr/github/dev-tools
#addpath ~/tamr/gdrive/bin

#source $(which mmenv.sh)
#source ~/quayenv.sh

alias tab=browse
alias dockerip='docker-machine ip default'

# TEMPORARY - delete once done experimenting with minimesos
#addbin ~/tamr/minimesos-master/bin/minimesos
#alias cdmm="cd ~/tamr/mm_test"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

PATH=${PATH}:~/tamr/github/dev-tools/j4
#source ~/tamr/github/dev-tools/j4/j4rc.sh
source ~/bin/dev-aws-env.sh

# Moved to ~/bin/play script
#alias play='ansible-playbook --vault-password-file ~/.vault_pass.txt -i hosts'

# Activate Autojump (https://github.com/wting/autojump)
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

# Enable publishing to Nexus.
export NEXUS_DEPLOY_PW=6p3WAWRYBgq0UVScOMVY

alias blaze=bazel
alias a=$HOME/projects/aphorism/random.sh

a
