const users = require("./user.json")
const movies = require("./movies.json")

const LOGGED_IN_USER = "";
const NUMBER_OF_CHROMOSOMES = 40;
const NUMBER_OF_GENERATION = 30;

function initializePopulation(row, col) {
    var res = new Array(row);
    for (let i = 0; i < res.length; i++) {
        res[i] = new Array(col);
    }

    for (let i = 0; i < row; i++) {
        for (let j = 0; j < 25; j++) {
            res[i][j] = Math.random();
        }
    }
    return res;
}


function getMovies(use, mov) {
    console.log(use);
    console.log("***************");
    console.log(mov);
}

function sortUser(users) {

    let userMap = new Map()
    for (u of users) {
        if (!userMap.has(u.UserId)) {
            userMap.set(u.UserId, new Map())
        }
        const rating = u.rating != undefined ? u.rating : 0;
        userMap.get(u.UserId).set(u.MovieId, rating);
    }
    return userMap;
}

function movieMap(moviesList) {
    var map = new Map();
    var counter = 0;
    for (movie of moviesList) {
        if (!map.has(movie.MovieId)) {
            map.set(movie.MovieId, counter);
            counter++;
        }
    }
    return map;
}

function userMap(usersList) {
    var map = new Map();
    var counter = 0;
    for (const [key, value] of usersList.entries()) {
        if (!map.has(key)) {
            map.set(key, counter);
            counter++;
        }
    }
    return map;
}

function fillRatingsOfAllUser(users, numberOfUsers, numberOfMovies, movieIdx, userIdx) {
    var ratings = new Array(numberOfUsers)
    for (let i = 0; i < numberOfUsers; i++) {
        ratings[i] = new Array(numberOfMovies + 1);
        for (let j = 0; j < numberOfMovies; j++) {
            ratings[i][j] = -1;
        }
        ratings[i][numberOfMovies] = 0
    }
    
    for (const [key, value] of users.entries()) {
        const idx = userIdx.get(key)
        if (idx) {
            for (const [m, r] of value.entries()) {
                const midx = movieIdx.get(m)
                if (midx) {
                    ratings[idx][midx] = r
                    ratings[idx][numberOfMovies] += r
                }                
            }
        }
        ratings[idx][numberOfMovies] /= value.size
    }
    return ratings;
}

function varray(currentUser, usersList, numberOfUsers, movieIdx, userIdx) {
    const v = new Array(numberOfUsers)
    for (let i = 0; i < numberOfUsers; i++) {
        v[i] = new Array(5);
        v[i][0] = 0;
        v[i][1] = 0;
        v[i][2] = 0;
        v[i][3] = 0;
        v[i][4] = 0;
    }
    for (const [key, value] of usersList.entries()) {
        if (currentUser.UserId !== key) {
            const uidx = userIdx.get(key)
            var commonRatings = 0
            for (const [m, r] of value.entries()) {
                if (currentUser.movies.get(m) && r) {
                    commonRatings++
                    var diff = Math.abs(currentUser.movies.get(m) - r);
                    console.log("Difference: ", diff)
                    if (diff === 0) {
                        v[uidx][0]++
                    } else if (diff === 1) {
                        v[uidx][1]++
                    } else if (diff === 2) {
                        v[uidx][2]++
                    } else if (diff === 3) {
                        v[uidx][3]++
                    } else if (diff === 4) {
                        v[uidx][4]++
                    } 
                }
            }
            if (commonRatings != 0) {
                v[uidx][0] /= commonRatings;
                v[uidx][1] /= commonRatings;
                v[uidx][2] /= commonRatings;
                v[uidx][3] /= commonRatings;
                v[uidx][4] /= commonRatings;
            }
        }
    }
    return v;
}


// getMovies(users, movies)
function geneticAlgorithm() {
    const allUsers = sortUser(users.Items);
    const currentUser = {
        UserId: "VTrDnu56mGeFMmywm0QIA6mOmKy1",
        movies: allUsers.get("VTrDnu56mGeFMmywm0QIA6mOmKy1")
    };
    console.log(currentUser)
    // allUsers.delete("VTrDnu56mGeFMmywm0QIA6mOmKy1")
    const movieIdx = movieMap(movies.Items);
    const userIdx = userMap(allUsers);
    const NUMBER_OF_MOVIES = movieIdx.size;
    const NUMBER_OF_USERS = userIdx.size
    const NUMBER_OF_OTHER_USERS = allUsers.size - 1
    const ratings = fillRatingsOfAllUser(allUsers, NUMBER_OF_USERS, NUMBER_OF_MOVIES, movieIdx, userIdx)

    // console.log(ratings)

    var v = varray(currentUser, allUsers, NUMBER_OF_USERS, movieIdx, userIdx)
    var px = new Array(NUMBER_OF_CHROMOSOMES)
    for (let i = 0; i < NUMBER_OF_CHROMOSOMES; i++) {
        px[i] = new Array(NUMBER_OF_MOVIES)
    }
    
    var population = initializePopulation(NUMBER_OF_CHROMOSOMES, 26);
    
    var generation = 1;

    while (generation--) {
        let fitnessValue = new Array(NUMBER_OF_CHROMOSOMES);
        let weightOfPopulation = new Array(NUMBER_OF_CHROMOSOMES);

        for (let i = 0; i < NUMBER_OF_CHROMOSOMES; i++) {
            weightOfPopulation[i] = new Array(5);
            for (let j = 0; j < 5; j++) {
                var sum = 0;
                for (let k = 0, a = 4; k < 5; a--, k++) {
                    sum += Math.pow(2, a) * population[i][j * 5 + k];
                }
                weightOfPopulation[i][j] = (2 * sum / 31.0) - 1.0
            }
        }

        let similarityValue = new Array(NUMBER_OF_CHROMOSOMES);
        for (let i = 0; i < NUMBER_OF_CHROMOSOMES; i++) {
            similarityValue[i] = new Array(NUMBER_OF_OTHER_USERS);
            for (let j = 0; j < NUMBER_OF_OTHER_USERS; j++) {
                var sum = 0;
                for (let k = 0; k < 5; k++) {
                    // @TODO Complete the sum
                    sum += weightOfPopulation[i][k] * v[j][k];
                }
                similarityValue[i][j] = sum / 5.0;                
            }
        }
        
        // pxvalue
        for (let j = 0; j < NUMBER_OF_CHROMOSOMES; j++) {
            for (let k = 0; k < NUMBER_OF_MOVIES; k++) {
                var sum = 0, sum2 = 0
                for (let l = 0; l < NUMBER_OF_OTHER_USERS; l++) {
                    
                    
                }
            }
        }

    }

    let weights = new Array(5)
    let similarity = new Array(NUMBER_OF_OTHER_USERS)
    let predicted = new Array(NUMBER_OF_MOVIES)

    for (let j = 0; j < 5; j++) {
        var sum = 0;
        for (let k = 0, a = 4; k < 5; a--, k++) {
            sum += Math.pow(2, a) * population[0][j * 5 + k];
        }
        weights[j] = 2 * sum / 31.0 - 1;
    }

    for (let j = 0; j < NUMBER_OF_OTHER_USERS; j++) {
        var sum = 0;
        
        for (let k = 0; k < 5; k++) {
            sum += weights[k] * v[j][k];
        }
        similarity[j] = sum / 5.0;
    }

    for (let i = 0; i < NUMBER_OF_MOVIES; i++) {
        var sum1 = 0, sum2 = 0
        for (let it = 0; it < NUMBER_OF_USERS; it++) {
            
        }
        // predicted[i] = 
    }

}

geneticAlgorithm()
