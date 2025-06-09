# Phoenix LiveView 1.0 Multi Chatroom App Tutorial

![phoenix-chat-logo](./tutorial_resources/PHOENIX_LIVEVIEW_CHATROOM_TUTORIAL_THUMBNAIL.png)

A complete Phoenix LiveView (~> 1.0) tutorial to build a chatroom app where users can _create_, _update_, and _delete_ both rooms and messages **all in real time.**

## Preview

![phoenix-chat-logo](./tutorial_resources/PHOENIX_LIVEVIEW_CHATROOM_TUTORIAL_THUMBNAIL.png)
Example:
[**https://my-link-here.com/**](https://my-link-here.com/)
This tutorial goes over building

## Table of Contents

- [**Intro**](#what-we-will-build)

  - [Preview](#project-overview)
  - [Table of Contents](#table-of-contents)

- [**Project Overview**](#project-overview)

  - [Who is this for?](#who-is-this-for)
  - [Prerequisites](#prerequisites)
  - [LiveView Concepts Covered](#liveview-concepts-covered)
  - [LiveView Concepts **Not** Covered](#liveview-concepts-not-covered)

- [**Tutorial**](#2-create-the-database)

  - [1. Creating the database](#2-create-the-database)
  - [2. Adding the templates](#2-building-templates-using-components)
  - [3. Creating the room list](#2-create-the-database)
  - [4. Creating the room form](#2-create-the-database)
  - [4. Live updating the room lists using PubSub ](#2-create-the-database)
  - [5. Deleting and updating rooms ](#2-create-the-database)
  - [6. Creating the message component ](#2-create-the-database)
  - [7. Showing users online with Presence ](#2-create-the-database)
  - [8. **BONUS:** Show users typing with JavaScript Hooks ](#2-create-the-database)

- [**Next Steps**](#2-create-the-database)
  - [Improvement Ideas](#2-create-the-database)
  - [Other Tutorials](#2-create-the-database)
  - [Contacts](#2-create-the-database)
  - [Credits](#2-create-the-database)

# Project Overview

In this tutorial you will build a multi chatroom app using the most powerful LiveView features. Users will have the ability to create their own room and update the name in realtime, with changes being instantly sent to anyone in the room without refreshing. Users may delete chatrooms, and any user in the deleted chatroom will navigate to the home page immediately with a notification saying the room has been deleted.

Inside a chatroom, a user may make their own username and send messages in realtime. Users can update and delete messages all done in realtime as well. Navigation between two pages will be seamless using Live Patching.

## Who is this for?

This project is great for **all skill levels**. _Beginners_ will learn the most powerful LiveView features and learn how to apply them in a moderately complex app. _Intermediate_ and _advanced_ Elixir programmers can use the code as a quick and easy reference for up-to-date LiveView (~> 1.0) code for topics listed in the [Concepts Covered](#concepts-covered) section.

## Prerequisites

You should be familiar with the Elixir language. Existing familiarity of Phoenix or Phoenix LiveView may help, but it is not required.

JavaScript is **NOT** required! There is no JavaScript throughout this course until the bonus section at the end. The bonus uses JavaScript, but it is optional and only adds a minor feature to the app.

## Concepts Covered

- Ecto Associations
- Ecto Queries
- Changesets
- Components
- Live Components
- JavaScript Commands (this is writen in Elixir)
- LiveView forms with associations
- LiveView Streams
- Phoenix PubSub for creating, updating, and deleting records
- Phoenix Presence for user tracking
- Patching properly with PubSub and Presence
- JavaScript Hooks

## Concepts **NOT** Covered

This tutorial focuses on the realtime liveview features over backend logic. Therefore there will not be authentication or authorization/permission logic. I may make a tutorial with these features if this tutorial does well, or you can add them yourself for practice!

# **Tutorial**

## 1. Creating the database

WIP!!! - Coming soon!


# Next Steps

## Improvement Ideas

## Other Tutorials

## Contacts

## Credits