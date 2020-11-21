const dynamodb = require('aws-sdk/clients/dynamodb');
const docClient = new dynamodb.DocumentClient();

const MOVIE_TABLE = 'Movie';
const USER_TABLE = "User";


exports.getRecommendation = async (event) => {
    if (event.httpMethod !== 'GET') {
        throw new Error(`postMethod only accepts POST method, you tried: ${event.httpMethod} method.`);
    }

    var movieParams = {
        TableName: MOVIE_TABLE
    };
    var userParams = {
        TableName: USER_TABLE
    };

    const movies = docClient.scan(movieParams).promise();
    const users = docClient.scan(userParams).promise();

    await Promise.all([movies, users]);
    console.log("********************USERS**********************");
    console.log(JSON.stringify(users));
    console.log("*********************MOVIES*********************");
    console.log(JSON.stringify(movies));
    console.log("******************************************");
    return {
        statusCode: 200,
    }
}