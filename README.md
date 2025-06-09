# Phoenix LiveView 1.0 Multi Chatroom App Tutorial

![phoenix-chat-logo](./tutorial_resources/PHOENIX_LIVEVIEW_CHATROOM_TUTORIAL_THUMBNAIL.png)

A complete Phoenix LiveView (~> 1.0) tutorial to build a chatroom app where users can _create_, _update_, and _delete_ both chatrooms and messages **all in real time.**

## Preview

![phoenix-chat-logo](./tutorial_resources/PHOENIX_LIVEVIEW_CHATROOM_TUTORIAL_THUMBNAIL.png)
Example:
[**https://my-link-here.com/**](https://my-link-here.com/)

## Table of Contents

- [**Intro**](#what-we-will-build)

  - [Preview](#project-overview)
  - [Table of Contents](#table-of-contents)

- [**Project Overview**](#project-overview)

  - [Who is this for?](#who-is-this-for)
  - [Prerequisites](#prerequisites)
  - [Concepts Covered](#liveview-concepts-covered)
  - [Concepts **Not** Covered](#liveview-concepts-not-covered)

- [**Tutorial**](#2-create-the-database)

  - [1. Creating the database](#2-create-the-database)
  - [2. Adding the templates](#2-building-templates-using-components)
  - [3. Creating the room list](#2-create-the-database)
  - [4. Creating the room form](#2-create-the-database)
  - [5. Live updating the room list using PubSub ](#2-create-the-database)
  - [6. Paginating the room list with PubSub ](#2-create-the-database)
  - [7. Deleting and updating rooms ](#2-create-the-database)
  - [8. Creating the message component ](#2-create-the-database)
  - [9. Showing users online with Presence ](#2-create-the-database)
  - [10. **BONUS:** Show users typing with JavaScript Hooks ](#2-create-the-database)

- [**Next Steps**](#2-create-the-database)
  - [Improvement Ideas](#2-create-the-database)
  - [Other Tutorials](#2-create-the-database)
  - [Contacts](#2-create-the-database)
  - [Credits](#2-create-the-database)

# Project Overview

In this tutorial you will build a multi chatroom app using the most powerful LiveView features. Users will have the ability to create their own room and update the name in realtime, with changes being instantly sent to anyone in the room without refreshing. Users may delete chatrooms, and any user in the deleted chatroom will navigate to the home page immediately with a notification saying the room has been deleted.

Inside a chatroom, a user may make their own username and send messages in realtime. Users can update and delete messages all done in realtime as well. Navigation between two chatrooms will be seamless using Live Patching.

## Who is this for?

This project is great for **all skill levels**. _Beginners_ will learn the most powerful LiveView features and learn how they are applied in a moderately complex app. _Intermediate_ and _advanced_ Elixir programmers can use the code as a quick and easy reference for up-to-date LiveView (~> 1.0) code for topics listed in the [Concepts Covered](#concepts-covered) section.

## Prerequisites

You should be familiar with the Elixir language. Concepts like piping and pattern matching are heavily used throughout the tutorial over conditional statements. Existing familiarity of Phoenix or Phoenix LiveView may help, but it is not required.

JavaScript is **NOT** required! There is no JavaScript throughout this course until the bonus section at the end. The bonus uses JavaScript, but it is optional and only adds a minor feature to the app (the feature shows how many users are currently typing).

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
- Best Elixir Practices

## Concepts **NOT** Covered

This tutorial focuses more on the realtime liveview features over backend logic. Therefore there will not be authentication or authorization/permission logic. I do not cover testing either. I may make a tutorial with these features if this tutorial does well so be sure to star this repo, or you can add them yourself for practice!

# **Tutorial**

## 1. Creating the database

WIP!!! - Coming soon!

# Next Steps

## Improvement Ideas

Now that you finished this tutorial, here are some ideas to exand and improve the app. Some of these concepts I have overlooked to keep things simpler, or were not a big deal for this specific app. Other ideas are a rough roadmap for exanding this app.

### Refactor LiveComponents:

As it stands, our LiveComponents are not too reusable and limited to our current API. We also pass many props/variables into these LiveComponents. It is recommended to refactor the code to use function callbacks according to the LiveView documentation. Doing so will make your components more reusable and easier to maintain.

Learn more about this here: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html

### Integrate async result:

Loading database records may take a while to fetch, and during this time there is currently no UI indication that messages or rooms are loading. Furthermore, loading database records one after another will compound the time (as we do when fetching the rooms, and messages)! LiveView's AsyncResult fixes both these issues by loading messages and rooms in parallel, and giving an option to display a loading state as ecto fetches the records to be loaded. Integrating this feature may make your chat app even faster and give the users a better UX (user experience).

Learn more about this here: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.AsyncResult.html

### Add Authentication:

The the most obvious missing feature, so here is rough roadmap of how I would do it. Phoenix has great options for authentication, with the simplest being `mix phx.gen.auth` command. Start by intergrating the login/signup page, and eventually completely replace the `username` from the messages schema with a `user_id` association.

Next, learn how to integrate authentication in a LiveView with the links below. Remove and replace the "username" input field with a hidden input connected to the current `user_id`. Then adjust the messages query to include the username of its poster since you no longer have the easy `username` field. Finally, replace `socket.id` when using presence with the logged in `user.id` to show a list of logged in users, rather than how many tabs are open. You can also make a list of users currently on the page using Presence and put it to the right.

**Learn more:**

_Phoenix auth generator:_ https://hexdocs.pm/phoenix/mix_phx_gen_auth.html

_Authetnication combined with LiveView:_ https://hexdocs.pm/phoenix_live_view/security-model.html

### Add Authorization / Basic User Permissions:

_ONLY DO AFTER ADDING AUTHENTICATION LISTED ABOVE!_

Now that you have authentication, you can make sure users can only delete their own posts and rooms! For simple authorization, make it so the edit/delete buttons in messages are listed only for their own posts with a simple `:if={...your logic here}` comparison. You can also add a ownership to rooms with associations between the user and room, and only display the edit/delete commands for the owner.

Be sure to also check for permissions when submitting the forms. Make sure the hidden input for `user_id` matches what liveviews `user_id` when submitting a form (if you choose to use a hidden input), otherwise your app is easily hackable! You can also make it so the owner may delete any comments by adding extra logic.

### Add Advanced / Role Permissions and Private Rooms

_ONLY DO AFTER ADDING THE LAST TWO IMPROVEMENTS! (AUTHENTICATION AND AUTHORIZATION)_

Complex Authorization can get tough to manage, especially with roles. Consider learning and using a library like Pow or Guardian to manage permissions. To create private rooms and permissions, you will need a new record called "permissions" with a many-to-many relationship between rooms and users. Each user_id and room_id combination must be unique, and it will need a "role" field for user role in that specific room.

The 'owner' field in the room can be removed and replaced with a permission record for a more robust system (ex. upon user record deletion).

## Other Tutorials

## Contacts

## Credits

- Tailwind Chatroom Template by Saim Ansari
  - [larainfo.com/blogs/tailwind-css-chat-ui-example/](https://larainfo.com/blogs/tailwind-css-chat-ui-example/)
