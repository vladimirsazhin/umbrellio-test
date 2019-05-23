# Задача 1

## Запуск на машине разработчика

```
createdb umbrellio-task1-development
createdb umbrellio-task1-test

bundle
rails db:migrate
rails server
```

Приложение будет доступно по адресу http://localhost:3000/.

## Генерация тестовых данных

```
rails db:seed
```

## Запуск спеков

```
rspec
```

## Запуск в production-окружении

```
createdb umbrellio-task1

export RAILS_ENV=production
export POSTGRES_URL=postgres://localhost/umbrellio-task1

bundle
rails credentials:edit
rails db:migrate

bundle exec puma
```

Приложение будет доступно по адресу http://localhost:3000/.

Порт можно изменить с помощью переменной окружения `PORT`.

## Производительность

Тестовый сервер запущен в production-окружении на MacBook Pro с процессором Intel Core i5 (2.3 GHz) и 8 Гб оперативной памяти.

```
umbrellio-task1-development=# SELECT COUNT(*) FROM "users";
 count 
-------
  1010
(1 row)

umbrellio-task1-development=# SELECT COUNT(*) FROM "posts" WHERE "author_id" IS NOT NULL;
 count 
-------
 53760
(1 row)

umbrellio-task1-development=# SELECT COUNT(*) FROM "posts" WHERE "rating" <> 0;
 count 
-------
 28120
(1 row)

umbrellio-task1-development=# SELECT COUNT(DISTINCT "author_ip") FROM "posts";
 count 
-------
  9951
(1 row)
```

### Создание поста

Несуществующий пользователь:

```
$ curl --silent -X POST -d "title=foo&content=bar&author_login=baz&author_ip=1.2.3.4" "http://localhost:3000/posts/create" | jq
{
  "id": 53806,
  "title": "foo",
  "content": "bar",
  "rating": 0,
  "author": {
    "id": 1049,
    "login": "baz",
    "ip": "1.2.3.4"
  }
}
```

```
Started POST "/posts/create" for 127.0.0.1 at 2019-05-30 11:55:55 +0300
Processing by PostsController#create as */*
  Parameters: {"title"=>"foo", "content"=>"bar", "author_login"=>"baz", "author_ip"=>"1.2.3.4"}
(0.000140s) BEGIN
(0.001313s) SELECT "id" FROM "users" WHERE ("login" = lower('baz')) LIMIT 1
(0.000556s) INSERT INTO "users" ("login") VALUES ('baz') ON CONFLICT (lower("login")) DO NOTHING RETURNING "id"
(0.000877s) INSERT INTO "posts" ("title", "content", "author_id", "author_ip") VALUES ('foo', 'bar', 1049, '1.2.3.4') RETURNING "id"
(0.040522s) COMMIT
Completed 200 OK in 45ms (Views: 0.3ms)
```

Существующий пользователь:

```
$ curl --silent -X POST -d "title=foo&content=bar&author_login=baz&author_ip=1.2.3.4" "http://localhost:3000/posts/create" | jq
{
  "id": 53807,
  "title": "foo",
  "content": "bar",
  "rating": 0,
  "author": {
    "id": 1049,
    "login": "baz",
    "ip": "1.2.3.4"
  }
}
```

```
Started POST "/posts/create" for 127.0.0.1 at 2019-05-30 11:58:00 +0300
Processing by PostsController#create as */*
  Parameters: {"title"=>"foo", "content"=>"bar", "author_login"=>"baz", "author_ip"=>"1.2.3.4"}
(0.000149s) BEGIN
(0.000670s) SELECT "id" FROM "users" WHERE ("login" = lower('baz')) LIMIT 1
(0.000706s) INSERT INTO "posts" ("title", "content", "author_id", "author_ip") VALUES ('foo', 'bar', 1049, '1.2.3.4') RETURNING "id"
(0.005502s) COMMIT
Completed 200 OK in 9ms (Views: 0.2ms)
```

### Оценка поста

```
$ curl --silent -X POST -d "post_id=53807&value=5" "http://localhost:3000/posts/rate" | jq
5
```

```
Started POST "/posts/rate" for 127.0.0.1 at 2019-05-30 12:02:59 +0300
Processing by PostsController#rate as */*
  Parameters: {"post_id"=>"53807", "value"=>"5"}
(0.000136s) BEGIN
(0.000395s) INSERT INTO "ratings" ("post_id", "value") VALUES (53807, 5) RETURNING "id"
(0.000742s) UPDATE "posts" SET "ratings_sum" = ("ratings_sum" + 5), "ratings_count" = ("ratings_count" + 1), "rating" = (CAST(("ratings_sum" + 5) AS numeric) / ("ratings_count" + 1)) WHERE ("id" = 53807) RETURNING "rating"
(0.005496s) COMMIT
Completed 200 OK in 8ms (Views: 0.1ms)
```


### Топ 20 постов по среднему рейтингу

```
$ curl --silent "http://localhost:3000/posts/top?n=20" | jq
[
  {
    "title": "4497c755578547dd3e6fff1d18202d4608d8a2e2c40c136ba0d9b80fe8face9c2d6af56831956c9a42eb080156815b29f79b",
    "content": "13b53f78f2e165345b513a53df88d3d6344d164560b9b672c807447b8eca2d12903df4fcf9e378bdf5cf544a5f4087e5a15f80970e5cb4102decd6cb7ccc3859d269da38e620b72e3f39d5c1f813f6005987280c4acd665ebb5d74cb6ddd25c5d890f9c6"
  },
  {
    "title": "270857d8996b7f70b895122f29d11c8ec85aa505496e35a099abf1a5b3131098629da41f11aa87b13ef666106438738d0053",
    "content": "8ebd20106592e5cad435c6f52b5f627258e9ea9b7646f6f796db832a04f39b70bab766373e56bd1e66fa20a97dde0f5f7b40deafef29dc2c9ceb6b2f227340f8fb9fe3e427b0b03f6acfeaa654d2939c6861f40a4428b580577b294598ee74146cb89cc8"
  },
  ...
]
```

```
Started GET "/posts/top?n=20" for 127.0.0.1 at 2019-05-30 12:05:58 +0300
Processing by PostsController#top as */*
  Parameters: {"n"=>"20"}
(0.118364s) SELECT "title", "content" FROM "posts" ORDER BY "rating" DESC, "ratings_count" DESC LIMIT 20
Completed 200 OK in 119ms (Views: 119.2ms)
```

### Авторы с одинаковыми IP

```
$ curl --silent "http://localhost:3000/authors/with-same-ips" | jq
[
  {
    "ip": "1.2.1.1",
    "logins": [
      "2fa2feb2efe56f97fb603a1d",
      "393d3d5d65f6fcade693fd20",
      "6b8c3bc7f193ac3adbee3344",
      "73faa3a19818ccaad381fb2a",
      "86e783ae7f9f62d361ba9917",
      "9d9b89da33b56135afa54e89",
      "add7e25f0fa0091878760624"
    ]
  },
  {
    "ip": "1.2.1.2",
    "logins": [
      "3821cfd16a953b23c578cc06",
      "deb4e0cc33d52d431bd4bf95"
    ]
  },
  {
    "ip": "1.2.1.3",
    "logins": [
      "41124e091a54277ec6288fef",
      "632322430c3f97116faa752a",
      "b00970325050f75f1b1ae18d",
      "da5affba2671dc6f1bdcc83c"
    ]
  },
  ...
]
```

```
Started GET "/authors/with-same-ips" for 127.0.0.1 at 2019-05-30 12:08:30 +0300
Processing by AuthorsController#with_same_ips as */*
(0.179622s) SELECT "ip", array_agg(DISTINCT "login") AS "logins" FROM (SELECT "author_ip" AS "ip", "author_id", count(*) OVER (PARTITION BY "author_ip") AS "ips_count" FROM "posts") AS "t1" INNER JOIN "users" ON ("users"."id" = "t1"."author_id") WHERE ("ips_count" > 1) GROUP BY "ip"
Completed 200 OK in 665ms (Views: 664.7ms)
```
