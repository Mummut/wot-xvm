#!/bin/sh

declare -A players
results_counter=0

# $1 - name
# $2 - data
# $3 - add_mask
get()
{
  value=$3${2#*\"$1\":$3}
  if [ "$value" = "$2" ]; then
    return
  fi
  if [ "${value:0:1}" = "{" ]; then
    value=${value%%\}*}}
  elif [ "${value:0:1}" = "[" ]; then
    value=${value%%]*}]
  else
    value=${value%%,*}
    value=${value%%\}*}
    value=${value/\"/}
    value=${value/\"/}
  fi
  echo $value
}

# [{
#   a: "playerId",
#         "a":6260143
#   b: "team",
#         "b":1
#   c: "stat",
#         "c":{"tl":6,"vn":"SU-100","tf":0,"r":50,"td":0,"tb":63,"w":2527,"id":6260143,"b":5021,
#              "tw":37,"clan":"","ts":0,"tr":56,"name":"INSI74","e":1100}
#   d: "vehicleId",
#         "d":"SU-100"
#   e: "label",
#         "e":"INSI74"
#   f: "clanAbbrev",
#         "f":""
#   g: "realVehicleId"
# },...]
process_setup()
{
  local pl id vehicle c
  echo $1 | sed "s/},{/\n/g" | while read pl; do
    id=$(get a "$pl")
    vehicle=$(get d "$pl")

#    key="$id:$vehicle"
#    if [ "${players[$key]}" = "1" ]; then
#      echo "skip: $key"
#      continue
#    fi
#    echo ${players[$key]}
#    players[$key]=1
#    echo ${players[$key]}

    echo -n "  <player" >> players.xml
    echo -n " "id=\"$id\" >> players.xml
    echo -n " "name=\"$(get name "$pl")\" >> players.xml
    echo -n " "vehicle=\"$vehicle\" >> players.xml
    echo -n " "vehId=\"$(get g "$pl")\" >> players.xml

    c=$(get c "$pl")

    echo -n " "battles=\"$(get b "$c")\" >> players.xml
    echo -n " "gwr=\"$(get r "$c")\" >> players.xml
    echo -n " "level=\"$(get tl "$c")\" >> players.xml
    echo -n " "tbattles=\"$(get tb "$c")\" >> players.xml
    echo -n " "tr=\"$(get tr "$c")\" >> players.xml
    echo -n " "eff=\"$(get e "$c")\" >> players.xml
    echo -n " "wn6=\"$(get wn "$c")\" >> players.xml
    echo -n " "twr=\"$(get twr "$c")\" >> players.xml
    echo -n " "wins=\"$(get w "$c")\" >> players.xml
    echo "/>" >> players.xml
  done
}

# a: "team1" : [...],
# b: "team2" : [...],
# c: "common",
#  "c":{"b":2,"c":1353505545,"a":2,"f":"sirmax2","g":"Т-34-85","d":"win","e":7}
#   a: "finishReason",
#   b: "winnerTeam",
#   c: "arenaCreateTime",
#   d: "resultShortStr",
#   e: "arenaTypeID",
#   f: "playerNameStr",
#   g: "vehicleName"
# d: "dailyXPFactor"
#   "d":2
process_results()
{
  local pl a c w
  c=$(get c "$1" "{")
  w=$(get b "$c")
  c=$(get c "$c")
  echo "  <result created=\"$c\" winTeam=\"$w\">" >> results.xml
  a=$(get a "$1" "[")
  a=$(process_results_2 "$a")
  echo "    <team$a/>" >> results.xml
  a=$(get b "$1" "[")
  a=$(process_results_2 "$a")
  echo "    <team$a/>" >> results.xml
  echo "  </result>" >> results.xml
}

#      [{
#        b: "vehicleId",
#        c: "playerId",
#        d: "name",
#        e: "team",
#        f: "vehicleFullName",
#        g: "squadID",
#        h:"isSelf",
#        i: "clanAbbrev",
#        //j: "vehicleStateStr",
#        k: "killerID",
#        l: "health",
#        m: "healthPercents",
#        n: "lifeTime",
#        o: "isTeamKiller",
#        p: "mileage",
#        q: "spotted",
#        r: "capturePoints",
#        s: "droppedCapturePoints",
#        t: "realKills",
#        u: "kills",
#        v: "damageAssisted",
#        w: "shots",
#        x: "hits",
#        y: "pierced",
#        z: "shotsReceived",
#        ac: "damaged",
#        ab: "damageReceived",
#        ad: "tdamageDealt",
#        ae: "damageDealt",
#        af: "xp",
#        ag: "freeXP",
#        ah: "credits",
#        ai: "repair",
#        aj: "typeCompDescr"
#      },...]
process_results_2()
{
  local c b
  n=1
  echo $1 | sed "s/},{/\n/g" | while read pl; do
    #c=$(get c "$pl")
    #echo -n " id$n=\"$c\""
    b=$(get b "$pl")
    echo -n " vehId$n=\"$b\""
    n=$(($n+1))
  done
}

# skip
process_chance()
{
  return
}

echo "<results>" > results.xml
echo "<players>" > players.xml
for i in log/*.log; do
  total=$(wc -l $i | cut -d' ' -f1)
  curr=1
  n=${i%%.*}
  n=${n#*/}
  echo $n
  cat $i | while read line; do
    data=${line#*:}
    typ=${data%%:*}
    data=${data#*:}
    echo "  [$curr/$total] $typ"
    curr=$(($curr+1))
    process_$typ "$data"
#    if [ ${}
#    case $stage in
#      win)
#        win=${line##* }
#        if [ "$win" = "-1" ]; then
#          win="defeat"
#        elif [ "$win" = "1" ]; then
#          win="win"
#        else
#          win="draw"
#        fi
#        echo -n " win=\"$win\">" >> result.xml
#        stage="name"
#        ;;
#      name)
#        name=${line%\"}
#        name=${name##*\"}
#        stage="team"
#        ;;
#      team)
#        team=${line##* }
#        echo -n "<player name=\"$name\" team=\"$team\"/>" >> result.xml
#        stage="name"
#        ;;
#     esac
  done
done
echo "</results>" >> results.xml
echo "</players>" >> players.xml
