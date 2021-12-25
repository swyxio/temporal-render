FROM temporalio/server:1.14.1

COPY custom-auto-setup.sh .
CMD ["custom-auto-setup.sh"]
