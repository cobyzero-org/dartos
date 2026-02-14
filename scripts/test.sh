#Zip test_app
zip -r test_app.appdart ../test_app/lib ../test_app/manifest.json

#Install test_app
sudo dartos install test_app.appdart