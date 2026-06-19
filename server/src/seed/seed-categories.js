const seedCategories = async () => {
  try {
    const Categories = require("../model/categories.model");

    const categoryData = [
      {
        name: "Movies",
        slug: "movies",
        description: "Feature-length films across all genres",
        sort_order: 1,
      },
      {
        name: "TV Series",
        slug: "tv-series",
        description: "Episodic television series",
        sort_order: 2,
      },
      {
        name: "Documentaries",
        slug: "documentaries",
        description: "Non-fiction stories from around the world",
        sort_order: 3,
      },
      {
        name: "Originals",
        slug: "originals",
        description: "Exclusive content produced for the platform",
        sort_order: 4,
      },
      {
        name: "Trending",
        slug: "trending",
        description: "What everyone is watching right now",
        sort_order: 5,
      },
    ];

    let created = 0;
    for (const data of categoryData) {
      const [, isNew] = await Categories.findOrCreate({
        where: { slug: data.slug },
        defaults: { ...data, status: "active" },
      });
      if (isNew) created += 1;
    }

    console.info(
      `  Categories seeded — ${created} new, ${categoryData.length - created} existing`,
    );
  } catch (error) {
    console.error("  Failed to seed categories:", error.message);
  }
};

module.exports = { seedCategories };
