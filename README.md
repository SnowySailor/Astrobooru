# Astrobooru
![Philomena](/assets/static/images/phoenix.svg)

## Getting started
On systems with `docker` and `docker-compose` installed, the process should be as simple as:

```
docker-compose build
docker-compose up
```

If you use `podman` and `podman-compose` instead, the process for constructing a rootless container is nearly identical:

```
podman-compose build
podman-compose up
```

Once the application has started, navigate to http://localhost:8080 and login with admin@example.com / examplepassword

## Troubleshooting

If you are running Docker on Windows and the application crashes immediately upon startup, please ensure that `autocrlf` is set to `false` in your Git config, and then re-clone the repository. Additionally, it is recommended that you allocate at least 4GB of RAM to your Docker VM.

If you run into an Elasticsearch bootstrap error, you may need to increase your `max_map_count` on the host as follows:
```
sudo sysctl -w vm.max_map_count=262144
```

If you have SELinux enforcing, you should run the following in the application directory on the host before proceeding:
```
chcon -Rt svirt_sandbox_file_t .
```

This allows Docker or Podman to bind mount the application directory into the containers.

## Deployment
You need a key installed on the server you target, and the git remote installed in your ssh configuration.

    git remote add production philomena@<serverip>:philomena/

The general syntax is:

    git push production master

And if everything goes wrong:

    git reset HEAD^ --hard
    git push -f production master

(to be repeated until it works again)

## TODO
* Automatic platesolving and tag modification with catalog objects (M, NGC, C, Arp, etc.)
* Create "telescope:" colored tag prefix (grey)
* Create "mount:" colored tag prefix (yellow)
* Create "guidescope:" colored tag prefix (green)
* Create "camera:" colored tag prefix (red)
* Create "editing-software:" colored tax prefix (light blue)
* Copy existing pages from DB to seeds.json
* Add total integration time to user stats
* Exposure lengths and filter types for images
  * Allow search by total integration time
* Allow users to upgrade to monthly premium subscription
  * PayPal integration
  * Credit card integration?
  * Create premium user role
* Sift through text to remove all character names and non-astronomy references
* Limit uploads to 15MB for premium users
* Limit uploads to 2MB for non-premium users
* Premium account subscriptions
* `"artist:"` to `"photographer:"`
* Default profile images changed
* Restyle pages to be darker
* Contact page