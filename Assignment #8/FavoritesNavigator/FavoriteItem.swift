import Foundation

struct FavoriteItem {
    let title: String
    let subtitle: String
    let imageName: String
    let rating: Int
    let description: String
}

extension FavoriteItem {
    static let allItems: [FavoriteItem] = [
        FavoriteItem(
            title: "Japan",
            subtitle: "East Asia · Tokyo",
            imageName: "japan",
            rating: 5,
            description: "Japan blends ancient traditions with ultra-modern city life across four main islands. From the serene temples of Kyoto and snow-capped Mount Fuji to the neon-lit streets of Tokyo, every region offers a distinct cultural experience. Its world-renowned cuisine, high-speed rail network, and seasonal cherry blossoms make it an unforgettable destination."
        ),
        FavoriteItem(
            title: "Italy",
            subtitle: "Southern Europe · Rome",
            imageName: "italy",
            rating: 5,
            description: "Italy is home to some of the greatest art, architecture, and gastronomy in human history. Visitors can explore Roman ruins in the capital, Renaissance masterpieces in Florence, and romantic canals in Venice. Beyond the historic cities, the Amalfi Coast and Tuscan countryside offer breathtaking Mediterranean landscapes."
        ),
        FavoriteItem(
            title: "Switzerland",
            subtitle: "Central Europe · Bern",
            imageName: "switzerland",
            rating: 5,
            description: "Switzerland is famous for its dramatic Alpine peaks, crystal-clear lakes, and storybook villages. Iconic mountains like the Matterhorn and Jungfrau attract hikers and skiers from around the globe year-round. Efficient scenic trains, artisan chocolates, and watchmaking heritage complete its timeless appeal."
        ),
        FavoriteItem(
            title: "New Zealand",
            subtitle: "Oceania · Wellington",
            imageName: "new_zealand",
            rating: 5,
            description: "New Zealand packs volcanic plateaus, fjords, glaciers, and golden beaches into two spectacular islands. The South Island's Milford Sound and Southern Alps look like scenes from another world, while the North Island features geothermal wonders and rich Māori culture. It is widely considered the adventure capital of the world."
        ),
        FavoriteItem(
            title: "Iceland",
            subtitle: "Northern Europe · Reykjavik",
            imageName: "iceland",
            rating: 5,
            description: "Known as the Land of Fire and Ice, Iceland is a geological wonderland of active volcanoes, geysers, and massive glaciers. Travelers drive the famous Ring Road to witness thunderous waterfalls, black-sand beaches, and geothermal lagoons. In winter, its dark skies provide one of the best vantage points for the Northern Lights."
        ),
        FavoriteItem(
            title: "Kazakhstan",
            subtitle: "Central Asia · Astana",
            imageName: "kazakhstan",
            rating: 5,
            description: "Kazakhstan is the world's largest landlocked country, stretching from the Caspian Sea to the Altai Mountains. Dramatic natural landmarks like Charyn Canyon, Kolsai Lakes, and the Tian Shan peaks showcase its vast steppe and mountain beauty. Modern cities like Astana and Almaty combine nomadic hospitality with bold contemporary architecture."
        ),
        FavoriteItem(
            title: "Spain",
            subtitle: "Southern Europe · Madrid",
            imageName: "spain",
            rating: 4,
            description: "Spain captivates visitors with its sunny Mediterranean coastlines, vibrant festivals, and diverse regional cultures. Gaudí's surreal architecture in Barcelona contrasts with the Moorish palaces of Granada and the world-class museums of Madrid. Late-night tapas, flamenco music, and historic plazas give every city an unmistakable energy."
        ),
        FavoriteItem(
            title: "Canada",
            subtitle: "North America · Ottawa",
            imageName: "canada",
            rating: 5,
            description: "Canada spans six time zones and boasts some of the most pristine wilderness on Earth. Turquoise glacial lakes in Banff and Jasper National Parks draw nature lovers from every continent. Meanwhile, multicultural cities like Vancouver, Toronto, and Montreal offer thriving food and arts scenes."
        ),
        FavoriteItem(
            title: "Greece",
            subtitle: "Southern Europe · Athens",
            imageName: "greece",
            rating: 4,
            description: "Greece is the cradle of Western civilization and home to thousands of sun-drenched islands in the Aegean and Ionian seas. Ancient landmarks like the Acropolis in Athens stand alongside whitewashed cliffside villages in Santorini and Mykonos. Fresh Mediterranean cuisine and warm coastal waters make it a classic summer escape."
        ),
        FavoriteItem(
            title: "South Korea",
            subtitle: "East Asia · Seoul",
            imageName: "south_korea",
            rating: 5,
            description: "South Korea seamlessly connects centuries-old royal palaces with cutting-edge technology and pop culture. In Seoul, traditional hanok villages sit just minutes away from futuristic design plazas and bustling night markets. Scenic Jeju Island and coastal Busan add volcanic landscapes and seaside temples to the journey."
        ),
        FavoriteItem(
            title: "Norway",
            subtitle: "Northern Europe · Oslo",
            imageName: "norway",
            rating: 5,
            description: "Norway's coastline is carved by deep, dramatic fjords flanked by towering cliffs and cascading waterfalls. Above the Arctic Circle, the Lofoten Islands and Tromsø offer midnight sun in summer and aurora borealis in winter. Its strong maritime heritage and outdoor lifestyle make every region rewarding to explore."
        ),
        FavoriteItem(
            title: "France",
            subtitle: "Western Europe · Paris",
            imageName: "france",
            rating: 4,
            description: "France is celebrated worldwide for its art, haute cuisine, and diverse landscapes ranging from Normandy's cliffs to the French Riviera. Paris enchants visitors with the Eiffel Tower, the Louvre, and charming riverside cafés along the Seine. Outside the capital, lavender fields in Provence and châteaux in the Loire Valley await."
        ),
        FavoriteItem(
            title: "Mexico",
            subtitle: "North America · Mexico City",
            imageName: "mexico",
            rating: 4,
            description: "Mexico offers a rich tapestry of indigenous heritage, colonial architecture, and biodiverse landscapes. Ancient Mayan and Aztec pyramids stand near vibrant cities filled with street art and UNESCO-recognized cuisine. From the cenotes of the Yucatán Peninsula to the beaches of Oaxaca, its cultural depth is unmatched."
        ),
        FavoriteItem(
            title: "Australia",
            subtitle: "Oceania · Canberra",
            imageName: "australia",
            rating: 4,
            description: "Australia is a continent of striking contrasts, from the red deserts of the Outback to the coral reefs of the Great Barrier Reef. Iconic coastal cities like Sydney and Melbourne offer world-class beaches, coffee culture, and performing arts. Unique wildlife such as kangaroos and koalas can be spotted across its national parks."
        ),
        FavoriteItem(
            title: "Portugal",
            subtitle: "Southern Europe · Lisbon",
            imageName: "portugal",
            rating: 5,
            description: "Portugal charms travelers with its Atlantic beaches, tiled facades, and soulful Fado music. Historic yellow trams climb the hills of Lisbon, while Porto's riverside cellars overlook the scenic Douro Valley. Further south, the Algarve coast features golden sea cliffs, hidden caves, and year-round sunshine."
        ),
        FavoriteItem(
            title: "Peru",
            subtitle: "South America · Lima",
            imageName: "peru",
            rating: 5,
            description: "Peru encompasses high Andean peaks, Pacific coastline, and a vast stretch of the Amazon rainforest. Tracing the Inca Trail to the cloud-forest citadel of Machu Picchu is one of the world's great travel experiences. Meanwhile, Lima has emerged as a global culinary capital celebrated for its fresh ceviche and fusion dishes."
        ),
        FavoriteItem(
            title: "Thailand",
            subtitle: "Southeast Asia · Bangkok",
            imageName: "thailand",
            rating: 4,
            description: "Thailand combines ornate gilded temples, lively street food markets, and tropical limestone islands. Bangkok buzzes with riverside shrines and floating markets, while northern Chiang Mai is surrounded by misty mountains and elephant sanctuaries. In the south, Phuket and Krabi offer turquoise waters and coral reefs."
        ),
        FavoriteItem(
            title: "Morocco",
            subtitle: "North Africa · Rabat",
            imageName: "morocco",
            rating: 4,
            description: "Morocco sits at the crossroads of Africa and Europe, offering labyrinthine medinas, Atlas Mountain passes, and Sahara Desert dunes. Marrakech dazzles the senses with colorful spice souks, mosaic courtyards, and lively evening squares. Blue-painted Chefchaouen and coastal Essaouira showcase the country's artistic charm."
        ),
        FavoriteItem(
            title: "Brazil",
            subtitle: "South America · Brasília",
            imageName: "brazil",
            rating: 4,
            description: "Brazil is defined by the rhythmic energy of samba, the vast Amazon basin, and dramatic coastal scenery. Rio de Janeiro's Sugarloaf Mountain and Christ the Redeemer overlook world-famous beaches like Copacabana and Ipanema. Along its borders, the thunderous cascades of Iguazu Falls form one of nature's greatest spectacles."
        ),
        FavoriteItem(
            title: "Turkey",
            subtitle: "Eurasia · Ankara",
            imageName: "turkey",
            rating: 5,
            description: "Straddling Europe and Asia, Turkey is an open-air museum of Byzantine, Roman, and Ottoman history. Istanbul's Hagia Sophia, Blue Mosque, and Grand Bazaar overlook the busy waters of the Bosphorus Strait. Inland, hot-air balloons drift at sunrise above the fairy chimneys and cave dwellings of Cappadocia."
        )
    ]
}
