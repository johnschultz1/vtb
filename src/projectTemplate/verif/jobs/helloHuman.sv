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

class delay;

    `startJob
        #(cfg.ints["CYCLES"]);
    `endJob

endclass;

//class rstSeq;

   // `startJob
   //     inf.setDut(cfg.strings["RSTSIG"],0);
   //     #(cfg.ints["ONCYCLES"]);
   //     inf.setDut(cfg.strings["RSTSIG"],1);
   // `endJob

//endclass;

class automatic toggleSeq;
    string id;
    //virtual dutInterface vif;


   // function new(string id, dutIf);
       // this.id =id;
      //  vif = dutIf;
  //  endfunction

      `startJob
     //`taskStart(toggleSeq)

        automatic  msg_t configuration = cfg; 
        bit sigInit;
        // init 
        $display(configuration.strings["SIG"]);
        sigInit = configuration.ints["SIGINIT"];
        vif.setDut(configuration.strings["SIG"],sigInit);
        #(configuration.ints["TOGGLEINITDELAY"]);
    
        // toggle forever
        if(configuration.bool["TOGGLEFOREVER"]) begin
            while(1) begin
                vif.setDut(configuration.strings["SIG"],~sigInit);
                sigInit = ~sigInit;
                #(configuration.ints["TOGGLEDELAY"]);
            end
        // toggle x # cycles
        end else if (configuration.ints.exists("TOGGLECYCLES")) begin
            repeat(configuration.ints["TOGGLECYCLES"]) begin
                vif.setDut(configuration.strings["SIG"],~sigInit);
                sigInit = ~sigInit;
                #(configuration.ints["TOGGLEDELAY"]);
            end
        // toggle once
        end else begin
            vif.setDut(configuration.strings["SIG"],~sigInit);
            sigInit = ~sigInit;
        end
      `endJob

endclass;

class broadcaster;

    `startJob
        msg_t msg;

        repeat (10) begin
            msg.strings["content"] = cfg.strings["content"];
            msg.stringList["ID"]   = cfg.stringList["ID"];
            msg.msgType = cfg.strings["BROADCASTMSGNAME"];
            //#1;
            publishMsg(.taskName(cfg.strings["name"]), .msg(msg));
            //#1;
        end

        //#1;
    `endJob

endclass;

class receiver;

    `startJob
        automatic bit valid = 0;
        automatic string msgName = cfg.strings["BROADCASTMSGNAME"];
        automatic stringList_t idList;
        automatic     msg_t msg;
        static int count[string];
        automatic string name;

        idList = msgs[msgName].stringList["ID"];
                    msg = msgs["broadcast"];

        foreach(idList[x]) begin
            automatic string ID = idList[x];
            if (ID == cfg.strings["ID"]) begin
                valid = 1;
                count[ID] = count[ID] +1;
                name = ID;
            end
        end

        if (valid == 1) begin
            $display($sformatf("MSG ACK From ID: %s received the following message:\n%s",cfg.strings["ID"], msgs[msgName].strings["content"] ));
            $display($sformatf("Have Recieved %d messages in total", count[name]  ));
        end
    `endJob

endclass;