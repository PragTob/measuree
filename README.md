# Measuree

## Task

> The goal of the application is to have some working code that can be presented in front
of the development team. In order to do so, we are going to ask for a very simple app
that has a backend and client with an emphasis on quality. Feel free to use whatever
tools you feel more comfortable with for the frontend and the backend but those must be
separated (single page application). Extra points if the tool can be easily run in our
machines.
> We want a Frontend + Backend application that allows you to post and visualise
metrics. Each metric will have: Timestamp, name, and value. The metrics will be shown
in a timeline and must show averages per minute/hour/day The metrics will be persisted
in the database.

## Installation

* Get the tools documented in `.tool-versions` in the documented versions (slightly older _should_ work but isn't tested), [`asdf`](https://github.com/asdf-vm/asdf) with the appropriate [plugins](https://github.com/asdf-vm/asdf-plugins) can help you with that otherwise check the docs ([Elixir](https://elixir-lang.org/install.html), [postgres](https://www.postgresql.org/docs/current/tutorial-install.html) & [nodejs](https://nodejs.org/en/learn/getting-started/how-to-install-nodejs)).
* Either edit `backend/config/dev.exs` to make postgres data work, or set `POSTGRES_USER` and `POSTGRES_PASSWORD` ENV variables.
* make sure postgres is started `pg_ctl start`
* in `backend` run `mix ecto.setup` and then `mix phx.server`
* in `frontend` run `npm i` and then `npm run dev`
* You should now be available to see the application working at [`localhost:5173`](http://localhost:5173/)

## Language

* Metric - a value we'd want to measure, such as "Temperature" or "Length"

## Assumptions

The task is very wide roaming and building a full application to do this is almost a startup. I was told I can make assumptions to ease the implementation, so I did :) And here they are.

* no **user auth is needed**/the application is protected/limited access in another way (mostly not to add an entire auth system to the challenge)
* **Metrics are limited, known upfront** and don't need frequent changes --> Allows us to forego CRUD features for metrics and provide select boxes for submitting measurements.
  * Also means that storing them in a separate table and reference makes sense as the names don't change all the time
  * also means we don't need features on the frontend to deal with 100+ metrics, if we have max. 10 displaying them all all the time is probably fine
* Metrics are unique aka no 2 of the same name can exist
* There are no further constraints on metrics i.e. a metric named "S" may be valid, further validations not necessary as we manage the data
* timestamp accuracy for measurements doesn't need to be in the microseconds (aka seconds are enough)
* measurements values are ok to store as floats aka small imprecisions when doing the averages are fine, since they are well... averages - allows us to forego some complexity of working with decimals
* measurements are also uniform aka they can be backed by the same data type
* it's ok to have multiple measurements for the same time
* We only care about creating and listing measurements right now, update and delete are out of scope (but potentially useful later). Functionality removed from the API for this reason, but kept in the context for the same reason as with metrics.
* Saving & submitting the timestamp as UTC is ok, so is keeping the definition of "day" in UTC
* the UI will not be the main way to submit measurements and is only done for demo purposes, usually they'd likely be submitted via API
* The application is more read-heavy, so potentially a lot of people looking at the dashboard
* The UI is mostly for reading, of **possibly a lot of data** also **old data isn't submitted often** (aka it's unusualy to get data for a day or 2 ago, or even last hour) hence the decision was made to cache the averages instead of calculating them dynamically
* Refresh for new data doesn't need to be immediate/automatic and a manual refresh is enough, hence no websocket updates were implemented
* We do not need to account for special time zone shenanigans, such as the time zones in India being off by half an hour.
* The metric of a given measurement does not change (---> we don't need to go and update the average cache for the old value)

## Decisions

### Statistics Cache

I decided to implement a cache, as per assumptions I don't expect to get a lot of old data so calculating averages on every request seems like a waste. And at the same time, if we don't often get old data a lot of the data (and hence the cache) are pretty stable.

This implementation is also based on the assumption that in general we have more read traffic vs. write traffic.


The implementation of the cache is probably up for debate:
I decided to implement it as **PostgreSQL triggers on `INSERT`/`UPDATE`**.  I first wanted to implement triggering the cache calculation on the application side (via `Task.async_no_link` doing it outside of the request/response cycle, but ultimately probably in a background queue). However, ultimately it seemed I'd just try to orchestrate what the database already knows how to do itself. As right now, we'd want to update whenever a new value is updated.

Since we do a simple statistic calculation that the database knows how to do, it seems a great fit to do at least the calculation in the database (and I'm pretty sure it's less load on the database vs. retrieving all rows and returning them to the app for calculation and then inserting again)

Potential downsides:
* more advanced statistics may be slightly harder to implement in SQL vs. application logic
* right now every insert/update causes an update, if we implemented bulk submissions/inserts we might want to delay statistics calculation to only do after all inserts are done. Similarly, if traffic increased we might want to throttle statistic calculations if we determine that to be a bottle neck.

However, this implementation is also easily reversible/move elsewhere:
* We can remove the trigger, move the SQL to the application side and trigger the statistics update from the application side easily
* if we decide to fully move away from SQL (for maintainability) we can do the calculations easily on the application side, with something like my [statistex library](https://github.com/bencheeorg/statistex).

Other considerations:
* The table `measurement_statistics` could have also been a table per time bucket to keep table growth a little in check, however that'd also mean multiple queries (unless we used view or materialized view) and the current approach should be fine
* the update of the statistics calculates the averages freshly every time, discarding previous results, as such it is idempotent and "self-healing" - should a bad value have snuck in triggering the statistics calculation again will fix it (as opposed to a more efficient incremental update of the average). Especially the "self-healing" aspect here is important.

### Others
* According to assumptions **CRUD API functionality (except for index) is removed** for metrics, CRUD functionality on the context level remains to allow easy changes/addition if necessary (if this was in production and we needed a new metric, someone could connect to a prod console and add a metric if this was rare)


## Improvements

* **Containerization** would be much appreciated, but in the interest of time, me usually running bare metal and the mandated complexity of 2 applications
* **Batch submit** for measurements might be a nice feature, but it's a bit more complex to build and the semantics are interesting aka if one fails does the entire batch fail or just the one and the others are accepted?