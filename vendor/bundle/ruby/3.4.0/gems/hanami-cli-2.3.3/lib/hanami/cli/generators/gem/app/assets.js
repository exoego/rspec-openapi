import * as assets from "hanami-assets";

// Assets are managed by esbuild (https://esbuild.github.io), and can be
// customized below.
//
// Learn more at https://guides.hanamirb.org/assets/customization/.

await assets.run({
  esbuildOptionsFn: (args, esbuildOptions) => {
    // Customize your `esbuildOptions` here.
    //
    // Use the `args.watch` boolean as a condition to apply diffierent options
    // when running `hanami assets watch` vs `hanami assets compile`.

    return esbuildOptions;
  },
});
