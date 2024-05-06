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

* Get the tools documented in `.tool-versions` in the documented versions (slightl older _should_ work but isn't tested), [`asdf`](https://github.com/asdf-vm/asdf) with the appropriate [plugins](https://github.com/asdf-vm/asdf-plugins) can help you with that other wise check the docs ([Elixir](https://elixir-lang.org/install.html), [postgres](https://www.postgresql.org/docs/current/tutorial-install.html)).

## Language

* Metric - a value we'd want to measure, such as "Temperature" or "Length"

## Assumptions

* Metrics are limited, known upfront and don't need frequent changes --> Allows us to forego CRUD features for metrics and provide select boxes for submitting measurements.
* Metrics are unique aka no 2 of the same name can exist
* There are no further constraints on metrics i.e. a metric named "S" may be valid, further validations not necessary as we manage the data

## Decisions

### Backend
* According to assumptions **CRUD API functionality (except for index) is removed**, CRUD functionality on the context level remains to allow easy changes/addition if necessary (if this was in production and we needed a new metric, someone could connect to a prod console and add a metric if this was rare)

## Improvements

* Containerization would be much appreciated, but in the interest of time, me usually running bare metal and the mandated complexity of 2 applications
