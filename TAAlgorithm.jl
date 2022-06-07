function sumAgg(char::Char, ranAccess::Dict{Char, Dict{Any, Any}})
    return sum([value for (key, value) in ranAccess[char]])
end

function sumOfDictValues(dictToSum::Dict)
    return sum([value for (key, value) in dictToSum])
end

function sortByDictVals(dictToSort::Dict, indexToCut::Int64)
    justVals = [val for (key, val) in dictToSort]
    justKeys = [key for (key, val) in dictToSort]
    whereToAccess = sortperm(justVals, rev=true)
    return [(justKeys[i], justVals[i]) for i in whereToAccess][1:indexToCut]
end

function rowColCalc(totalNum::Int64, scoreNames)
    colNum = totalNum % 3 
    if colNum == 0 colNum=3 end
    rowNum = Int64((totalNum - colNum)/3) + 1
    return (rowNum, colNum)
end

function sortedAccessChooser(totalNum::Int64, thresholdVals::Dict, scoreNames, sortedAccessIndices, scoreLists)
    indices = rowColCalc(totalNum, scoreNames)
    println("Sorted access into $(scoreNames[indices[2]])'s $(indices[1]) score")
    indexForScores = sortedAccessIndices[indices[2]][indices[1]]
    nextDoc = scoreLists[indices[2]][indexForScores]
    thresholdVals[scoreNames[indices[2]]] = nextDoc[2]
    return nextDoc
end

function randomAccesser!(nextDoc, ScoresOfTop::Dict, randomAccess)
    println("Random access for document $(nextDoc)")
    ScoresOfTop[nextDoc] = sumAgg(nextDoc[1], randomAccess)
end

function topk(kVal::Int64, scoreNames, letters::Vector{Char}, sortedAccessIndices, scoreLists, randomAccess)
    scoresOfTop, threshold = Dict(), Dict(scoreName=>1.0 for scoreName in scoreNames)
    combinedThreshold = sumOfDictValues(threshold)
    for i in 1:(length(scoreNames))*(length(letters))
        nextDoc, updateForThreshold = sortedAccessChooser(i, threshold, scoreNames, sortedAccessIndices, scoreLists)
        randomAccesser!(nextDoc, scoresOfTop, randomAccess)
        combinedThreshold = sumOfDictValues(threshold)
        listOfOverThreshold = [doc for (doc, value) in scoresOfTop if value >= combinedThreshold]
        if length(listOfOverThreshold) == kVal
            println("Sorting and taking top results")
            return sortByDictVals(scoresOfTop, kVal)
        end
    end
end

function main()
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
    res = topk(5, scoreNames, letters, sortedAccessIndices, scoreLists, randomAccess)
    println("Result is \n $(res)")
end

main()