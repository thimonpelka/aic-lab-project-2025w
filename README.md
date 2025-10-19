# Setup/Requirements

### Docker

Download under https://www.docker.com/

You can also validate the docker-compose.yml file using the [localstack cli](https://docs.localstack.cloud/aws/getting-started/installation/#docker-compose) and `localstack config validate`


# Start Application

### LocalStack

```docker compose up```

# Target Scope

- User Registration, Log in, Log Out using Amazon Cognito
- User consists of first name, last name, email and password
- Users log in using email and password
- Additionaly a user can upload a profile picture
- On Registration Event a fixed amount (10) of exercises are randomly generated (Addition, Multiplication and Derivatives) and stored for the user (each user has their own exercises)
- After log in users are redirected to the main page of the application where they have 2 options:
    1. Solve Exercises
    2. View Past Results
- Solution of exercises are only generated during submission not before!!!
- Solving an Exercise consists of 2 parts
    1. Query an unsolved exercise (which belongs to the user) from the database
    2. On submission evaluate the solution and store their result
- Both generating and evaluating exercises is asynchronous (using a message broker)
- This process is managed using a coordinator lambda which forwards the solution to the appropriate evaluator lamba indirectly by sending the solution to the message queue using to correct topic (= exercise type)
- Each time an exercise is marked as solved the DynamoDB Stream invokes a watcher lambda which checks if there are at least 5 unsolved exercise of the currently solved type available -> if not then the generator lambda is instructed to asynchronously generate a new exercise
- Viewing results page requires:
    1. Lambda that fetches the results from the database 
    2. Computes the ratio between correct and incorrect answers for each exercise type (still inside the lambda)
    3. Additionally it should include a grade in the result (ratio > 0.87 => 1, 0.87 >= ratio > 0.74 => 2, 0.74 >= ratio > 0.59 => 3, 0.59 >= ratio > 0.49 => 4, else 5)
