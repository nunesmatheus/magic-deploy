# Magic Deploy
Magic Deploy provides a simple way for self hosting a "git push deploy" solution on Kubernetes with the utmost flexibility and low cost on Google Cloud. Tweak a bit and use it anywhere.

## Usage
1. Create a kubernetes secret file with the keys listed in **./builder-deployment.yml**
2. Run ```kubectl create -f ./builder-deployment.yml && kubectl create -f ./builder-service.yml```
3. Run ```kubectl get services``` and copy the IP of the just created service(**builder**)
4. Run ```git remote add production root@$JUST_COPIED_IP:/app.git```
5. Copy your public SSH key(which might be **~/.ssh/id_rsa.pub**)
6. Run ```kubectl exec -it `kubectl get pods | grep builder | awk '{print $1}'` bash``` to enter the pod bash(unless you have another pod named **builder**)
7. Run ```echo $JUST_COPIED_SSH_PUBLIC_KEY > ~/.ssh/authorized_keys```
8. Exit the the pod(Ctrl+D)
9. Run ```git push production master```

From now on, all you need to do to rollout new versions is ```git push production master```.

## How it works
The **builder** pod runs a [Git server](https://git-scm.com/book/en/v1/Git-on-the-Server) that will receive your push, build a Docker image with the pushed repository ./Dockerfile and push the image to the [Google Cloud Container Registry](https://cloud.google.com/container-registry), then proceed to run ```kubectl set image deployment $APPLICATION_NAME $APPLICATION_NAME=$APPLICATION_TAG```, consequently rolling a update for the application without downtime.

Obs: $APPLICATION_TAG is **gcr.io/$PROJECT_ID/$APPLICATION_NAME:** followed by a 10 character random string, so keep that in mind if you are used to tagging your images with versions.

## Upcoming features
- Automagically rollout Heroku-like applications based on a Procfile
- Package resources in a helm chart
- Script to add SSH public key to pod
- ~Support multiple applications deploy with one builder pod~
- Shrink Dockerfile using lighter image

## Upcoming general improvements
- Halt hook execution upon any failure
