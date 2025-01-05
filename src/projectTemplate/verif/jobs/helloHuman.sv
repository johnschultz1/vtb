class helloHuman;

    `startJob
        int list_length;
        int random_index;

        static string hello_list[] = '{
            "Hello", "Hola", "Bonjour", "Hallo", "Ciao", "Olá", "Hallo", "Привет",
            "你好", "こんにちは", "안녕하세요", "नमस्ते", "مرحبا", "হ্যালো", "ہیلو",
            "ਸਤ ਸ੍ਰੀ ਅਕਾਲ", "வணக்கம்", "హలో", "ഹലോ", "ಹಲೋ", "नमस्कार", "નમસ્તે",
            "สวัสดี", "Xin chào", "Habari", "Sawubona", "Molo", "Hallo", "Merhaba",
            "سلام", "Γειά σου", "שלום", "Cześć", "Ahoj", "Ahoj", "Szia", "Salut",
            "Здравейте", "Здраво", "Bok", "Zdravo", "Përshëndetje", "გამარჯობა",
            "Բարեւ", "Привіт", "Прывітанне", "Hei", "Hej", "Hei", "Hej", "Halló",
            "Helo", "Dia dhuit", "Halò", "Kaixo", "Hola", "Ola", "Saluton", "Salve",
            "Bonjou", "Wa gwaan", "Kamusta", "Selamat pagi", "Halo", "Kia ora",
            "Talofa", "Malo e lelei", "Bula", "Aloha", "Сайн байна уу", "Сәлеметсіз бе",
            "Salom", "Салом", "Salam", "Салам", "سلام", "ສະບາຍດີ", "សួស្ដី", "မင်္ဂလာပါ",
            "ආයුබෝවන්", "नमस्ते", "བཀྲ་ཤིས་བདེ་ལེགས", "Bawo ni", "Nnọọ", "Sannu",
            "ሰላም", "Salaan", "Moni", "Mhoro", "Sawubona", "ሰላም", "Mbote", "Muraho",
            "Gyebale", "Dumela", "Lumela", "Akkam", "Salaam aleekum", "Yá'át'ééh"
        };
        // Get the length of the array
        list_length = hello_list.size();

        // Select a random index
        random_index = $urandom_range(0, list_length - 1);

        // Fetch the random greeting
        $display(hello_list[random_index]);
        //#1;
    `endJob

endclass;