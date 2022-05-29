function sumAgg(char::Char)
    sum = 0
    for (key, value) in randomAccess[char] sum += value end
    return sum
end

function sumOfDictValues(dictToSum::Dict)
    sum = 0
    for (key, value) in dictToSum sum += value end
    return sum
end

function sortByDictVals(dictToSort::Dict, indexToCut::Int64)
    justVals = [val for (key, val) in dictToSort]
    justKeys = [key for (key, val) in dictToSort]
    whereToAccess = sortperm(justVals, rev=true)
    return [(justKeys[i], justVals[i]) for i in whereToAccess][1:indexToCut]
end

function rowColCalc(totalNum::Int64)
    rowNum = Int(floor((totalNum-1)/length(scoreNames))) + 1
    colNum = totalNum - length(scoreNames) * (rowNum - 1)
    return (rowNum, colNum)
end

function sortedAccessChooser(totalNum::Int64, thresholdVals::Dict)
    indices = rowColCalc(totalNum)
    indexForScores = sortedAccessIndices[indices[2]][indices[1]]
    nextDoc = scoreLists[indices[2]][indexForScores]
    thresholdVals[scoreNames[colNum]] = nextDoc[2]
    #println(nextDoc[2])
    return nextDoc
end

function randomAccesser(nextDoc, ScoresOfTop::Dict)
    (doc, val) = nextDoc
    #println(doc)
    ScoresOfTop[doc] = sumAgg(doc[1])
end

letterStr = "abcdefghijklmnopqrstuvwxyz"
letters = [char for char in letterStr]
scores = Dict()
scoreNames = ["score1", "score2", "score3"]
for name in scoreNames scores[name] = Dict() end

for name in scoreNames for char in letters scores[name][char] = rand() end end

scoreLists = [[key for key in scores[name]] for name in scoreNames]

randomAccess = Dict(char=>Dict() for char in letters)
for idx in 1:length(scoreNames) for key in scoreLists[idx] randomAccess[key[1]][scoreNames[idx]] = key[2] end end
scoresOnly = [[key[2] for key in score] for score in scoreLists]
sortedAccessIndices = [sortperm(scoresOnly[idx], rev=true) for idx in 1:length(scoreLists)]

function topk(kVal::Int64)
    scoresOfTop, threshold = Dict(), Dict(scoreName=>1 for scoreName in scoreNames)
    combinedThreshold = sumOfDictValues(threshold)
    for i in 1:(length(scoreNames))*(length(letters))
        nextDoc, updateForThreshold = sortedAccessChooser(i)
        randomAccesser(nextDoc, scoresOfTop)
        combinedThreshold = sumOfDictValues(threshold)
        listOfOverThreshold = [doc for (doc, value) in scoresOfTop if value >= combinedThreshold]
        #println(threshold)
        if length(listOfOverThreshold) == kVal
            return sortByDictVals(scoresOfTop, kVal)
        end
    end
end
