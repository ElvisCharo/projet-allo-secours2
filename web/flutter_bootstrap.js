{{flutter_js}}
{{flutter_build_config}}

const loader = document.getElementById('app-loader');

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();

    window.setTimeout(function () {
      loader?.classList.add('loader-hidden');
    }, 120);
  }
});
