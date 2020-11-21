import boto3
import numpy as np
import json
import random

dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
movie_table = dynamodb.Table('Movie')
user_table = dynamodb.Table('User')

EPSILON = 0.000000001


def build_weight_array(population, population_size, no_of_different_ratings):
    weight_array = np.zeros((population_size, no_of_different_ratings), dtype=np.float32)
    for i in range(population_size):
        for j in range(no_of_different_ratings):
            tmp = population[i][no_of_different_ratings * j: no_of_different_ratings * (j + 1)]
            tmp_val = (2 * tmp.dot(2 ** np.arange(tmp.size)[::-1]) / (pow(2, no_of_different_ratings) - 1)) - 1
            weight_array[i][j] = tmp_val
    return weight_array


def similarity_function(cur_user_idx, weight_array, value_array, population_size, no_of_users, no_of_different_ratings):
    similarity = np.zeros((population_size, no_of_users))
    for i in range(population_size):
        for j in range(no_of_users):
            if cur_user_idx != j:
                tmp_1 = np.dot(weight_array[i], value_array[j]) / no_of_different_ratings
                similarity[i][j] = tmp_1
    return similarity


def probability_function(cur_user_idx, similarity, population_size, no_of_movies, rating_array, user_mean):
    px = np.zeros((population_size, no_of_movies))
    for i in range(population_size):
        for j in range(no_of_movies):
            tmp_rating = np.where(rating_array[:, j] > 0, rating_array[:, j] - user_mean, 0)
            tmp_rating = np.dot(tmp_rating, similarity[i, :])
            sum_1 = np.sum(similarity[i, :])
            px[i][j] = user_mean[cur_user_idx] + np.sum(tmp_rating) / (sum_1 + EPSILON)

    return px


def build_fitness_function(prob, rating_array, population_size, no_of_movies):
    fitness = np.zeros(population_size)
    for i in range(population_size):
        a_t = np.sum(np.abs((rating_array - prob[i])), axis=1) / no_of_movies
        fitness[i] = a_t.mean()
    return fitness


def lambda_handler(event, context):
    CURRENT_USER_ID = 'NEW_USER'

    if event.get('queryStringParameters') is not None:
        qpuserid = event.get('queryStringParameters').get('userid')
        CURRENT_USER_ID = qpuserid

    # CURRENT_USER_ID = 'VTrDnu56mGeFMmywm0QIA6'
    print("Current user is", CURRENT_USER_ID)

    org_movies = movie_table.scan()['Items']
    org_user = user_table.scan()['Items']

    for m in org_movies:
        if m.get('averageRating') is not None:
            m['averageRating'] = None

    # print(org_movies)

    # print(org_movies)
    # print(org_user)
    #  Storing index of movies
    movie_map = dict()
    idx_movie = dict()

    user_rated_movie = set()

    counter = 0
    for m in org_movies:
        if movie_map.get(m['MovieId']) is None:
            movie_map[m['MovieId']] = counter
            idx_movie[counter] = m
            counter = counter + 1

        if m['UserId'] == CURRENT_USER_ID:
            user_rated_movie.add(m['MovieId'])

    # Storing user idx
    user_map = dict()
    idx_user = dict()
    counter = 0

    for u in org_user:
        if user_map.get(u['UserId']) is None:
            user_map[u['UserId']] = counter
            idx_user[counter] = u
            counter = counter + 1

    # Build Value Array
    # @TODO set current user idx
    current_user = None
    if user_map.get(CURRENT_USER_ID) is not None:
        current_user = user_map.get(CURRENT_USER_ID)
    else:
        random_movies = random.sample(org_movies, 10)
        return {
            'statusCode': 200,
            'headers': {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            'body': json.dumps(random_movies)
        }

    # Constants
    _NUMBER_OF_DIFF_RATINGS = 5
    _NUM_OF_GENERATION = 20
    _NUM_MOVIE = len(movie_map)
    _NUM_USERS = len(user_map)
    _POPULATION_SIZE = 40
    _CROSSOVER_POP = 6

    # Ratings of all users
    rat_array = np.zeros([_NUM_USERS, _NUM_MOVIE], dtype=np.float16)
    for rat in org_user:
        rat_array[user_map[rat['UserId']]][movie_map[rat['MovieId']]] = rat['rating']

    _USER_MEAN = np.true_divide(rat_array.sum(1), (rat_array != 0).sum(1))

    _value_array = np.zeros((_NUM_USERS, _NUMBER_OF_DIFF_RATINGS), dtype=np.float32)

    current_user_rating = rat_array[current_user]
    for user in org_user:
        if user['UserId'] is not current_user:
            user_idx = user_map[user['UserId']]
            user_b = rat_array[user_idx]
            common_ratings = 0
            for a, b in zip(current_user_rating, user_b):
                a_i = int(a)
                b_i = int(b)
                if a_i != 0 and b_i != 0:
                    diff = int(abs(a - b))
                    _value_array[user_idx][diff] += 1
                    common_ratings += 1
            if common_ratings != 0:
                _value_array[user_idx] /= common_ratings

    # Generating Random population
    population = np.random.randint(2, size=(_POPULATION_SIZE, _NUMBER_OF_DIFF_RATINGS * _NUMBER_OF_DIFF_RATINGS))
    generation = _NUM_OF_GENERATION

    while generation > 0:
        # print("Generating population: ", generation)
        generation -= 1
        weight_array = build_weight_array(population=population,
                                          population_size=_POPULATION_SIZE,
                                          no_of_different_ratings=_NUMBER_OF_DIFF_RATINGS)
        similarity_value = similarity_function(cur_user_idx=current_user,
                                               weight_array=weight_array,
                                               value_array=_value_array,
                                               population_size=_POPULATION_SIZE,
                                               no_of_users=_NUM_USERS,
                                               no_of_different_ratings=_NUMBER_OF_DIFF_RATINGS)
        probability = probability_function(cur_user_idx=current_user,
                                           similarity=similarity_value,
                                           population_size=_POPULATION_SIZE,
                                           no_of_movies=_NUM_MOVIE,
                                           rating_array=rat_array,
                                           user_mean=_USER_MEAN)
        fitness_value = build_fitness_function(prob=probability,
                                               rating_array=rat_array,
                                               population_size=_POPULATION_SIZE,
                                               no_of_movies=_NUM_MOVIE)

        population = np.c_[population, -1 * fitness_value]
        population = population[population[:, -1].argsort()]
        population = np.delete(population, -1, 1)

        if generation > 1:
            new_population = []
            # Crossover
            for i in range(_CROSSOVER_POP):
                for j in range(i, _CROSSOVER_POP):
                    tmp_1 = population[i].copy()
                    tmp_2 = population[j].copy()
                    rand_int = np.random.randint(_NUMBER_OF_DIFF_RATINGS * _NUMBER_OF_DIFF_RATINGS)
                    tmp_1[:rand_int] = tmp_2[:rand_int]
                    new_population.append(tmp_1)

            new_population = np.array(new_population)
            rand_idx = np.random.randint(_NUMBER_OF_DIFF_RATINGS * _NUMBER_OF_DIFF_RATINGS)
            for i in range(len(new_population)):
                new_population[i][rand_idx] = 1 - new_population[i][rand_idx]

            population[-len(new_population):, :] = new_population

    # Predicting the movies list
    top_pop = population[0]
    p_weight = np.zeros(_NUMBER_OF_DIFF_RATINGS, dtype=np.float32)
    for j in range(_NUMBER_OF_DIFF_RATINGS):
        tmp = top_pop[_NUMBER_OF_DIFF_RATINGS * j: _NUMBER_OF_DIFF_RATINGS * (j + 1)]
        tmp_val = (2 * tmp.dot(2 ** np.arange(tmp.size)[::-1]) / (pow(2, _NUMBER_OF_DIFF_RATINGS) - 1)) - 1
        p_weight[j] = tmp_val

    p_similarity = np.zeros(_NUM_USERS)
    for j in range(_NUM_USERS):
        if current_user != j:
            tmp_1 = np.dot(p_weight, _value_array[j]) / _NUMBER_OF_DIFF_RATINGS
            p_similarity[j] = tmp_1

    p_probability = np.zeros(_NUM_MOVIE)
    for j in range(_NUM_MOVIE):
        tmp_rating = np.where(rat_array[:, j] > 0, rat_array[:, j] - _USER_MEAN, 0)
        tmp_rating = np.dot(np.abs(tmp_rating), p_similarity)
        sum_1 = np.sum(p_similarity)
        p_probability[j] = np.sum(tmp_rating) / (sum_1 + EPSILON)

    p_probability = np.c_[p_probability, np.arange(len(p_probability))]
    p_probability = p_probability[p_probability[:, 0].argsort()][::-1]

    recommended_movie_result = []
    mov_counter = 0
    for i in range(len(p_probability)):
        tmp_movie = idx_movie.get(int(p_probability[i][1]))
        if tmp_movie['MovieId'] not in user_rated_movie:
            recommended_movie_result.append(tmp_movie)
            mov_counter += 1

        if mov_counter > 5:
            break

    return {
        'statusCode': 200,
        'headers': {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
        },
        'body': json.dumps(recommended_movie_result)
    }


if __name__ == '__main__':
    print(lambda_handler("", ""))
