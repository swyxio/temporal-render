FROM temporalio/server:1.14.1 # cant use auto-setup image, see https://github.com/sw-yx/temporal-render/issues/1


CMD ["custom-auto-setup.sh"]
