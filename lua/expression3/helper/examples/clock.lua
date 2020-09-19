/***********************************************************************************
    Ruskeths - E3 Clock
***********************************************************************************/
@name "Ruskeths E3 Clock";

server {
    entity gate = system.getEntity();
    
/***********************************************************************************
    CLOCK BODY
***********************************************************************************/
    hologram bg = new hologram(
		"models/sprops/geometry/t_fdisc_12.mdl",
		gate.toWorld(new vector(0, 0, -2)),
		gate.toWorld(new angle(0, 0, -90)),
		new vector(13, 1, 13)
	);
    bg.setMaterial("models/debug/debugwhite");
    bg.setColor(new color(145, 140, 125));
    bg.parent(gate);
    
    hologram ring = new hologram(
		"models/sprops/geometry/fring_42.mdl",
		gate.toWorld(new vector(0, 0, 0)),
		gate.toWorld(new angle(0, 0, -90)),
		new vector(4.2, 1, 4.2)
	);
    ring.setMaterial("models/debug/debugwhite");
    ring.setColor(new color(20, 20, 20));
    ring.parent(gate);
    
    hologram cog = new hologram(
		"models/sprops/geometry/t_fdisc_12.mdl",
		gate.toWorld(new vector(0, 0, 2)),
		gate.toWorld(new angle(0, 0, -90)),
		new vector(1, 3, 1)
	);
    cog.setMaterial("models/debug/debugwhite");
    cog.setColor(new color(0, 0, 0));
    cog.parent(gate);

/***********************************************************************************
    CLOCK FACE
***********************************************************************************/

    function void buildHours(num x, num y, num hour) {
        string h = math.toString(hour);
        angle ang = gate.toWorld(new angle(0, -90, 90));
        vector pos = gate.toWorld(new vector(x, y, 0) * 60);
        
        hologram frst = new hologram(
			"models/sprops/misc/alphanum/alphanum_" + h[1] + ".mdl",
			null,
			ang,
			new vector(0.5)
		);
        frst.setColor(new color(0, 0, 0));
        if (2 == #h) pos += (frst.forward() * 2.5);
        frst.setPos(pos);
        frst.parent(gate);
        
        if (2 == #h) {
            hologram snd = new hologram(
				"models/sprops/misc/alphanum/alphanum_" + h[2] + ".mdl",
				pos - (frst.forward() * 5),
				ang,
				new vector(0.5)
			);
            snd.setColor(new color(0, 0, 0));
            snd.parent(gate);
       }
   }
    
    function void buildMinute(num x, num y, num minute) {
        hologram h = new hologram(
			"cube",
			gate.toWorld(new vector(x, y, 0) * 70),
			null,
			new vector(0.1)
		);
        h.parent(gate);
        
        if (minute % 5 == 0) {
            h.setColor(new color(0, 0, 0));
            num hour = minute / 5;
            if (hour == 0) hour = 12;
            buildHours(x, y, hour);
       }
   }
        
    function void buildDisplay(num minute) {
        num step = ((2*math.pi()) / 60);
        num j = (step * minute) - (step * 15);
        num x = math.sin(j);
        num y = math.cos(j);
        
        buildMinute(x, y, minute);
   }
    
    num i = 0;
    
    timer.create("buildDisplay", 0.1, 60, function() {
        buildDisplay(i);
        i += 1;
   });

/***********************************************************************************
    CLOCK HANDS
***********************************************************************************/
    
    timer.create("buildHands", 7, 1, function() {
        hologram hs = new hologram(
			"cube",
			null,
			null,
			new vector(6, 0.1, 0.1)
		);
        hs.setColor(new color(227, 18, 53));
        hs.parent(gate);
        
        hologram hm = new hologram(
			"cube",
			null,
			null,
			new vector(5, 0.1, 0.1)
		);
        hm.parent(gate);
        
        hologram hh = new hologram(
			"cube",
			null,
			null,
			new vector(3.5, 0.1, 0.1)
		);
        hh.parent(gate);
        
        function void updateSeconds(num seconds) {
            num step = ((2*math.pi()) / 60);
            num j = (step * seconds) - (step * 15);
            num x = math.sin(j);
            num y = math.cos(j);
        
            vector of = gate.up() * 1;
            vector center = gate.getPos();
            vector aimpos = gate.toWorld(new vector(x, y, 0) * 70);
            angle ang = (center - aimpos).toAngle();
            hs.setPos((center + ((aimpos - center) * 0.5)) + (ang.forward() * 4) + of);
            hs.setAng(ang);
       };
        
        function void updateMinutes(num minutes) {
            num step = ((2*math.pi()) / 60);
            num j = (step * minutes) - (step * 15);
            num x = math.sin(j);
            num y = math.cos(j);
            
            vector of = gate.up() * 2;
            vector center = gate.getPos();
            vector aimpos = gate.toWorld(new vector(x, y, 0) * 60);
            angle ang = (center - aimpos).toAngle();
            hm.setPos((center + ((aimpos - center) * 0.5)) + (ang.forward() * 5) + of);
            hm.setAng(ang);
       };
        
        function void updateHours(num hours, num minutes) {
            num step = ((2*math.pi()) / 12);
            num j = (step * hours) + ((step / 60) * minutes) - (step * 15);
            num x = math.sin(j);
            num y = math.cos(j);
            
            vector of = gate.up() * 3;
            vector center = gate.getPos();
            vector aimpos = gate.toWorld(new vector(x, y, 0) * 60);
            angle ang = (center - aimpos).toAngle();
            hh.setPos((center + ((aimpos - center) * 0.5)) + (ang.forward() * 13) + of);
            hh.setAng(ang);
       };
            
        timer.create("moveHands", 1, 0, function() {
            date now = new date(time.now());
            updateSeconds(now.second);
            updateMinutes(now.minute);
            updateHours(now.hour, now.minute);
       });
   });
    
/***********************************************************************************
    CLOCK TEXT
***********************************************************************************/ 
   
    function void holoString(string text, hologram parent, vector pos, angle ang) {
        while(#text > 0) {
            string char = text[1];
            
            if (char != " ") {
                string prefix = "models/sprops/misc/alphanum/alphanum_";
                if (char.upper() != char) prefix += "l_";
                
                hologram letter = new hologram(
					prefix + char + ".mdl",
					pos,
					ang,
					new vector(0.5)
				);
                letter.setColor(new color(0, 255, 255));
                letter.parent(parent);
                parent = letter;
           }
            
            text = text.sub(2);
            pos -= (parent.forward() * 5);
       }
   }
    
    timer.create("buildText", 5, 1, function() {
        angle ang = gate.toWorld(new angle(0, -90, 90));
        
        vector pos = gate.toWorld(new vector(-10, -25, 0.5));
        holoString("Expression 3", bg, pos, ang);
        
        pos = gate.toWorld(new vector(10, -10, 0.5));
        holoString("Clock", bg, pos, ang);
   });
    
    
}
    
/***********************************************************************************
    SCRIPT END
***********************************************************************************/